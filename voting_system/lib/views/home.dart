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
    Provider.of<VoteViewModel>(context, listen: false).init();
  }
  @override
  Widget build(BuildContext context) {
        final vm = Provider.of<VoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Elections')),
      body: vm.isLoading? Center(child: CircularProgressIndicator()) : 
      ListView.builder(
        itemCount: vm.elections.length,
        itemBuilder: (context, index){
        final election = vm.elections[index];
        return Card(
          child: ListTile(
            title:  Text(election['name']),
            subtitle: Text(election['description']),
            trailing: Icon(Icons.arrow_forward),
           onTap: (){
            Navigator.pushNamed(context, RoutesName.voter);
           },
          ),
        );
      })
    );
  }
}