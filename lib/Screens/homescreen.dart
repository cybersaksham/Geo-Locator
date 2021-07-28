import 'package:flutter/material.dart';

import '../Models/routes.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RaisedButton getBtn(String txt, String route) {
      return RaisedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(route);
        },
        child: Container(
          width: 100,
          child: Text(
            txt,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Geo Locator"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Choose one option.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            getBtn("Coordinates", Routes.coordinate),
            SizedBox(height: 10),
            getBtn("Address", Routes.address),
            SizedBox(height: 10),
            getBtn("Distance", Routes.distance),
          ],
        ),
      ),
    );
  }
}
