 class ElectionModel {
   String id;
   String name;
   String description;
   DateTime startDate;
   DateTime endDate;

   ElectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate
    });

    Map<String, dynamic> toJson()=>{
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate':  endDate,
    };

}