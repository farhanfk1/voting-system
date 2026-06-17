/// Ganache account pool for this app.
///
/// **Admin** uses index [adminAccountIndex] (election create, add candidate, advance phase).
/// **Voters** get indices 1, 2, 3… assigned once per Firebase user at signup/login.
///
/// If voting fails with "invalid account", open Ganache → Accounts → copy each
/// account's private key into [privateKeys] in the same order (0 = admin, 1–9 = voters).
class GanacheAccounts {
  GanacheAccounts._();

  static const int adminAccountIndex = 0;

  /// Must match accounts in your Ganache workspace (same order as the UI list).
  static const List<String> privateKeys = [
    // 0 — Admin (keep in sync with your Ganache account used for deploy/admin)
    '0x6c4c9f507474aec6dd31c94901b3df906a75dfbd11ffdf29a4c3bdfc3810322b',
    // 1–9 — Voters (default Ganache keys; replace from your Ganache if different)
  '0x0ce8ad30437eaab1f8af8060446ef6698e80197059a12417096652841cfea864',

'0xaa5110da67e9a2191d0f85b40903f378d0163d0ccdfd2aec468d139a11499d75',

'0xfd217ffefbb8e3528471c7ad1eb99397f019a5aa1f14966f55410e36e0619dee',

'0xc96c7b447144e7f8fe7122449085f91f68f62435dc579dab2d4796307f3b9707',

'0xeb1005eb7ecad7c40aa6238f799e56367b5abbc8ea651c97cfcab06a9555c4ff',

'0x32ce6a662f2c53c78e4ead85b59377bd774ff7612a406f5b6aeadfbf7b27e56c',

'0x74134e6d774eaa3775f823f7c076a246ebe874872d9a84e039a548e9bd4fc91b',

'0x8b6e1bc2d8442cd6a7d5795780b36590de5039fe5d9b02bfb5219a6ed0486446',

'0x3550a3d49784b645fc15be0903a8ad18ef449ac12f9da0ed70bb0524507fb501'
  ];

  static String get adminPrivateKey => privateKeys[adminAccountIndex];

  static const int voterAccountStartIndex = 1;

  static int get maxVoters => privateKeys.length - voterAccountStartIndex;

  static bool isValidIndex(int index) =>
      index >= 0 && index < privateKeys.length;

  static String privateKeyAt(int index) {
    if (!isValidIndex(index)) {
      throw ArgumentError('Invalid Ganache account index: $index');
    }
    return privateKeys[index];
  }
}
