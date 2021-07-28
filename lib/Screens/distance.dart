import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../Models/url.dart';
import '../Models/curren_location.dart';

class Distance extends StatefulWidget {
  @override
  _DistanceState createState() => _DistanceState();
}

class _DistanceState extends State<Distance> {
  final _form = GlobalKey<FormState>();
  final _ctxKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _dataFetched = false;
  bool _isError = false;
  TextEditingController _latitude1 = new TextEditingController();
  TextEditingController _longitude1 = new TextEditingController();
  TextEditingController _latitude2 = new TextEditingController();
  TextEditingController _longitude2 = new TextEditingController();
  String _compAddress;
  String _error;
  String _lat1;
  String _long1;
  String _lat2;
  String _long2;
  String _distance;

  Future<void> getData() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_form.currentState.validate()) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
        _dataFetched = false;
        _isError = false;
      });

      // Fetching Response
      final response = await http.post(
        "${Url.url}${Url.distance}?lat1=${double.parse(_latitude1.text)}&long1=${double.parse(_longitude1.text)}&lat2=${double.parse(_latitude2.text)}&long2=${double.parse(_longitude2.text)}",
      );
      final data = json.decode(response.body);

      // Handling Error
      if (data["error"] == null) {
        _error = data["error"];
        _lat1 = double.parse(data["lat1"].toString()).toStringAsFixed(7);
        _long1 = double.parse(data["long1"].toString()).toStringAsFixed(7);
        _lat2 = double.parse(data["lat2"].toString()).toStringAsFixed(7);
        _long2 = double.parse(data["long2"].toString()).toStringAsFixed(7);
        _distance =
            double.parse(data["distance"].toString()).toStringAsFixed(2);
      } else {
        _isError = true;

        // Finding which error
        String msg = "Internal server error. Try later.";
        if (data["error"] == "TIMEOUT") msg = "Slow Internet. Try again.";
        if (data["error"] == "NOT_FOUND") msg = "Invalid coordinates.";

        // Showing Error
        _ctxKey.currentState.hideCurrentSnackBar();
        _ctxKey.currentState.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }

      setState(() {
        _isLoading = false;
        _dataFetched = true;
      });
    }
  }

  Future<void> getCurPos1() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _isLoading = true;
      _dataFetched = false;
    });
    Location loc = Location();
    final Position pos = await loc.getCurrentLocation();
    setState(() {
      _latitude1.value = TextEditingValue(text: pos.latitude.toString());
      _longitude1.value = TextEditingValue(text: pos.longitude.toString());
      _isLoading = false;
    });
  }

  Future<void> getCurPos2() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _isLoading = true;
      _dataFetched = false;
    });
    Location loc = Location();
    final Position pos = await loc.getCurrentLocation();
    setState(() {
      _latitude2.value = TextEditingValue(text: pos.latitude.toString());
      _longitude2.value = TextEditingValue(text: pos.longitude.toString());
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Row getRow(String title, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      );
    }

    return Scaffold(
      key: _ctxKey,
      appBar: AppBar(
        title: Text("Distance"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                "Enter latitudes & longitudes to find distance in kms.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Latitude 1"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == "") return "Latitude 1 cannot be empty";
                        if (double.tryParse(val) == null)
                          return "Enter valid value";
                        return null;
                      },
                      controller: _latitude1,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Longitude 1"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == "") return "Longitude 1 cannot be empty";
                        if (double.tryParse(val) == null)
                          return "Enter valid value";
                        return null;
                      },
                      controller: _longitude1,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Latitude 2"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == "") return "Latitude 2 cannot be empty";
                        if (double.tryParse(val) == null)
                          return "Enter valid value";
                        return null;
                      },
                      controller: _latitude2,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Longitude 2"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == "") return "Longitude 2 cannot be empty";
                        if (double.tryParse(val) == null)
                          return "Enter valid value";
                        return null;
                      },
                      controller: _longitude2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              if (_isLoading) CircularProgressIndicator(),
              if (!_isLoading) ...[
                RaisedButton(
                  onPressed: () => getCurPos1(),
                  child: Container(
                    child: Text("Fill 1", textAlign: TextAlign.center),
                    width: 80,
                  ),
                ),
                RaisedButton(
                  onPressed: () => getCurPos2(),
                  child: Container(
                    child: Text("Fill 2", textAlign: TextAlign.center),
                    width: 80,
                  ),
                ),
                RaisedButton(
                  onPressed: () => getData(),
                  child: Container(
                    child: Text("Find", textAlign: TextAlign.center),
                    width: 80,
                  ),
                ),
              ],
              SizedBox(height: 30),
              _dataFetched
                  ? _isError
                      ? Container()
                      : Container(
                          child: Column(
                            children: [
                              getRow("Latitude 1", _lat1),
                              SizedBox(height: 10),
                              getRow("Longitude 1", _long1),
                              SizedBox(height: 10),
                              getRow("Latitude 2", _lat2),
                              SizedBox(height: 10),
                              getRow("Longitude 2", _long2),
                              SizedBox(height: 10),
                              getRow("Distance (kms)", _distance),
                            ],
                          ),
                        )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
