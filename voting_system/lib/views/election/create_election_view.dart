import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/viewsModel/election_view_model.dart';
import 'package:voting_system/widgets/reusable_textfield.dart';
import 'package:voting_system/widgets/round_button.dart';

class CreateElectionScreen extends StatefulWidget {
  const CreateElectionScreen({super.key});

  @override
  State<CreateElectionScreen> createState() => _CreateElectionScreenState();
}

class _CreateElectionScreenState extends State<CreateElectionScreen> {
    final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
DateTime? _startDate;
DateTime? _endDate;


@override
void initState() {
  super.initState();
  Provider.of<ElectionViewModel>(context, listen: false).init();
}

void _submitElection()async{
  final name = _nameController.text.trim();
  final desc = _descController.text.trim();
      if (name.isEmpty || desc.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
  final start = _startDate!.microsecondsSinceEpoch ~/ 1000;
  final end = _endDate!.microsecondsSinceEpoch ~/ 1000;
try {
      await Provider.of<ElectionViewModel>(context, listen: false)
          .createElection(name, desc, start, end);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Election Created Successfully')),
      );

      _nameController.clear();
      _descController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create election')),
      );
    }
}

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ElectionViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text('Admin panel - create election'),
      ),

     body: Padding(
           padding: EdgeInsets.all(16.0),
           child: Column(
            children: [
              ReusableTextFormField(
                controller: _nameController, 
                hintText: 'Enter Election Name', 
                labelText: 'Election Name',
                ),
                ReusableTextFormField(
                  controller: _descController, 
                  hintText: 'Enter Description', 
                  labelText: 'Description'
                  ),

                  SizedBox(height: 10,),
                  RoundButton(
                    onPress: ()async{
                      final picked = await showDatePicker(
                        context: context, 
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(), 
                        lastDate: DateTime(2100)
                        );
                if (picked != null) setState(() => _startDate = picked);
                    },
                     title: _startDate == null ? 'Pick Start Date' : 
                     'Start: ${_startDate!.toLocal().toString().split('')[0]}'
                     ),

                     RoundButton(onPress: ()async{
                        final picked = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now().add(Duration(days: 1)),
                          firstDate: DateTime.now(), 
                          lastDate: DateTime(2100));
                if (picked != null) setState(() => _endDate = picked);
                     }, 
                     title: _endDate == null
                  ? 'Pick End Date'
                  : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}',
                     ),
                     SizedBox(height: 10,),
                    vm.isLoading ? CircularProgressIndicator():
                     RoundButton(onPress: (){
                      _submitElection();
                     },
                      title: 'Create Election'
                      
                      )
            ],
           ),
              ),

    );
  }
}