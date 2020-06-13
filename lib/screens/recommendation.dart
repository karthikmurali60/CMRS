import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecommendationScreen extends StatefulWidget {
  static const String id = 'recommendation_screen';
  final String documentIDs;

  RecommendationScreen({Key key, @required this.documentIDs}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with SingleTickerProviderStateMixin {


  List<String> docIDs = [];
  List<String> docNames = [];
  String location = "";
  String phone = "";
  bool showSpinner = false;
  void initialise() async {
   // String names1;
    docIDs = widget.documentIDs.split(",");

    /*for (int i = 0; i < docIDs.length; i++) {
      print(docIDs[i]);
    }
    for (int i = 0; i < docIDs.length; i++) {
      final String uid = docIDs[i];
      firestore.collection('hospitals').document('AHVtBT3FSKY7uYWRipBmsKHyFuj1')
      // ignore: non_constant_identifier_names
          .get().then((DocumentSnapshot) =>
          names1 = DocumentSnapshot.data['name']);
      print(names1);*/

    final String _collection = 'hospitals';
    final _fireStore = Firestore.instance;

    getData() async {
      return await _fireStore.collection(_collection).getDocuments();
    }

    getData().then((val){
      if(val.documents.length > 0){
        //print(val.documents[0].data["name"]);
        for (int i = 0; i < docIDs.length; i++) {
          for (int j = 0; j < val.documents.length; j++ ){
            if(docIDs[i].compareTo(val.documents[j].documentID) == 0){
              docNames.add(val.documents[j].data['name']);
            }
          }
        }
        }
    });
  }


  @override
  void initState() {
    super.initState();
    _getThingsOnStartup().then((value){
      print("Done");
    });
  }
  Future _getThingsOnStartup() async {
    await Future.delayed(Duration(seconds: 2));
    initialise();
  }


    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("List of Hospitals"),
          ),
          body: Center(
            child: Column(
              children: docNames.map((String data) {
                return RaisedButton(
                  child: Text(data),
                  onPressed: () {
                    print(data);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }




