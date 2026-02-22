import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/viewsModel/election_view_model.dart';

class AdminElectionListScreen extends StatefulWidget {
  const AdminElectionListScreen({super.key});

  @override
  State<AdminElectionListScreen> createState() => _AdminElectionListScreenState();
}

class _AdminElectionListScreenState extends State<AdminElectionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ElectionViewModel>(context, listen: false).init();
    });
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
        title: const Text('Admin - Manage Elections'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.createElection);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Create Election',
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No Elections Found',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, RoutesName.createElection);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Election'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await vm.fetchElections();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.elections.length,
                      itemBuilder: (context, index) {
                        final election = vm.elections[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              election.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Phase: '),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPhaseColor(election.phase),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getPhaseText(election.phase),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.settings,
                              color: Colors.deepPurple,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutesName.manageElection,
                                arguments: {
                                  'electionId': election.id,
                                  'electionName': election.name,
                                  'currentPhase': election.phase,
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.createElection);
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
