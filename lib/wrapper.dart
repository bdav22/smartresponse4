import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/authenticate.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    //return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}