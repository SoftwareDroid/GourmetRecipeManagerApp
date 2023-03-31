import 'package:flutter/material.dart';

var bodyProgress = new Container(
  child: new Stack(
    children: <Widget>[
      new Container(
        alignment: AlignmentDirectional.center,
        decoration: new BoxDecoration(
          color: Colors.white70,
        ),
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.blue[200],
              borderRadius: new BorderRadius.circular(10.0)),
          width: 300.0,
          height: 200.0,
          alignment: AlignmentDirectional.center,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
              new Center(
                child: new SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: new CircularProgressIndicator(
                    value: null,
                    strokeWidth: 7.0,
                  ),
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(top: 25.0),
                child: new Center(
                  child: new Text(
                    "loading.. wait...",
                    style: new TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);

Widget loadImage(BuildContext context, Future<List<int>> f1, int imgSize,
    bool showAsCircle) {
  return FutureBuilder<List<int>>(
    future: f1, // a previously-obtained Future<String> or null
    builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
      List<Widget> children;

      if (snapshot.hasData) {
        if (snapshot.data == null) {
          return Icon(
            Icons.image,
            color: Colors.green,
            //size: imgSize.toDouble(),
          );
        } else {
          if (showAsCircle) {

            children = <Widget>[
              Container(
                color: Colors.transparent,
                width: imgSize.toDouble(),
                height: imgSize.toDouble(),
                child: ClipOval(
                    child: Image.memory(snapshot.data, fit: BoxFit.cover)),
              ),
            ];
          } else {

            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(snapshot.data, fit: BoxFit.cover),
            );
          }
        }
      } else if (snapshot.hasError) {
        return new FittedBox(
          fit: BoxFit.fill,
          child: new Icon(Icons.error_outline, color: Colors.red),
        );
      } else {

        return new FittedBox(
          fit: BoxFit.fill,
          child: new Icon(Icons.image, color: Colors.green),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    },
  );
}
