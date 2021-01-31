
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartresponse4/database.dart';
//import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/equipment.dart';
//import 'package:smartresponse4/equipment_riders.dart';
import 'package:provider/provider.dart';


class NotificationsSelection extends StatefulWidget {
  final squadID;
  NotificationsSelection(this.squadID);

  @override
  _NotificationsSelectionState createState() => _NotificationsSelectionState();
}

class _NotificationsSelectionState extends State<NotificationsSelection> {

  Stream<List<Equipment>> _eqStream;
  Map<String, bool> values = {
  };


  @override
  void initState() {
    super.initState();
    _eqStream = context.read<Repository>().getEquipment(widget.squadID);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Select Equipment Notifications')),
      body: StreamBuilder<List<Equipment>> (
        stream: _eqStream,
        builder: (BuildContext context, AsyncSnapshot<List<Equipment>> eqss) {
          if (eqss.hasData) {
            return ListView(
                shrinkWrap: true,
                children: eqss.data.map((Equipment eq) {
                  return CheckboxListTile(
                    title: new Text(eq.equipmentName),
                    value: values[eq.equipmentName] ?? false,
                    onChanged: (bool value) {
                      setState(() {
                        values[eq.equipmentName] = value;
                      });
                    }
                  );
                }).toList()
            );
          }
          else {
            return Text("Loading Equipment Data");
          }
        }
    ));

/*
    new ListView(
        children: values.keys.map((String key) {
          return new CheckboxListTile(
            title: new Text(key),
            value: values[key],
            onChanged: (bool value) {
              setState(() {
                values[key] = value;
              });
            },
          );
        }).toList(),
      ),
    );
 */
  }
}
