import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/marker_data.dart';

class ChooseMarker extends StatelessWidget {
  final MarkerData markers;
  ChooseMarker({this.markers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Marker Chooser")
        ),
        body: ListView.builder(
          itemCount: markers?.markerList?.length ?? 0,
          itemBuilder: (context,index) {
            return Card( child:
                ListTile(
              leading: markers.markerList[index].image,
              title: Text(markers.markerList[index].commonName),
                    onTap: () {
                      Navigator.pop(context, markers.markerList[index]);
                    },
            )
            );
          }
        )
      );
  }
}