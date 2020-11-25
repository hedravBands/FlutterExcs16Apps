import 'dart:io';

import 'package:chatty/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void _sendMessage({String text, File imgFile}) async {

    Map<String, dynamic> data = {};

    if (text != null) data['text'] = text;

    if(imgFile != null){
      //StorageUploadTask task = FirebaseStorage.instance.ref().child("pasta1").child("pasta2")...
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);
      StorageTaskSnapshot taskSnapshot =  await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      //print(url);
      data['imgUrl'] = url;
    }

    //push to DB
    Firestore.instance.collection("message").add(data);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatty"),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("message").snapshots(),
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
                      return ListTile(
                        title: Text(documents[index].data['text']),
                      );
                    },
                  );
              }
            },
           ),
          ),
         TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
