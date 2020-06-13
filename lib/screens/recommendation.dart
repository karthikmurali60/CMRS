import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RecommendationScreen extends StatefulWidget {
  static const String id = 'recommendation_screen';
  final String documentIDs;
  RecommendationScreen({Key key, @required this.documentIDs}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {

  List<String> names = [];
  List<String> docNames = [];
  String location = "";
  String phone = "";
  bool showSpinner = false;
  List<RaisedButton> buttonsList = new List<RaisedButton>();

  void initialize() async {
    names = widget.documentIDs.split(",");
    print(names[0]);
  }

  @override
  void initState() {
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
    super.initState();
    initialize();
  }

  void Alert1() {
    Alert(
      type: AlertType.success
    ).show();
  }

  List<Widget> _buildButtonsWithNames() {
    for (int i = 0; i < names.length; i++) {
      buttonsList
          .add(new RaisedButton(onPressed: Alert1, child: Text(names[i])));
    }
    return buttonsList;
  }

  @override
   /*Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("List of Hospitals"),
          ),
          body: Center(
            child: Container(
                child: RaisedButton(
                  child: Text("Get Hospitals"),
                  onPressed: () {
                    getName();
                  },
                ),
            ),
          ),
        ),
      );
    }*/
  Widget build(BuildContext context) {
    return Scaffold(body: Wrap(children: _buildButtonsWithNames()));
  }
}

