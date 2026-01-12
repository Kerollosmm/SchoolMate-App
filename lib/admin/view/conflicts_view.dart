import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/admin/controllers/conflict_controller.dart';
import 'package:school_management_system/public/models/conflict_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConflictsView extends StatelessWidget {
  final ConflictController controller = Get.put(ConflictController());

  ConflictsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Conflict Resolution")),
      body: Obx(() {
        if (controller.conflicts.isEmpty) {
          return Center(child: Text("No conflicts found."));
        }
        return ListView.separated(
          itemCount: controller.conflicts.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            ConflictRecord conflict = controller.conflicts[index];
            return ListTile(
              title: Text("${conflict.studentName} (${conflict.date})"),
              subtitle: Text("Local: ${conflict.localVersion['status']} vs Remote: ${conflict.remoteVersion['status']}"),
              trailing: ElevatedButton(
                child: Text("Resolve"),
                onPressed: () => _showResolutionDialog(context, conflict),
              ),
            );
          },
        );
      }),
    );
  }

  void _showResolutionDialog(BuildContext context, ConflictRecord conflict) {
    Get.defaultDialog(
      title: "Resolve Conflict",
      content: Column(
        children: [
          Text("Student: ${conflict.studentName}"),
          Text("Date: ${conflict.date}"),
          Divider(),
          ListTile(
            title: Text("Keep Local Version"),
            subtitle: Text("Status: ${conflict.localVersion['status']}"),
            onTap: () => controller.resolveConflict(conflict, true),
            tileColor: Colors.blue.withOpacity(0.1),
          ),
          SizedBox(height: 10.h),
          ListTile(
            title: Text("Accept Remote Version"),
            subtitle: Text("Status: ${conflict.remoteVersion['status']}"),
            onTap: () => controller.resolveConflict(conflict, false),
            tileColor: Colors.green.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
