import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_project/components/cards/completed_courses_card.dart';
import 'package:first_project/components/certificate_viewer.dart';
import 'package:first_project/components/lists/completed_courses_list.dart';
import 'package:first_project/constants.dart';
import 'package:first_project/model/course.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var badges = [];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  var name = "Loading...";
  var bio = "Loading";
  var photoURL = FirebaseAuth.instance.currentUser.photoURL;

  @override
  void initState() {
    super.initState();
    _auth.currentUser.reload();
    loadUserData();
    loadBadges();
  }

  Future getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File _image = File(pickedFile.path);

      _storage
          .ref("profile_pictures/${_auth.currentUser.uid}.jpg")
          .putFile(_image)
          .then((snapshot) {
        snapshot
            .ref
            .getDownloadURL()
            .then((url) {
          _firestore
              .collection("users")
              .doc(_auth.currentUser.uid)
              .update({
            'profilePic': url
          }).then((snapshot) {
            _auth
                .currentUser
                .updateProfile(photoURL: url);
          });
        });
      });
    } else {
      print("assa");
    }
  }

  void loadUserData() {
    _firestore
        .collection("users")
        .doc(_auth.currentUser.uid)
        .get()
        .then((snapshot) {
      setState(() {
        name = snapshot.data()["name"];
        bio = snapshot.data()["bio"];
      });
    });
  }

  void updateUserData() {
    _firestore
        .collection("users")
        .doc(_auth.currentUser.uid)
        .update({
      'name': name,
      'bio':bio,
    }).then((value) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Success!"),
              content: Text("The profile data has been updated!"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Uh-Oh!"),
              content: Text("$err"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Try Again!"),
                ),
              ],
            );
          });
    });
  }

  void loadBadges() {
    _firestore
        .collection("users")
        .doc(_auth.currentUser.uid)
        .get()
        .then((snapshot) {
      for (var badge in snapshot.data()["badges"]) {
        _storage
            .ref("badges/$badge")
            .getDownloadURL()
            .then((url) {
          setState(() {
            badges.add(url);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kCardPopupBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kShadowColor,
                    offset: Offset(0, 12),
                    blurRadius: 32.0,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 24.0,
                        bottom: 32.0,
                        left: 20,
                        right: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RawMaterialButton(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            constraints: BoxConstraints(
                              minWidth: 40.0,
                              maxWidth: 40.0,
                              maxHeight: 24.0,
                            ),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: kSecondaryLabelColor,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Profile",
                            style: kCalloutLabelStyle,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Update Your Profile!"),
                                      content: Column(
                                        children: [
                                          TextField(
                                            onChanged: (newValue) {
                                              setState(() {
                                                name = newValue;
                                              });
                                            },
                                            controller: TextEditingController(text: name),
                                          ),
                                          TextField(
                                            onChanged: (newValue) {
                                              setState(() {
                                                bio = newValue;
                                              });
                                            },
                                            controller: TextEditingController(text: bio),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            updateUserData();
                                          },
                                          child: Text("Update!"),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: kShadowColor,
                                    offset: Offset(0, 12),
                                    blurRadius: 32.0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
                                color: kSecondaryLabelColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Container(
                                  padding: EdgeInsets.all(6.0),
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xFFE7EEFB),
                                    child: (photoURL != null)
                                        ? ClipRRect(
                                        borderRadius: BorderRadius.circular(30.0),
                                        child: Image.network(
                                          photoURL,
                                          width: 60.0,
                                          height: 60.0,
                                          fit: BoxFit.cover,
                                        )
                                    )
                                        : Icon(Icons.person),
                                    radius: 30.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kBackgroundColor,
                                    borderRadius: BorderRadius.circular(42.0),
                                  ),
                                ),
                              ),
                              height: 84.0,
                              width: 84.0,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFF00AEFF),
                                    Color(0xFF0076FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(42.0),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: kTitle2Style,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                bio,
                                style: kSecondaryCalloutLabelStyle,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 28.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Badges",
                                  style: kHeadlineLabelStyle,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "See all",
                                      style: kSearchPlaceholderStyle,
                                    ),
                                    Icon(Icons.chevron_right, color: kSecondaryLabelColor,),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: 112.0,
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 28.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: badges.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: index !=3 ? 0.0 : 20.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: kShadowColor.withOpacity(0.1),
                                  offset: Offset(0, 12),
                                  blurRadius: 18.0,
                                ),
                              ],
                            ),
                            child: Image.network('${badges[index]}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 32.0,
                left: 20.0,
                right: 20.0,
                bottom: 12.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Certificates",
                        style: kHeadlineLabelStyle,
                      ),
                      Row(
                        children: [
                          Text(
                            "See all",
                            style: kSearchPlaceholderStyle,
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: kSecondaryLabelColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CertificateViewer(),
            Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 12.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Completed Courses",
                        style: kHeadlineLabelStyle,
                      ),
                      Row(
                        children: [
                          Text(
                            "See all",
                            style: kSearchPlaceholderStyle,
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: kSecondaryLabelColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CompletedCoursesList(),
            SizedBox(height: 28.0),
          ],
        ),
      ),
    );
  }
}
