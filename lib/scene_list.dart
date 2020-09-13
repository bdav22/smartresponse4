import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/scene_tile.dart';
import 'package:smartresponse4/user.dart';

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