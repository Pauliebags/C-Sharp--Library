import 'package:country_codes/country_codes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Questions/ui/shared/color.dart';
import '../settings/settings.dart';
import '../signin/sign_in_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
bool checkPolicy =false;
bool _passwordInVisible = true; 
bool _confirmpasswordInVisible = true; 
final formkey = GlobalKey<FormState>();
Position? gp;
var cl;
dynamic placemarks;
late Locale? deviceLocale;
TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();
TextEditingController confirmpassword = TextEditingController();
TextEditingController emailaddress = TextEditingController();
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth user = FirebaseAuth.instance;
RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
bool validatePassword(String pass) {
  String _password = pass.trim();
  if (pass_valid.hasMatch(_password)) {
    return true;
  } else {
    return false;
  }
}
Future<Position> getPostion() async {
  return await Geolocator.getCurrentPosition().then((value) => value);
}
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}
class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          GoRouter.of(context).go('/signin');
        },),
        centerTitle: true,
        backgroundColor: AppColor.pripmaryColor,
        title: Text('Create New Account'),
        actions: [
           ValueListenableBuilder<bool>(
              valueListenable: settingsController.muted,
              builder: (context, muted, child) {
                return IconButton(
                  onPressed: () => settingsController.toggleMuted(),
                  icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
                );
              },
            ),
        ],
      ),
      backgroundColor: AppColor.pripmaryColor,
      body: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Image.asset('assets/images/geotrivia.jpg',
                  width: 150.0, height: 150.0),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter your Email';
                        }
                      },
                      controller: username,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter your password';
                        } else {
                          bool result = validatePassword(value);
                          if (result) {
                            return null;
                          } else {
                            return " Password should contain Capital, small letter & Number & Special";
                          }
                        }
                      },
                      controller: password,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordInVisible
                                ? Icons.visibility_off
                                : Icons
                                    .visibility, 
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordInVisible =
                                  !_passwordInVisible; 
                            });
                          },
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _passwordInVisible,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter password';
                        }
                        if (value != password.text) {
                          return 'Password does not match';
                        }
                      },
                      controller: confirmpassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmpasswordInVisible
                                ? Icons.visibility_off
                                : Icons
                                    .visibility, 
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmpasswordInVisible =
                                  !_confirmpasswordInVisible; 
                            });
                          },
                        ),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _confirmpasswordInVisible,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter your email address';
                        }
                      },
                      controller: emailaddress,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ),
              ),
              CheckboxListTile(
                value: checkPolicy,
                onChanged: (value) {
                  setState((){
                    checkPolicy=value!;
                  });
                },
                title: Text('GDPR policy accept'),
              ),
              MaterialButton(
                onPressed: () async {
                  bool isLocationServiceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  LocationPermission per;
                  if (isLocationServiceEnabled == false) {
                    Fluttertoast.showToast(
                        msg: "Services Not Enabled",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                  per = await Geolocator.checkPermission();
                  if (per == LocationPermission.denied) {
                    per = await Geolocator.requestPermission();
                  }
                  gp = await getPostion();
                  placemarks = await placemarkFromCoordinates(
                      gp!.latitude, gp!.longitude);
                  await CountryCodes
                      .init(); 
                  deviceLocale = CountryCodes.getDeviceLocale();
                  print(deviceLocale!.countryCode); 
                },
                child: Text('Get Your Location'),
                color: Colors.greenAccent,
              ),
              placemarks == null
                  ? Container()
                  : Text(
                      placemarks[0].country,
                      style: TextStyle(color: Colors.white),
                    ),
              MaterialButton(
                onPressed: () async {
                  if (!formkey.currentState!.validate()) {
                    return;
                  }
                  if(checkPolicy==false){
                    Fluttertoast.showToast(
                        msg: "accept the policy",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.black,
                        fontSize: 16.0);
                  }
                  formkey.currentState!.save();
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailaddress.text,
                        password: confirmpassword.text).then((value) =>Fluttertoast.showToast(
                        msg:"Account Successfully Created",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.black,
                        fontSize: 16.0) );
                    firestore
                        .collection('Users')
                        .doc(user.currentUser!.uid)
                        .set({
                      'UserName': username.text,
                      'UserEmail': emailaddress.text,
                      'UserCountry': placemarks[0].country,
                      'CountryCode': deviceLocale!.countryCode,
                      'Point':0,
                    });
                    GoRouter.of(context).go('/');
                  } on FirebaseException catch (e) {
                    if (e.code == 'weak-password') {
                      Fluttertoast.showToast(
                          msg: "weak password",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    } else if (e.code == 'email-already-in-use') {
                      Fluttertoast.showToast(
                          msg: "email already in use",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: "An unknown error occured",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Text('Create New Account'),
                color: Colors.greenAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
