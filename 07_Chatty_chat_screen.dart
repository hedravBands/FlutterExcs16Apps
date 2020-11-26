import 'dart:io';

import 'package:chatty/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if(_currentUser != null) return _currentUser;
    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      //firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );
      final AuthResult authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      return user;

    } catch (error){
      print(error);
      return null;
    }

  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    //block unAuth users
    if(user == null){
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Not logged in. C'mon... try again."),
            backgroundColor: Colors.red,
          ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if (imgFile != null){
      //StorageUploadTask task = FirebaseStorage.instance.ref().child("pasta1").child("pasta2")...
      StorageUploadTask task = FirebaseStorage.instance.ref().child(user.uid +
        DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot =  await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      //print(url);
      data['imgUrl'] = url;
      setState(() {
        _isLoading = false;
      });
    }
  //bug when pressing enter on keyboard, text comes as "" and it is not null
    // solved by blocking onSubmitt calling sendMessage if text == ""
    if (text != null) data['text'] = text;

    //push to DB
    Firestore.instance.collection("message").add(data);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null ? "Welcome, ${_currentUser.displayName}" : "Chatty"
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null ? IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: (){
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text("See you later, Alligator"),
                    ));

              }) : Text("")
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('message').orderBy('time').snapshots(),
            builder: (context, snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: CircularProgressIndicator()
                  );
                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data.documents.reversed.toList();

                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context,index){
                      return ChatMessage(documents[index].data,
                        // checmessages are from _current user \\\?///  <<<< see the ? to avoid null.uid
                        documents[index].data['uid']==_currentUser?.uid);
                    },
                  );
              }
            },
           ),
          ),
         _isLoading ? LinearProgressIndicator() : Container(),
         TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
