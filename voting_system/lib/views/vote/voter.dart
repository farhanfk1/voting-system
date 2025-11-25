import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';

class VoterScreen extends StatefulWidget {
    final BigInt electionId;
  final String electionName;
  const VoterScreen({super.key, required this.electionId, required this.electionName});

  @override
  State<VoterScreen> createState() => _VoterScreenState();
}

class _VoterScreenState extends State<VoterScreen> {
    int? selectedCandidate;

  void _vote()async{
    if (selectedCandidate == null){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select a candidate')));
      return;
    }
    try{
      await Provider.of<VoteViewModel>(context, listen: false)
      .castVote(widget.electionId, selectedCandidate!);
           ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote submitted!')),
      );
      Navigator.pushNamed(context, RoutesName.result);
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vote failed')));


    }

  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VoteViewModel>(context);
    return  Scaffold(
     appBar: AppBar(title: Text(widget.electionName)),
  body: Column(
    children: [
      RadioListTile<int>(
        title: Text('Candidate 1'),
        value: 0,
        groupValue: selectedCandidate,
        onChanged: (val) => setState(() => selectedCandidate = val),
        ),
                  SizedBox(height: 20),
                  RadioListTile<int>(
            title: Text('Candidate 2'),
            value: 1,
            groupValue: selectedCandidate,
            onChanged: (val) => setState(() => selectedCandidate = val),
          ),
          SizedBox(height: 20),
                    vm.isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: _vote, child: Text('Vote')),

    ],
  ),
    );
  }
}