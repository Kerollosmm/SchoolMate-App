import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/public/login/login_controller.dart';
import 'package:school_management_system/public/login/login_label.dart';
import 'package:school_management_system/public/utils/constant.dart';
import 'package:school_management_system/public/utils/font_style.dart';
import 'package:school_management_system/public/widgets/circuled_button.dart';
import 'package:school_management_system/public/widgets/custom_button.dart';
import 'package:school_management_system/public/widgets/custom_formfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Pics pics = Pics();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/images/login-background-squares.png",
                ),
                fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 72.h),
                    const Loginlabel(),
                    SizedBox(height: size.height / 15), // Reduced slightly to fit more
                    Text(
                      "I am",
                      style: sfBoldStyle(fontSize: 24, color: gray),
                    ),
                    SizedBox(height: 20.h),

                    // Role Selection
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildRoleButton(
                              'teacher',
                              pics.teacherGreyPic,
                              controller.selectedRole.value == 'teacher'
                            ),
                            SizedBox(width: 10.w),
                            _buildRoleButton(
                              'student',
                              pics.studentGreyPic,
                              controller.selectedRole.value == 'student'
                            ),
                            SizedBox(width: 10.w),
                            _buildRoleButton(
                              'parent',
                              pics.parentGreyPic,
                              controller.selectedRole.value == 'parent'
                            ),
                            SizedBox(width: 10.w),
                            _buildRoleButton(
                              'admin',
                              pics.adminGreyPic,
                              controller.selectedRole.value == 'admin'
                            ),
                          ],
                        ),
                      )),
                    ),
                    SizedBox(height: 32.h),

                    // Login Form
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(children: [
                        customFormField(
                          controller: controller.emailController,
                          label: 'Email',
                          prefix: Icons.email,
                          type: TextInputType.emailAddress,
                          validate: (String? value) {
                            if (value!.isEmpty) return 'email must not be empty';
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        Obx(() => customFormField(
                          controller: controller.passwordController,
                          label: 'Password',
                          prefix: Icons.lock,
                          suffix: controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          isPassword: controller.isPasswordVisible.value,
                          suffixPressed: controller.togglePasswordVisibility,
                          type: TextInputType.visiblePassword,
                          validate: (String? value) {
                            if (value!.isEmpty) return 'password is too short';
                            return null;
                          },
                        )),
                        SizedBox(height: 20.h),
                      ]),
                    ),

                    SizedBox(height: 32.h),

                    Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          press: controller.login,
                        )
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, String pic, bool isSelected) {
    return circuledButton(
      pic: pic,
      text: role,
      background: isSelected ? gradientColor : gradientColor2,
      icontextcolor: isSelected ? Colors.white : gray,
      press: () => controller.selectRole(role),
    );
  }
}
