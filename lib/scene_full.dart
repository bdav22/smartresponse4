import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/wrapper.dart';

class FullSceneTile extends StatefulWidget {

  final Scene scene;
  final String respond = "Respond";
  FullSceneTile({this.scene});
  _FullSceneTileState createState() => _FullSceneTileState();
}


class _FullSceneTileState extends State<FullSceneTile> {

  bool displayRespond = true;
  Widget respondButton;
  Widget alreadyResponding = getMyButton("--", (){}, color: "invisible");
  Widget actualWidgetRespond;
  @override
  void initState() {
    super.initState();
    displayRespond = EmailStorage.instance.userData.responding != widget.scene.ref.id;

    actualWidgetRespond =         getMyButton("Respond", () async {
        //String address = await widget.scene.getAddress();
        String address = widget.scene.address;
        await FirebaseFirestore.instance.collection("profiles").doc(EmailStorage.instance.uid).update({
          "responding": widget.scene.ref.id
        });
        print("scene_tile.dart: Responding to this scene at: " + address);
        BackgroundLocationInterface().onStart(widget.scene.ref.id);
        EmailStorage.instance.updateData();
        Navigator.pop(context);
        setState(() {
          if(displayRespond) {
            respondButton = actualWidgetRespond;
          }
          else {
            respondButton = alreadyResponding;
          }
        });
      }, color: "go");

    if(displayRespond) {
      respondButton = actualWidgetRespond;
    }
    else {
      respondButton = alreadyResponding;
    }


  }


  String getShortDescription(String desc) {
    final length = 85;
    if (desc.length > length) {
      return desc.substring(0, length - 4) + " ...";
    } else {
      return desc;
    }
  }


  void respondFunction(BuildContext context) async {
    if (widget.respond == "Respond") {

    } else {
      BackgroundLocationInterface().onStop();
      await FirebaseFirestore.instance.collection("profiles").doc(EmailStorage.instance.uid).update({
        "responding": "unbusy"
      });
      EmailStorage.instance.updateData();
    }
  }


  @override
  Widget build(BuildContext context) {
    final p = ProfileInfo.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Full Scene Description"),
        backgroundColor: appColorMid,
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Container(
        decoration: customBoxDecoration(),
        child: Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Card(
              shadowColor: Colors.red,
              margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
              child: Column(children: <Widget>[
                ListTile(

                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding (
                          padding: EdgeInsets.fromLTRB(0,0,10,0),
                          child: Text(widget.scene?.created?.toDate()?.toLocal()?.toString()?.substring(5, 16) ?? "---",
                            style: TextStyle(color: appColorMidLight)
                          ),
                        ),
                        Flexible(child: Text(widget.scene.address, overflow: TextOverflow.ellipsis)),
                        /*
                        FutureBuilder<String>(
                            future: widget.scene.address, //getLocality(),
                            builder: (context, snapshot) {
                              if(snapshot.hasError) { return Text('Error: ${snapshot.error}');    }
                              if(snapshot.connectionState == ConnectionState.waiting) { return Text('Loading...Connection Waiting'); }
                              if (snapshot.hasData) {
                                return Flexible(child: Text(snapshot.data, overflow: TextOverflow.ellipsis) );
                              } else {
                                return Text("location data is loading");
                              }
                            })
                         */
                      ]),
                  subtitle: Text('Lat: ${widget.scene.location.latitude.toString()}, Long:${widget.scene.location.longitude.toString()} '),
                ),
                //FutureBuilder<String>( future: widget.scene.getLocality( version: 1), builder: (context, snapshot) { if(snapshot.hasData) { return(Flexible(child: Text(snapshot.data))); } else { return Text("full loc"); }}),
                Flexible(child: Text(widget?.scene?.address ?? "No Address")),
                Flexible(child: Text(widget?.scene?.priority ?? "No Priority")),
                Flexible(child: Text(widget?.scene?.units ?? "No Units")),
                Padding( padding: EdgeInsets.all(18.0), child: Text(widget.scene?.desc ?? "---")),
                Flexible( child: SizedBox(height: 550) ),
                Row(

                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [
                      getMyButton( 'Chat',  () {Navigator.pushNamed(context, '/chat', arguments: widget.scene);}),
                      getMyButton("ICS", () {Navigator.of(context).pushNamed('/ICS', arguments: widget.scene);}),
                      getMyButton( "Logistics", () {Navigator.of(context).pushNamed('/Logistics', arguments: widget.scene);}),
                    ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [
                      p.profile.responding != widget.scene.ref.id ? respondButton : SizedBox(),
                      getMyButton( 'Map',  () {Navigator.pushNamed(context, '/MyMapPage', arguments: widget.scene);}),
                      getMyButton( 'Drive',  () async {
                        String address = widget.scene.address; //await getAddress();
                        MapsLauncher.launchQuery(address);
                      }),

                    ]),


              ]),
            )),
      ),
    );
  }
}
