import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../Models/url.dart';
import '../Models/curren_location.dart';

class Address extends StatefulWidget {
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final _form = GlobalKey<FormState>();
  final _ctxKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _dataFetched = false;
  bool _isError = false;
  TextEditingController _latitude = new TextEditingController();
  TextEditingController _longitude = new TextEditingController();
  String _compAddress;
  String _error;
  String _lat;
  String _long;

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
          "${Url.url}${Url.address}?lat=${_latitude.text}&long=${_longitude.text}");
      final data = json.decode(response.body);

      // Handling Error
      if (data["error"] == null) {
        _compAddress = data["address"];
        _error = data["error"];
        _lat = double.parse(data["lat"].toString()).toStringAsFixed(7);
        _long = double.parse(data["long"].toString()).toStringAsFixed(7);
      } else {
        _isError = true;

        // Finding which error
        String msg = "Internal server error. Try later.";
        if (data["error"] == "TIMEOUT") msg = "Slow Internet. Try again.";
        if (data["error"] == "NOT_FOUND")
          msg =
              "Either coordinates are invalid or no address at that position.";

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

  Future<void> getCurPos() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _isLoading = true;
      _dataFetched = false;
    });
    Location loc = Location();
    final Position pos = await loc.getCurrentLocation();
    setState(() {
      _latitude.value = TextEditingValue(text: pos.latitude.toString());
      _longitude.value = TextEditingValue(text: pos.longitude.toString());
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
        title: Text("Address"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                "Enter latitude & longitude to get address of that point.",
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
                      decoration: InputDecoration(labelText: "Latitude"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == "") return "Latitude cannot be empty";
                        if (double.tryParse(val) == null)
                          return "Enter valid value";
                        return null;
                      },
                      controller: _latitude,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Longitude"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == "") return "Longitude cannot be empty";
                        if (double.tryParse(val) == null)
                          return "Enter valid value";
                        return null;
                      },
                      controller: _longitude,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              if (_isLoading) CircularProgressIndicator(),
              if (!_isLoading) ...[
                RaisedButton(
                  onPressed: () => getCurPos(),
                  child: Container(
                    child: Text("Get Current", textAlign: TextAlign.center),
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
                              Text(
                                _compAddress,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 30),
                              getRow("Latitude", _lat),
                              SizedBox(height: 10),
                              getRow("Longitude", _long),
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
