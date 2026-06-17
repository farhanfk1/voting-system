import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';

class ResultScreen extends StatefulWidget {
  final int electionId;

  const ResultScreen({super.key, required this.electionId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Map<String, dynamic>? result;
  bool _loading = true;
  String? _error;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vm = Provider.of<VoteViewModel>(context, listen: false);
      final res = await vm.getResult(widget.electionId);
      if (!mounted) return;
      setState(() {
        result = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().split('\n').first;
      });
    }
  }

  int _voteCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is BigInt) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return List<dynamic>.from(value);
    return [];
  }

  List<_CandidateResult> _parseResults() {
    if (result == null) return [];
    final ids = _asList(result!['ids']);
    final names = _asList(result!['names']);
    final votes = _asList(result!['votes']);

    return List.generate(ids.length, (i) {
      return _CandidateResult(
        name: names.length > i ? names[i]?.toString() ?? 'Candidate ${i + 1}' : 'Candidate ${i + 1}',
        votes: _voteCount(votes.length > i ? votes[i] : 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseResults();
    final totalVotes = parsed.fold<int>(0, (sum, c) => sum + c.votes);
    final maxVotes = parsed.isEmpty ? 0 : parsed.map((c) => c.votes).reduce((a, b) => a > b ? a : b);
    final winnerIndex = parsed.isEmpty
        ? -1
        : parsed.indexWhere((c) => c.votes == maxVotes && maxVotes > 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Election Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchResult,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _error != null
                ? _buildErrorState()
                : parsed.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchResult,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildSummaryCard(totalVotes, parsed.length),
                            if (winnerIndex >= 0) ...[
                              const SizedBox(height: 16),
                              _buildWinnerCard(parsed[winnerIndex]),
                            ],
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 12),
                              child: Text(
                                'All Candidates',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...List.generate(parsed.length, (index) {
                              final item = parsed[index];
                              final fraction = totalVotes > 0 ? item.votes / totalVotes : 0.0;
                              final isWinner = index == winnerIndex && maxVotes > 0;

                              return _buildResultCard(
                                rank: index + 1,
                                name: item.name,
                                votes: item.votes,
                                fraction: fraction,
                                isWinner: isWinner,
                              );
                            }),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalVotes, int candidateCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryTile(Icons.how_to_vote, '$totalVotes', 'Total Votes'),
          Container(width: 1, height: 48, color: Colors.grey[300]),
          _summaryTile(Icons.people, '$candidateCount', 'Candidates'),
        ],
      ),
    );
  }

  Widget _summaryTile(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(_CandidateResult winner) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leading Candidate',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  winner.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${winner.votes} vote${winner.votes == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required int rank,
    required String name,
    required int votes,
    required double fraction,
    required bool isWinner,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isWinner
            ? Border.all(color: Colors.amber, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isWinner
                    ? Colors.amber.shade100
                    : Colors.deepPurple.withOpacity(0.12),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWinner ? Colors.orange.shade800 : Colors.deepPurple,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$votes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isWinner ? Colors.green : Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(fraction * 100).toStringAsFixed(1)}% of total votes',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.poll_outlined, size: 72, color: Colors.white.withOpacity(0.8)),
          const SizedBox(height: 16),
          const Text(
            'No results yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votes will appear here once casting begins.',
            style: TextStyle(color: Colors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateResult {
  final String name;
  final int votes;

  _CandidateResult({required this.name, required this.votes});
}
