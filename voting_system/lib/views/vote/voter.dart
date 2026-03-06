import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/viewsModel/vote_view_model.dart';

class VoterScreen extends StatefulWidget {
    final int electionId;
  final String electionName;
  const VoterScreen({super.key, required this.electionId, required this.electionName});

  @override
  State<VoterScreen> createState() => _VoterScreenState();
}

class _VoterScreenState extends State<VoterScreen> with AutomaticKeepAliveClientMixin {
    int? selectedCandidate;
    List<Map<String, dynamic>> _candidates = [];
    bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState(){
    super.initState();
    _loadCandidates();
  }
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
      Navigator.pushNamed(
        context,
        RoutesName.result,
        arguments: {'electionId': widget.electionId},
      );
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Vote failed: ${e.toString()}'),));


    }

  }

  Future<void> _loadCandidates() async {
  try {
    final vm = Provider.of<VoteViewModel>(context, listen: false);

    final candidates = await vm.getCandidates(widget.electionId);
    print("Candidates fetched: $candidates");
    setState(() {
      _candidates = candidates;
      _loading = false;
      // Restore selected candidate if it exists in the new candidate list
      if (selectedCandidate != null) {
        bool candidateExists = _candidates.any((candidate) => candidate['id'] == selectedCandidate);
        if (!candidateExists) {
          selectedCandidate = null; // Clear selection if candidate no longer exists
        }
      }
    });

  } catch (e) {
    print("Error loading candidates: $e");
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final vm = Provider.of<VoteViewModel>(context);
    return  Scaffold(
     appBar: AppBar(title: Text(widget.electionName),
     
     ),
  // body: Column(
  //   children: [
  //     RadioListTile<int>(
  //       title: Text('Farhan khan'),
  //       value: 0,
  //       groupValue: selectedCandidate,
  //       onChanged: (val) => setState(() => selectedCandidate = val),
  //       ),
  //                 SizedBox(height: 20),
  //                 RadioListTile<int>(
  //           title: Text('Hamid wali'),
  //           value: 1,
  //           groupValue: selectedCandidate,
  //           onChanged: (val) => setState(() => selectedCandidate = val),
  //         ),
  //         SizedBox(height: 20),
  //                   vm.isLoading
  //             ? CircularProgressIndicator()
  //             : ElevatedButton(onPressed: _vote, child: Text('Vote')),

  //   ],
  // ),
  body: _loading
    ? Center(child: CircularProgressIndicator())
      : _candidates.isEmpty
        ? Center(child: Text("No candidates available"))
    : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _candidates.length,
              itemBuilder: (context, index) {
                final candidate = _candidates[index];

                return RadioListTile<int>(
                  title: Text(candidate['name']),
                  value: candidate['id'].toInt(),
                  groupValue: selectedCandidate,
                  onChanged: (val) =>
                      setState(() => selectedCandidate = val),
                );
              },
            ),
          ),
          vm.isLoading
              ? CircularProgressIndicator()
              : Padding(
                padding:  const EdgeInsets.all(16.0),
                child: ElevatedButton(
                    onPressed: _vote,
                    child: Text('Vote'),
                  ),
              ),
              ElevatedButton(
  onPressed: (){
    Navigator.pushNamed(
      context, 
      RoutesName.result,
      arguments: {'electionId': widget.electionId},
    );
  },
  child: Text('See Result'),
),
        ],
      ),
    );
  }
}