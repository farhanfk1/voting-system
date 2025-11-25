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
    // Load elections only once
 WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<VoteViewModel>(context, listen: false).init();
  });  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Available Elections",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: Container(
        decoration: BoxDecoration(
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
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.elections.length,
                    itemBuilder: (context, index) {
                      final election = vm.elections[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            election['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            election['description'],
                            style: TextStyle(fontSize: 15),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.deepPurple),
                          onTap: () {
                            Navigator.pushNamed(context, RoutesName.voter);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
