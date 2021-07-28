import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../Models/url.dart';

class Coordinates extends StatefulWidget {
  @override
  _CoordinatesState createState() => _CoordinatesState();
}

class _CoordinatesState extends State<Coordinates> {
  final _form = GlobalKey<FormState>();
  final _ctxKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _dataFetched = false;
  bool _isError = false;
  String _address = "";
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
      final response =
          await http.post("${Url.url}${Url.coordinate}?address=$_address");
      final data = json.decode(response.body);

      // Handling Error
      if (data["error"] == null) {
        _compAddress = data["complete_address"];
        _error = data["error"];
        _lat = double.parse(data["lat"].toString()).toStringAsFixed(7);
        _long = double.parse(data["long"].toString()).toStringAsFixed(7);
      } else {
        _isError = true;

        // Finding which error
        String msg = "Internal server error. Try later.";
        if (data["error"] == "TIMEOUT") msg = "Slow Internet. Try again.";
        if (data["error"] == "NOT_FOUND")
          msg = "No such address found. Check spelling.";

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
        title: Text("Coordinates"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                "Enter address to get latitude & longitude.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _form,
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Address"),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    return val != "" ? null : "Address cannot be empty";
                  },
                  onSaved: (val) {
                    _address = val;
                  },
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: () => getData(),
                      child: Text("Find"),
                    ),
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
