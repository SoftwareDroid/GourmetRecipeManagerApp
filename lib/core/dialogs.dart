import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/**
 * A simple alter dialog
 *
 */
Future<void> altertDialog(BuildContext context, String title,String body) async {
  return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: <Widget>[
            Text(body),
          ],
        );
      });
}

/**
 * A dialog which asks for a single decision out of n
 *
 */
Future<String> simpleDialog1ofN2(BuildContext context, String title,
    List<String> names) async {
  return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: <Widget>[
            for (var name in names)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, name);
                },
                child: Text(name),
              ),
          ],
        );
      });
}
/**
 * A dialog which asks a yes no question
 *
 */
Future<bool> simpleDialogAskBoolean(
    BuildContext context, String title, String body) async {
  //Map<String,bool> ret = Map<String,bool>();

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                  child: Text(body));
            }),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),

          FlatButton(
            child: Text('Accept'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),


        ],
      );
    },
  );
}


/**
 * A dialog whcich ask to choose a subset n of subset m
 *
 */
Future<Map<String, bool>> simpleDialogNofM(
    BuildContext context, String title, Map<String, bool> names) async {
  //Map<String,bool> ret = Map<String,bool>();

  return showDialog<Map<String, bool>>(
    context: context,
    barrierDismissible: false,
    // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var name in names.keys.toList()..sort())
                CheckboxListTile(
                    title: Text(name),
                    value: names[name],
                    onChanged: (bool value) {
                      setState(() => names[name] = value);
                    }),
            ],
          ));
        }),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),

          FlatButton(
            child: Text('Accept'),
            onPressed: () {
              Navigator.of(context).pop(names);
            },
          ),


        ],
      );
    },
  );
}

/**
 * Choose a option out of n options
 *
 */
Future<String> simpleDialog1ofN(BuildContext context, String title,
    List<String> names, String defaultValue) async {
  assert(names.contains(defaultValue), "default values must be in the list");
  String groupValue = defaultValue;
  //Map<String,bool> ret = Map<String,bool>();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {


              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (var name in names..sort())
                      RadioListTile<String>(
                        title: Text(name.toString()),
                        value: name.toString(),
                        groupValue: groupValue,
                        onChanged: (String value) {
                          setState(() {
                            groupValue = value;
                          });
                        },
                      ),
                  ],
                ),
              );

          /*return Column(
            mainAxisSize: MainAxisSize.min,

          );*/
        }

        ),


        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),

          FlatButton(
            child: Text('Accept'),
            onPressed: () {
              Navigator.of(context).pop(groupValue);
            },
          ),
        ],
      );
    },
  );
}

/**
 * A dialog for entering a string
 *
 */
Future<String> simpleDialogAskForString(
    BuildContext context, String title, String label, String labelHint,List<String> forbiddenEntries) async {
  String result = '';
  bool _validate = true;
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 50,
            width: 300,
            child: SingleChildScrollView(
              child: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: label,
                  hintText: labelHint,
                  errorText: _validate ? 'Invalid Input' : null,
                ),
                onChanged: (value) {
                setState(() {
                  result = value;
                  _validate = forbiddenEntries.contains(result);
                });
                },
              ))
            ],
          )));


        }),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          FlatButton(
            child: Text('Accept'),
            // TODO um den Dialog zu deaktivieren muss das Statefullwidget auch um den Dialgo gehene
            onPressed:  () {
              if (!_validate)
                Navigator.of(context).pop(result);
            },
          ),
        ],
      );
    },
  );
}

/**
 * A dialog which asks for an interger
 *
 */
Future<int> simpleDialogAskInteger(
    BuildContext context, String title, String label, String labelHint,int min, int max, final int defaultValue) async {
  int result = defaultValue;
  bool _error = true;
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Container(
                height: 50,
                width: 300,
                child: SingleChildScrollView(
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new TextField(
                              controller: TextEditingController()..text = result.toString(),
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                              decoration: new InputDecoration(
                                labelText: label,
                                hintText: labelHint,
                                errorText: _error ? 'Out of Range' : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  result = int.parse(value);
                                  _error = result < min || result > max;
                                });
                              },
                            ))
                      ],
                    ))),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(defaultValue);
                },
              ),
              FlatButton(
                child: Text('Accept'),
                // TODO um den Dialog zu deaktivieren muss das Statefullwidget auch um den Dialgo gehene
                onPressed:  _error ? null : () {
                  if (!_error)
                    Navigator.of(context).pop(result);
                },
              ),
            ]
          );
        },
      );
    },
  );
}