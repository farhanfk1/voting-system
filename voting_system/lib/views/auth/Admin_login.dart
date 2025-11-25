import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/utils/utils.dart';
import 'package:voting_system/viewsModel/admin_auth_view_model.dart';
import 'package:voting_system/widgets/reusable_textfield.dart';
import 'package:voting_system/widgets/round_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
       ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
       final TextEditingController _emailController = TextEditingController();
       final TextEditingController _passwordController = TextEditingController();
       final _formKey = GlobalKey<FormState>();
     FocusNode emailFocusNode = FocusNode();
    FocusNode passwordFocusNode = FocusNode();
  void _login()async{
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
final viewModel = Provider.of<AdminAuthViewModel>(context, listen: false);
final success = await viewModel.adminLogin(email, password);
if (success){
 Navigator.pushNamed(context, RoutesName.createElection);
}else{
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid admin credentials')));
}

  }
  @override
  void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _obsecurePassword.dispose();
      emailFocusNode.dispose();
      passwordFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
      final viewModel = Provider.of<AdminAuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
   body: Stack(
     children:[ 
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
          ) 
        ),
      ),
      
         Positioned(
          top: -60,
         left: -40,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          )
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            )
            ),
      
      Column(
       mainAxisSize: MainAxisSize.min,
       children: [
                 Text("Welcome Back!", style: TextStyle(
                 fontSize: 32, color: Colors.black)),
                 Text("Login to create election", 
                 style: TextStyle(
                 fontSize: 16, color: Colors.white38)),
                 SizedBox(height: 50),
           
       Form(
         key: _formKey,
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 24.0),
           child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               ReusableTextFormField(
                        controller: _emailController, 
                        hintText: "Enter Email", 
                        labelText: 'Email',
                        focusNode: emailFocusNode,
                        prefixIcon: Icon(Icons.email),
                           validator: (value){
                           if(value == null || value.isEmpty){
                             return 'Please enter your email';
                           }
                           if(!value.contains('@')){
                             return 'Enter a valid Email';
                           }
                           return null;
                         },
                         onFieldSubmitted: (value){
                          Utils.fieldFocusChange(context, emailFocusNode, passwordFocusNode);
                         },                  
                 ),
                           SizedBox(height: 20,),
                         ValueListenableBuilder(
                             valueListenable: _obsecurePassword,
                              builder: (context, value, child){
                               return ReusableTextFormField(
                           controller: _passwordController, 
                           hintText: "Enter your password", 
                           labelText: "Password",
                           focusNode: passwordFocusNode,
                           obscureText: value,
                           prefixIcon: Icon(Icons.lock),
                           suffixIcon:  Icon(
                            value ? 
                            Icons.visibility_off_outlined :
                            Icons.visibility_outlined
                               ),
                               onpress: (){
                             _obsecurePassword.value = !value;
                               },
                               
                               validator: (value){
                           if(value == null || value.isEmpty){
                             return 'Please enter your pssword';
                           } if(value.length < 6){
                            return 'Your password is less than 6 digit';
                           }
                           return null;
                         },
                               );
                              }
                              ),
      
           SizedBox(height: 50,),
           viewModel.isLoading ?
           const CircularProgressIndicator() :
           RoundButton(onPress: (){
             _login(
              
             );
           },
            title: 'Admin Login')
             ],
           ),
         ),
       ),
      
      ],),]
   ),
    );
  }
}