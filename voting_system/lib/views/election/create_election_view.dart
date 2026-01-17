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
    // Initialize the smart contract after the first frame
    Future.microtask(() =>
        Provider.of<ElectionViewModel>(context, listen: false).init());
  }

  void _submitElection() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    // Validate all fields are filled
    if (name.isEmpty || desc.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Validate date logic: end date must be after start date
    if (_endDate!.isBefore(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final start = _startDate!.millisecondsSinceEpoch ~/ 1000;
    final end = _endDate!.millisecondsSinceEpoch ~/ 1000;

    final vm = Provider.of<ElectionViewModel>(context, listen: false);

    // Check if contract is initialized
    if (!vm.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract is still initializing. Please wait...')),
      );
      return;
    }

    try {
      await vm.createElection(name, desc, start, end);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Election Created Successfully')),
      );

      _nameController.clear();
      _descController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
      });
    } catch (e) {
      String errorMessage = 'Failed to create election';
      if (e.toString().contains('Contract not initialized')) {
        errorMessage = 'Contract not initialized. Please try again.';
      } else if (e.toString().contains('End date must be after')) {
        errorMessage = 'End date must be after start date';
      } else if (e.toString().contains('transaction')) {
        errorMessage = 'Transaction failed. Please check your connection and try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ElectionViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Admin Panel - Create Election'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReusableTextFormField(
                controller: _nameController,
                hintText: 'Enter Election Name',
                labelText: 'Election Name',
              ),
              const SizedBox(height: 12),
              ReusableTextFormField(
                controller: _descController,
                hintText: 'Enter Description',
                labelText: 'Description',
              ),
              const SizedBox(height: 12),
              RoundButton(
                title: _startDate == null
                    ? 'Pick Start Date'
                    : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}',
                onPress: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              const SizedBox(height: 12),
              RoundButton(
                title: _endDate == null
                    ? 'Pick End Date'
                    : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}',
                onPress: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
              const SizedBox(height: 20),
              // Show initialization message if contract is not ready
              if (!vm.isInitialized)
                const Center(
                  child: Text(
                    "Initializing contract...",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              if (vm.isInitialized)
                RoundButton(
                  title: 'Create Election',
                  loading: vm.isLoading, // show spinner while transaction is processing
                  onPress: (){
                    if (!vm.isLoading) _submitElection();
                  } 
                  
                ),
            ],
          ),
        ),
      ),
    );
  }
}
