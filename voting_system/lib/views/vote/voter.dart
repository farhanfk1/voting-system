import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';
import 'package:voting_system/widgets/round_button.dart';

class VoterScreen extends StatefulWidget {
  final int electionId;
  final String electionName;

  const VoterScreen({
    super.key,
    required this.electionId,
    required this.electionName,
  });

  @override
  State<VoterScreen> createState() => _VoterScreenState();
}

class _VoterScreenState extends State<VoterScreen> with AutomaticKeepAliveClientMixin {
  int? selectedCandidate;
  List<Map<String, dynamic>> _candidates = [];
  bool _loading = true;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => _loading = true);
    try {
      final vm = Provider.of<VoteViewModel>(context, listen: false);
      final candidates = await vm.getCandidates(widget.electionId);
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _loading = false;
        if (selectedCandidate != null) {
          final exists = _candidates.any((c) => c['id'] == selectedCandidate);
          if (!exists) selectedCandidate = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load candidates: $e')),
      );
    }
  }

  Future<void> _vote() async {
    if (selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate first')),
      );
      return;
    }
    try {
      final message = await Provider.of<VoteViewModel>(context, listen: false)
          .castVote(widget.electionId, selectedCandidate!);
      if (!mounted) return;

      final isSuccess = message.toLowerCase().contains('success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.orange,
        ),
      );

      if (!isSuccess) return;

      Navigator.pushNamed(
        context,
        RoutesName.result,
        arguments: {'electionId': widget.electionId},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vote failed: ${e.toString().split('\n').first}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _goToResults() {
    Navigator.pushNamed(
      context,
      RoutesName.result,
      arguments: {'electionId': widget.electionId},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = Provider.of<VoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.electionName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _candidates.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildCandidateList()),
                      _buildBottomActions(vm),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.how_to_vote,
              color: Colors.deepPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.electionName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a candidate below, then submit your vote',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _candidates.length,
      itemBuilder: (context, index) {
        final candidate = _candidates[index];
        final id = candidate['id'] is int
            ? candidate['id'] as int
            : (candidate['id'] as BigInt).toInt();
        final isSelected = selectedCandidate == id;

        return GestureDetector(
          onTap: () => setState(() => selectedCandidate = id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.green.withOpacity(0.25)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isSelected
                      ? Colors.green
                      : Colors.deepPurple.withOpacity(0.15),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    candidate['name']?.toString() ?? 'Candidate ${index + 1}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey[400],
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(VoteViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: RoundButton(
              title: 'Submit Vote',
              loading: vm.isLoading,
              height: 50,
              width: double.infinity,
              onPress: _vote,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _goToResults,
              icon: const Icon(Icons.bar_chart, color: Colors.deepPurple),
              label: const Text(
                'View Results',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.deepPurple, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 72, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 16),
            const Text(
              'No candidates yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask the admin to add candidates before voting.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loadCandidates,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
