import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/marker_description.dart';

class ChooseMarker extends StatelessWidget {
  final MarkerData markers;
  final bool getMoreInfo;
  ChooseMarker({this.markers, this.getMoreInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Marker Chooser"),
          backgroundColor: appColorMid,
        ),
        body: Container (
          decoration: customBoxDecoration(),
          child: ListView.builder(
            itemCount: markers?.markerList?.length ?? 0,
            itemBuilder: (context,index) {
              return Card( child:
                  ListTile(
                leading: markers.markerList[index].image,
                title: Text(markers.markerList[index].commonName),
                    onTap: () async {
                        if(getMoreInfo) {
                          String desc = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                MarkerDescription()),
                          );
                          markers.markerList[index].desc = desc;
                        }
                        Navigator.pop(context, markers.markerList[index]);
                      },
              )
              );
            }
          ),
        )
      );
  }
}