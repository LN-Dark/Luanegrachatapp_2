import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp2/Pages/HomePage.dart';
import 'package:chatapp2/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  LoginScreen({Key key }) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences _preferences;
  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser _firebaseUser;

  @override
  void intState(){
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async{
    this.setState(() {
      isLoggedIn = true;
    });
    _preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if(isLoggedIn){
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(firebaseUserID: _preferences.getString("id"))));
    }
    this.setState(() {
      isLoading = false;
    });

  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.lightBlueAccent, Colors.purpleAccent]
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Lua Negra Chat App",
              style: TextStyle(
                fontSize: 82.0, color: Colors.white, fontFamily: "Signatra"
              ),
            ),
            GestureDetector(
              onTap: controlSignIn,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 270.0,
                      height: 65.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/google_signin_button.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isLoading ? circularProgress() : Container(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Future<Null> controlSignIn() async{
    _preferences = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication authentication = await googleSignInAccount.authentication;
    final AuthCredential credential  = GoogleAuthProvider.getCredential(idToken: authentication.idToken, accessToken: authentication.accessToken);
    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
    if(firebaseUser != null){
      final QuerySnapshot resultQuery = await Firestore.instance.collection("users").where("id", isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documentSnapshot  = resultQuery.documents;
      if(documentSnapshot.length == 0){
        Firestore.instance.collection("users").document(firebaseUser.uid).setData(
            {
              "nickname" : firebaseUser.displayName,
              "photoUrl" : firebaseUser.photoUrl,
              "id" : firebaseUser.uid,
              "aboutMe" : "Sobre Mim",
              "createdAt" : DateTime.now().millisecondsSinceEpoch.toString(),
              "chattingWith" : null,
            });
        _firebaseUser = firebaseUser;
        await _preferences.setString("id", _firebaseUser.uid);
        await _preferences.setString("nickname", _firebaseUser.displayName);
        await _preferences.setString("photoUrl", _firebaseUser.photoUrl);
      }else{
        await _preferences.setString("id", documentSnapshot[0]["id"]);
        await _preferences.setString("nickname", documentSnapshot[0]["nickname"]);
        await _preferences.setString("photoUrl", documentSnapshot[0]["photoUrl"]);
        await _preferences.setString("aboutMe", documentSnapshot[0]["aboutMe"]);
      }
      Fluttertoast.showToast(msg: "Logged in");
      this.setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(firebaseUserID: firebaseUser.uid)));
    }else{
      Fluttertoast.showToast(msg: "Tenta outra vez");
      this.setState(() {
        isLoading = false;
      });

    }
  }

}
