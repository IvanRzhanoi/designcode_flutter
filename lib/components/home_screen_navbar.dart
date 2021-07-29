import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/components/searchfield_widget.dart';
import 'package:first_project/components/sidebar_button.dart';
import 'package:first_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class HomeScreenNavBar extends StatelessWidget {
  HomeScreenNavBar({required this.triggerAnimation});
  final photoURL = FirebaseAuth.instance.currentUser.photoURL;
  final Function() triggerAnimation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SidebarButton(triggerAnimation: triggerAnimation,),
          SearchFieldWidget(),
          Icon(
              Icons.notifications,
              color: kPrimaryLabelColor
          ),
          SizedBox(
              width: 16.0
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ProfileScreen()
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Color(0xFFE7EEFB),
              child: (photoURL != null)
                  ? ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Image.network(
                    photoURL,
                    width: 36.0,
                    height: 36.0,
                    fit: BoxFit.cover,
                  )
              )
                  : Icon(Icons.person),
              radius: 18.0,
            ),
          )
        ],
      ),
    );
  }
}