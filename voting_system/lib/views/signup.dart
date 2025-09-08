import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/utils/utils.dart';
import 'package:voting_system/viewsModel/login_view_model.dart';
import 'package:voting_system/widgets/round_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
      appBar: AppBar(
        title: Text('SignUp'),
        centerTitle: true,
      ),
      body:  SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  focusNode: emailFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.alternate_email),
            
                  ),
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
                   builder: (context ,value ,child){
                   return   TextFormField(
                  controller: _passwordController,
                  obscureText: _obsecurePassword.value,
                  obscuringCharacter: '*',
                  focusNode: passwordFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_open_rounded),
                    suffixIcon: InkWell(
                      onTap: (){
                        _obsecurePassword.value = !_obsecurePassword.value;
                      },
                      child: Icon(
                       _obsecurePassword.value ? Icons.visibility_off_outlined : Icons.visibility
                        )),
            
                  ),
                  validator: (value){
                   if(value == null || value.isEmpty){
                    return 'Enter your Password';
                   }
                   if(value.length < 6){
                    return 'Password must be at least 6 characters';
                   }
                   return null;
                  },
                );
                   }
                   ),
                   SizedBox(height: height * .085,),
                   Consumer<LoginViewModel>(builder: (context, provider , child){
                    return     RoundButton(
                  onPress: (){
                    Navigator.pushNamed(context, RoutesName.login);
                    if(_formKey.currentState!.validate()){
        final loginViewModel = Provider.of<LoginViewModel>(context,listen: false);
        loginViewModel.login(
          email:  _emailController.text.trim(),
          password: _passwordController.text.trim(),
          context: context
        );
                print("Email: ${_emailController.text}");
                      print("Password: ${_passwordController.text}");
                    }
                  },
                   title: 'Sign Up',
                   loading: provider.loading,
                   );
                   }),
                    SizedBox(height: height * .085,),

                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Don't have an account"),
                      TextButton(onPressed: (){
              Navigator.pushNamed(context, RoutesName.login);
                      },
                       child: Text("Login", style: TextStyle(color: Colors.green),)
                       )
                    ],
                   )
              
                
              ],
            ),
          ),
        )
        ),
    );
  }
}