 
 import 'package:flutter/widgets.dart';
import 'package:voting_system/repository/election_repository.dart';

class ElectionViewModel with ChangeNotifier{

 final ElectionRepository _repo = ElectionRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;



 Future<void> init()async{
  _isLoading = true;
  notifyListeners();
  await _repo.init();
  _isLoading = false;
  notifyListeners();
 }
  Future<void> createElection(String name, String description, int start,  int end)async{
    _isLoading= true;
    notifyListeners();
    try{
      await  _repo.createElection(name, description, start, end);
    } catch (e){
      debugPrint('Error creating election: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
   }
}