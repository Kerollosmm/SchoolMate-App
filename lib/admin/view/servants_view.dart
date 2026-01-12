import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/admin/controllers/admin_servants_controller.dart';
import 'package:school_management_system/public/models/servant_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServantsView extends GetView<AdminServantsController> {
  const ServantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.servants.isEmpty) {
          return Center(child: Text("No servants found"));
        }
        return ListView.separated(
          itemCount: controller.servants.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            ServantProfile servant = controller.servants[index];
            return ListTile(
              leading: CircleAvatar(child: Text(servant.name[0])),
              title: Text(servant.name),
              subtitle: Text("${servant.email} | Grade: ${servant.assignedGrade}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Switch(
                     value: servant.isActive,
                     onChanged: (val) => controller.toggleActivation(servant.uid, servant.isActive)
                   ),
                   IconButton(
                     icon: Icon(Icons.delete, color: Colors.red),
                     onPressed: () => controller.deleteServant(servant.uid),
                   )
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final gradeC = TextEditingController();
    final passC = TextEditingController();

    Get.defaultDialog(
      title: "Add Servant",
      content: Column(
        children: [
          TextField(controller: nameC, decoration: InputDecoration(labelText: "Name")),
          TextField(controller: emailC, decoration: InputDecoration(labelText: "Email")),
          TextField(controller: gradeC, decoration: InputDecoration(labelText: "Assigned Grade (e.g. '1')")),
          TextField(controller: passC, decoration: InputDecoration(labelText: "Password (dummy)")),
        ],
      ),
      textConfirm: "Add",
      onConfirm: () {
        if (nameC.text.isNotEmpty && gradeC.text.isNotEmpty) {
           controller.addServant(nameC.text, emailC.text, gradeC.text, passC.text);
        }
      }
    );
  }
}
