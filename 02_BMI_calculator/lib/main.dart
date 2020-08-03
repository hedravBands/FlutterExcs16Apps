import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  String _result = "Insert Values";

  void _resetFields(){
    weightController.text = "";
    heightController.text = "";

    setState(() {
      _result = "Inform Values";
    });

  }

  void _calculate(){

    setState(() {
      double weight = double.parse(weightController.text);
      double height = double.parse(heightController.text) / 100; //unit in m
      double bmi = weight / (height*height);
      print(bmi);
      if(bmi < 18.6) {
        _result = "Under weight (BMI: ${bmi.toStringAsPrecision(3)})";
      } else if(bmi >= 18.6 && bmi < 24.9){
        _result = "Ideal weight (BMI: ${bmi.toStringAsPrecision(3)})";
      } else if(bmi >= 25.0 && bmi < 29.9){
        _result = "Above weight (BMI: ${bmi.toStringAsPrecision(3)})";
      } else {
        _result = "Obesity detected (BMI: ${bmi.toStringAsPrecision(3)})";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("BMI Calculator"),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetFields,
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.person_outline, size: 120.0, color: Colors.green),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Weight (Kg)",
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 25.0),
                  controller: weightController,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Height (cm)",
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 25.0),
                  controller: heightController,
                ),
                Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                      height: 50.0,
                      child:
                      RaisedButton(
                        onPressed: _calculate,
                        color: Colors.green,
                        child: Text(
                          "Calculate",
                          style: TextStyle(color: Colors.white, fontSize: 25.0),
                        ),
                      )
                  ),
                ),
                Text("$_result", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 25.0),)
              ],
            )),
    );
  }
}
