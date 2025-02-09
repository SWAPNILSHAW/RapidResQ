import 'package:flutter/material.dart';
import 'package:woman_safety/drawer/custom_app_bar.dart';

class AddGuardiansDetails extends StatelessWidget {
  const AddGuardiansDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add Drtails", onMenuPressed: (){},showLeading: false,),
    );
  }
}
