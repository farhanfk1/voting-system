import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/utils/utils.dart';
import 'package:voting_system/viewsModel/login_view_model.dart';
import 'package:voting_system/widgets/reusable_textfield.dart';
import 'package:voting_system/widgets/round_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
     ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
     
     final _emailController = TextEditingController();
     final _passwordController = TextEditingController();
     final _formKey = GlobalKey<FormState>();
    FocusNode emailFocusNode = FocusNode();
    FocusNode passwordFocusNode = FocusNode();

    @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    _obsecurePassword.dispose();

    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      //   centerTitle: true,
      // ),
      body:  Stack(
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
                color: Colors.white.withOpacity(0.1)
              ),
            )),
                    Positioned(
          bottom: -80,
          right: -50,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),

          SafeArea(
            child: Column(
              mainAxisSize:  MainAxisSize.min,
              children: [
                 SizedBox(height: 25),
                 Text("Welcome Back!", style: TextStyle(
                  fontSize: 32, color: Colors.black)),
                 Text("Login to access the voting system and cast\n                   your vote securely.", 
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
                          hintText: "Enter your Email", 
                          labelText: "Email",
                          focusNode: emailFocusNode,
                          prefixIcon: Icon(Icons.email),
                            validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter your email';
                            }
                            if(!value.contains('@')){
                              return 'Enter a valif Email';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, emailFocusNode, passwordFocusNode);
                          },
                          ),
                        
                         SizedBox(height: 15,),
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
                 
                           SizedBox(height: height * .085,),
                           Consumer<LoginViewModel>(builder: (context, provider , child){
                            return     RoundButton(
                                                         title: 'Login',
                           loading: provider.loading,
                          onPress: ()async{
                          if (_formKey.currentState!.validate()) {
                     await provider.login(
                     email: _emailController.text.trim(),
                     password: _passwordController.text.trim(),
                     context: context
                           );
                         }
            //                 if(_formKey.currentState!.validate()){
            //     final loginViewModel = Provider.of<LoginViewModel>(context,listen: false);
            // bool isSuccess = await   loginViewModel.login(

            //       email:  _emailController.text.trim(),
            //       password: _passwordController.text.trim(),
            //       context: context
            //     );
            //       if (isSuccess) {
            //         // WAIT 200 ms to allow loading to stop
            //    Future.delayed(Duration(milliseconds: 200), () {
            //    Navigator.pushReplacementNamed(context, RoutesName.home);
            //    });
            //    }
            //             //      if(isSuccess){
            //             //     Navigator.pushNamed(context, RoutesName.home);               
            //             // print("Email: ${_emailController.text}");
            //             //       print("Password: ${_passwordController.text}");
            //             //     }


            //                 }
                           },

                           );
                           }),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(onPressed: (){
                                  Navigator.pushNamed(context, RoutesName.forgot);
                                },
                                 child: Text("Forgot Password?", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),)
                                 ),
                              ),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Don't have an account", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black26
                              ),),
                              TextButton(onPressed: (){
                      Navigator.pushNamed(context, RoutesName.signup);
                              },
                               child: Text("SignUp", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),)
                               ),
                            ],
                           ),
                       TextButton(onPressed: (){
                      Navigator.pushNamed(context, RoutesName.admin);
                              },
                               child: Text("Admin", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),)
                               ),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),]
      ),
    );
  }
}