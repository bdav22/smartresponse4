import 'package:flutter/material.dart';
import 'package:smartresponse4/profile_tile.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/loading.dart';
import 'package:smartresponse4/scene_home.dart';
import 'package:smartresponse4/scene_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SceneList extends StatefulWidget {
  @override
  _SceneListState createState() => _SceneListState();
}

class _SceneListState extends State<SceneList> {
  @override
  Widget build(BuildContext context) {
    final scenes = Provider.of<List<Scene>>(context) ?? [];


    return ListView.builder(
      itemCount: scenes.length,
      itemBuilder: (context, index) {
        return SceneTile(scene: scenes[index]);
      },
    );
  }
}