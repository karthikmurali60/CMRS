import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMaps {

  GoogleMaps._();
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}


class RecommendationScreen extends StatefulWidget {
  static const String id = 'recommendation_screen';
  final String documentIDs;
  RecommendationScreen({Key key, @required this.documentIDs}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {

  List<String> names = [];
  List<String> locations = [];
  List<String> phones = [];
  String n1 = "";
  String l1 = "";
  String p1 = "";
  String phone = "";
  bool showSpinner = false;
  List<Container> buttonsList = new List<Container>();
  QuerySnapshot querySnapshotNew;
  final String _collection = 'hospitals';
  final _fireStore = Firestore.instance;
  Position position;
  GeoPoint myLocation = GeoPoint(56,-122);
  GeoPoint minDistanceLocation ;


  void initialize() async {
    n1 = widget.documentIDs.split(";")[0];
    l1 = widget.documentIDs.split(";")[1];
    p1 = widget.documentIDs.split(";")[2];
    names = n1.split(",");
    locations = l1.split(" ");
    phones = p1.split(",");
  }

  void _launchCaller(int number) async{
    var url = "tel:${number.toString()}";
    if(await canLaunch(url)){
      await launch(url);
    }
    else{
      throw 'Could not place call';
    }
  }

  getData() async {
    return await _fireStore.collection(_collection).getDocuments();
  }

  getLocation(int i) async {
    position = await Geolocator().getLastKnownPosition(
        desiredAccuracy: LocationAccuracy.high);
    myLocation = GeoPoint(position.latitude, position.longitude);
    EdgeAlert.show(context, title: 'Your location', description: '$position', gravity: EdgeAlert.BOTTOM);
    minDistanceLocation = GeoPoint(double.parse(locations[i].split(",")[0]), double.parse(locations[i].split(",")[1]));
    GoogleMaps.openMap(minDistanceLocation.latitude,minDistanceLocation.longitude);
  }

  call(int i) async {
    _launchCaller(int.parse(phones[i]));
  }

  @override
  void initState() {
    super.initState();
    initialize();
    getData().then((val) {
      setState(() {
        querySnapshotNew = val;
      });
    });
  }

  List<Container> _buildButtonsWithNames() {
    buttonsList.clear();
    for (int i = 0; i < names.length; i++) {
      buttonsList.add(
        Container(
            margin: EdgeInsets.all(15.0),
            decoration: BoxDecoration(

              color: Colors.teal,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: <Widget>[
                Container(

                  padding: EdgeInsets.all(10),
                  child: Text(
                    names[i],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    RaisedButton(
                      child: Text(
                        "Location",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: (){
                        getLocation(i);
                      } ,
                    ),
                    RaisedButton(
                      child: Text(
                        "Call",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: (){
                        call(i);
                      },
                    ),
                  ],
                ),
              ],
            )),
      );

    }
    return buttonsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Nearest Hospitals'),
      ),
      body: ListView(children: _buildButtonsWithNames()),
      backgroundColor: Colors.white,
    );
  }
}