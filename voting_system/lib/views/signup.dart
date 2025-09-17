import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_system/repository/auth_repository.dart';
import 'package:voting_system/utils/routes/routes_name.dart';
import 'package:voting_system/utils/utils.dart';
import 'package:voting_system/viewsModel/login_view_model.dart';
import 'package:voting_system/widgets/reusable_textfield.dart';
import 'package:voting_system/widgets/round_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
     ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _cnicController = TextEditingController();
final _phoneController = TextEditingController();
final _dobController = TextEditingController();
final _addressController = TextEditingController();
final _confirmPasswordController = TextEditingController();
     final _formKey = GlobalKey<FormState>();
     FocusNode nameFocusNode = FocusNode();
    FocusNode emailFocusNode = FocusNode();
    FocusNode passwordFocusNode = FocusNode();
    FocusNode rePasswordFocusNode = FocusNode();
    FocusNode phoneFocusNode = FocusNode();
    FocusNode dobFocusNode = FocusNode();
    FocusNode addressFocusNode = FocusNode();
    FocusNode cnicFocusNode = FocusNode();

     AuthRepository auth = AuthRepository();
    @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    rePasswordFocusNode.dispose();
    cnicFocusNode.dispose();
    addressFocusNode.dispose();
    dobFocusNode.dispose();
    phoneFocusNode.dispose();
    _obsecurePassword.dispose();


    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('SignUp'),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  SizedBox(height: 25),
                  Text("Create Your Account", style: TextStyle(
                  fontSize: 32, color: Colors.black)),
                  Text("Register to participate in secure and transparent\n                            digital voting.", style: TextStyle(
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
                          controller: _nameController,
                           hintText: 'Enter your name', 
                           labelText: 'Name',
                           focusNode: nameFocusNode,
                                                     validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter your Name';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, nameFocusNode, emailFocusNode);
                          },
                           ),
                        SizedBox(height: 15,),
                                           
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
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, passwordFocusNode, rePasswordFocusNode);
                                                         
                                },
                                );
                               }
                               ),
                            
                            
                           
                           
                           SizedBox(height: 15,),

                          ValueListenableBuilder(
                              valueListenable: _obsecurePassword,
                               builder: (context, value, child){
                                return ReusableTextFormField(
                            controller: _confirmPasswordController, 
                            hintText: "Enter your Re-password", 
                            labelText: "Confirm Password",
                            focusNode: rePasswordFocusNode,
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
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, rePasswordFocusNode, cnicFocusNode);
                                                         
                                },
                                );
                               }
                               ),
                            
                   
                            
                         SizedBox(height: 15,),
                          ReusableTextFormField(
                            controller: _cnicController, 
                            hintText: "Enter your CNIC", 
                            labelText: "CNIC",
                            focusNode: cnicFocusNode,
                                                      validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter your CNIC';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, cnicFocusNode, phoneFocusNode);
                          },
                            
                            ),
                          SizedBox(height: 15,),
                          ReusableTextFormField(
                            controller: _phoneController, 
                            hintText: "Enter your phone number", 
                            labelText: "Phone",
                            focusNode: phoneFocusNode,
                                                      validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter your phone no';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, phoneFocusNode, dobFocusNode);
                          },
                            ),
                          SizedBox(height: 15,),
                          ReusableTextFormField(
                            controller: _dobController, 
                            hintText: "Enter your DOB", 
                            labelText: "DOB",
                            focusNode: dobFocusNode,
                                                      validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter your DOB';
                            }

                            return null;
                          },
                          onFieldSubmitted: (value){
                           Utils.fieldFocusChange(context, dobFocusNode, addressFocusNode);
                          },
                            ),
                          SizedBox(height: 15,),
                          ReusableTextFormField(
                            controller: _addressController, 
                            hintText: "Enter your address", 
                            labelText: "Address",
                            focusNode: addressFocusNode,
                             validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter your Address';
                            }

                            return null;
                          },                    
                            ),

                         SizedBox(height: 15,),
                           SizedBox(height: height * .085,),
                           Consumer<LoginViewModel>(builder: (context, provider , child){
                            return     RoundButton(
                          onPress: (){
                            if(_formKey.currentState!.validate()){
                           
                final loginViewModel = Provider.of<LoginViewModel>(context,listen: false);
                loginViewModel.register(
                 email: _emailController.text.trim(),
                 password: _passwordController.text.trim(),
                 context: context,
                 name: _nameController.text.trim(),
                 cnic: _cnicController.text.trim(),
                 phone: _phoneController.text.trim(),
                 dob: _dobController.text.trim(),
                 address: _addressController.text.trim(),
                );
                 Navigator.pushNamed(context, RoutesName.login);

                            }else{
                              print('Form is invalid');
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
                              Text("Already have an account", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black26
                              ),),
                              TextButton(onPressed: (){
                      Navigator.pushNamed(context, RoutesName.login);
                              },
                               child: Text("Login", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),)
                               )
                            ],
                           )
                      
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          ),]
      ),
    );
  }
}