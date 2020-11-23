import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


Future<void> main()  async {

  runApp(MyApp());
  // setData vs updateData
  // Firestore.instance.collection("msg").document().setData({"from":"Ana", "text":"Olah tudo bem"});
  // Firestore.instance.collection("msg").document("52hcV1Xp48AFDfIE3Xsx").updateData({"from":"Ana Amanda"});

  //  QuerySnapshot snapshot = await Firestore.instance.collection("msg").getDocuments();
  //  snapshot.documents.forEach((d){
  //    //print(d.data);
  //    //print(d.documentID);
  //    d.reference.updateData({"read": false});
  //  });

  //  Firestore.instance.collection("msg").document("52hcV1Xp48AFDfIE3Xsx").updateData({"read":true});
  //

  // DocumentSnapshot documentSnapshot = await Firestore.instance.collection("msg")
  //     .document("52hcV1Xp48AFDfIE3Xsx").get();
  // print(documentSnapshot.data);


  Firestore.instance.collection("msg").snapshots().listen((dado) {
    dado.documents.forEach((d) {
      print(d.data);
    });
  });



}





class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(),
    );
  }
}
