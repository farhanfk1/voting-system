import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:voting_system/config/ganache_accounts.dart';
import 'package:web3dart/web3dart.dart';

/// Assigns one Ganache account per Firebase user (stored in Firestore).
class WalletAssignmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Ensures the logged-in user has a Ganache account index. Returns the index.
  Future<int> ensureWalletAssigned({String? uid}) async {
    final userId = uid ?? _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final doc = await _firestore.collection('voters').doc(userId).get();
    if (doc.exists) {
      final index = doc.data()?['ganacheAccountIndex'];
      if (index is int && GanacheAccounts.isValidIndex(index)) {
        return index;
      }
    }

    return assignWalletToUser(userId);
  }

  /// Picks the next free Ganache account (indices 1..9) for this user.
  Future<int> assignWalletToUser(String uid) async {
    final usedIndices = await _getUsedAccountIndices();

    for (int i = GanacheAccounts.voterAccountStartIndex;
        i < GanacheAccounts.privateKeys.length;
        i++) {
      if (usedIndices.contains(i)) continue;

      final privateKey = GanacheAccounts.privateKeyAt(i);
      final address = await _addressFromPrivateKey(privateKey);

      await _firestore.collection('voters').doc(uid).set(
        {
          'ganacheAccountIndex': i,
          'walletAddress': address.hex,
        },
        SetOptions(merge: true),
      );

      debugPrint(
        'Assigned Ganache account #$i (${address.hex}) to user $uid',
      );
      return i;
    }

    throw Exception(
      'No Ganache voter accounts left. Maximum ${GanacheAccounts.maxVoters} voters. '
      'Add more keys in lib/config/ganache_accounts.dart or reset Ganache.',
    );
  }

  Future<String?> getPrivateKeyForCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return getPrivateKeyForUser(uid);
  }

  Future<String?> getPrivateKeyForUser(String uid) async {
    final doc = await _firestore.collection('voters').doc(uid).get();
    if (!doc.exists) return null;

    final index = doc.data()?['ganacheAccountIndex'];
    if (index is! int || !GanacheAccounts.isValidIndex(index)) return null;

    return GanacheAccounts.privateKeyAt(index);
  }

  Future<String?> getWalletAddressForCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('voters').doc(uid).get();
    return doc.data()?['walletAddress'] as String?;
  }

  Future<Set<int>> _getUsedAccountIndices() async {
    final snapshot = await _firestore.collection('voters').get();
    final used = <int>{};

    for (final doc in snapshot.docs) {
      final index = doc.data()['ganacheAccountIndex'];
      if (index is int) {
        used.add(index);
      }
    }

    // Admin account is never assigned to voters
    used.add(GanacheAccounts.adminAccountIndex);
    return used;
  }

  Future<EthereumAddress> _addressFromPrivateKey(String privateKeyHex) async {
    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    return credentials.extractAddress();
  }
}
