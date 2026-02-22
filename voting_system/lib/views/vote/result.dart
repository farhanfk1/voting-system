import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';

class ResultScreen extends StatefulWidget {
    final BigInt electionId;

  const ResultScreen({super.key, required this.electionId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
   Map<String, dynamic>? result;
   bool _loading = true;

   @override
   void initState() {
     super.initState();
     _fetchResult();
   }
   void _fetchResult()async{
    final vm = Provider.of<VoteViewModel>(context, listen: false);
    final res = await vm.getResult(widget.electionId);
   setState(() {
     result = res;
     _loading = false;
   });

   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text('Election Result')),
       body: _loading ? Center(child: CircularProgressIndicator(),) :
       ListView.builder(
        itemCount: result!['ids'].length,
        itemBuilder: (context, index){
          final votesList = result!['votes'] as List<dynamic>;
        final votes = votesList[index] as BigInt; // access each element
                     return ListTile(
                  title: Text(result!['names'][index]),
                  trailing: Text((result!['votes'][index] as BigInt).toString(),
              ),
          );

       })
    );
  }
}