import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VoteViewModel>(context, listen: false).init();
    });
  }

  int _getPhaseValue(dynamic phase) {
    if (phase is BigInt) return phase.toInt();
    if (phase is int) return phase;
    return 0;
  }

  String _getPhaseText(int phase) {
    switch (phase) {
      case 0:
        return 'Coming Soon';
      case 1:
        return 'Vote Now';
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

  IconData _getPhaseIcon(int phase) {
    switch (phase) {
      case 0:
        return Icons.hourglass_empty;
      case 1:
        return Icons.how_to_vote;
      case 2:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Elections",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.init(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : vm.elections.isEmpty
                ? const Center(
                    child: Text(
                      "No Elections Found!",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => vm.init(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.elections.length,
                      itemBuilder: (context, index) {
                        final election = vm.elections[index];
                        final phase = _getPhaseValue(election['phase']);
                        final isVotingPhase = phase == 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isVotingPhase ? 1.0 : 0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isVotingPhase
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.black26,
                                blurRadius: isVotingPhase ? 12 : 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                            border: isVotingPhase
                                ? Border.all(color: Colors.green, width: 2)
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    election['name'] ?? 'Election',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isVotingPhase
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPhaseColor(phase),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getPhaseIcon(phase),
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getPhaseText(phase),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                phase == 0
                                    ? 'Voting has not started yet'
                                    : phase == 1
                                        ? 'Tap to cast your vote'
                                        : 'Voting has ended',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isVotingPhase
                                      ? Colors.green[700]
                                      : Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            trailing: isVotingPhase
                                ? const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    phase == 2 ? Icons.bar_chart : Icons.lock,
                                    color: Colors.grey,
                                  ),
                            onTap: () {
                              if (isVotingPhase) {
                                Navigator.pushNamed(
                                  context,
                                  RoutesName.voter,
                                  arguments: {
                                    'electionId': election['id'] is BigInt
                                        ? election['id']
                                        : BigInt.from(election['id'] as int),
                                    'electionName': election['name'] ?? 'Election',
                                  },
                                );
                              } else if (phase == 2) {
                                Navigator.pushNamed(
                                  context,
                                  RoutesName.result,
                                  arguments: {
                                    'electionId': election['id'] is BigInt
                                        ? election['id']
                                        : BigInt.from(election['id'] as int),
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Voting has not started yet. Please wait.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
