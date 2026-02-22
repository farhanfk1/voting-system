import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/viewsModel/election_view_model.dart';
import 'package:voting_system/widgets/round_button.dart';

class ManageElectionScreen extends StatefulWidget {
  final int electionId;
  final String electionName;
  final int currentPhase;

  const ManageElectionScreen({
    super.key,
    required this.electionId,
    required this.electionName,
    required this.currentPhase,
  });

  @override
  State<ManageElectionScreen> createState() => _ManageElectionScreenState();
}

class _ManageElectionScreenState extends State<ManageElectionScreen> {
  final _candidateController = TextEditingController();
  List<Map<String, dynamic>> _candidates = [];
  bool _loadingCandidates = true;
  int _currentPhase = 0;

  @override
  void initState() {
    super.initState();
    _currentPhase = widget.currentPhase;
    _loadCandidates();
  }

  @override
  void dispose() {
    _candidateController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    setState(() => _loadingCandidates = true);
    try {
      final vm = Provider.of<ElectionViewModel>(context, listen: false);
      final candidates = await vm.getCandidates(widget.electionId);
      setState(() {
        _candidates = candidates;
        _loadingCandidates = false;
      });
    } catch (e) {
      setState(() => _loadingCandidates = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading candidates: $e')),
        );
      }
    }
  }

  Future<void> _addCandidate() async {
    final name = _candidateController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter candidate name')),
      );
      return;
    }

    try {
      final vm = Provider.of<ElectionViewModel>(context, listen: false);
      await vm.addCandidate(widget.electionId, name);
      _candidateController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidate added successfully')),
      );
      await _loadCandidates();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().split('\n').first}')),
      );
    }
  }

  Future<void> _advancePhase() async {
    String actionText = _currentPhase == 0 ? 'Start Voting' : 'End Voting';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(actionText),
        content: Text(
          _currentPhase == 0
              ? 'This will start the voting phase. Users can vote after this. Are you sure?'
              : 'This will end the voting phase. No more votes will be accepted. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final vm = Provider.of<ElectionViewModel>(context, listen: false);
      await vm.advancePhase(widget.electionId);
      setState(() {
        _currentPhase = _currentPhase + 1;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$actionText successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('Need at least 1 candidate')) {
          errorMsg = 'You need to add at least 1 candidate before starting voting.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg')),
        );
      }
    }
  }

  String _getPhaseText(int phase) {
    switch (phase) {
      case 0:
        return 'Registration';
      case 1:
        return 'Voting';
      case 2:
        return 'Ended';
      default:
        return 'Unknown';
    }
  }

  Color _getPhaseColor(int phase) {
    switch (phase) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ElectionViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${widget.electionName}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Phase:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getPhaseColor(_currentPhase),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getPhaseText(_currentPhase),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_currentPhase < 2)
                        SizedBox(
                          width: double.infinity,
                          child: RoundButton(
                            title: _currentPhase == 0 ? 'Start Voting Phase' : 'End Voting Phase',
                            loading: vm.isLoading,
                            onPress: _advancePhase,
                          ),
                        ),
                      if (_currentPhase == 2)
                        const Center(
                          child: Text(
                            'This election has ended.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_currentPhase == 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Candidate',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _candidateController,
                          decoration: InputDecoration(
                            hintText: 'Enter candidate name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: RoundButton(
                            title: 'Add Candidate',
                            loading: vm.isLoading,
                            onPress: _addCandidate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Candidates',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _loadCandidates,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_loadingCandidates)
                        const Center(child: CircularProgressIndicator())
                      else if (_candidates.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No candidates added yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = _candidates[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                candidate['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: _currentPhase >= 1
                                  ? Text(
                                      '${candidate['votes']} votes',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
