import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/public/utils/constant.dart';
import 'package:school_management_system/routes/app_pages.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;

import '../../../public/config/user_information.dart';
import '../../Widgets/chat_body_widget.dart';
import '../../Widgets/chat_header_widget.dart';
import '../../models/user.dart';
import '../../resources/chat/chat_api.dart';
import '../TeacherEmails/Teachers.body.dart';
import '../TeacherEmails/Teachersheader.dart';

class ChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(AppPages.Chatsearch);
          },
          child: Icon(Icons.search),
          focusColor: primaryColor,
          hoverColor: primaryColor,
          splashColor: primaryColor,
          backgroundColor: primaryColor,
        ),
        backgroundColor: primaryColor,
        body: SafeArea(
          child: StreamBuilder<List<User>>(
            stream: FirebaseApi.getUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return _buildSkeletonLoader();
                default:
                  if (snapshot.hasError) {
                    developer.log(snapshot.error.toString());
                    return buildText('Something Went Wrong Try later');
                  } else {
                    final users = snapshot.data!;

                    if (users.isEmpty) {
                      return buildText('No Users Found');
                    } else
                      return Column(
                        children: [
                          if (UserInformation.uParent == false)
                            ChatHeaderWidget(users: users),
                          if (UserInformation.uParent == false)
                            ChatBodyWidget(users: users),
                          if (UserInformation.uParent)
                            TeachersHeaderWidget(users: users),
                          if (UserInformation.uParent)
                            TeachersBodyWidget(users: users)
                        ],
                      );
                  }
              }
            },
          ),
        ),
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: double.infinity, color: Colors.white),
                    SizedBox(height: 5),
                    Container(height: 10, width: 100, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
