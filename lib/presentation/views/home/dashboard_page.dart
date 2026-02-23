import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Issue Dashboard")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openIssueDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("issues")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final issues = snapshot.data!.docs;

          if (issues.isEmpty) {
            return const Center(child: Text("No Issues Found"));
          }

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(issue["issueSummary"]),
                  subtitle: Text(
                      "${issue["customer"]} • ${issue["status"]} • ${issue["priority"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openIssueDialog(context, issue: issue),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔥 Common dialog for Create + Edit
  void _openIssueDialog(BuildContext context, {DocumentSnapshot? issue}) {
    final processController =
        TextEditingController(text: issue?["processName"]);
    final assignedController =
        TextEditingController(text: issue?["assignedTo"]);
    final summaryController =
        TextEditingController(text: issue?["issueSummary"]);
    final actionController = TextEditingController(text: issue?["actionTaken"]);

    String customer = issue?["customer"] ?? "Ecocash";
    String technology = issue?["technology"] ?? "UiPath";
    String priority = issue?["priority"] ?? "Low";
    String status = issue?["status"] ?? "New";
    String rootCause = issue?["rootCauseCategory"] ?? "Unknown";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(issue == null ? "Create Issue" : "Edit Issue"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.65, // 60% screen width

            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: customer,
                        items: [
                          "Ecocash",
                          "Econet",
                          "CWS",
                          "EMM",
                          "EthioTelecom"
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => customer = val!),
                        decoration:
                            const InputDecoration(labelText: "Customer"),
                      ),
                      TextField(
                        controller: processController,
                        decoration:
                            const InputDecoration(labelText: "Process Name"),
                      ),
                      DropdownButtonFormField(
                        value: technology,
                        items: [
                          "Power Automate Cloud",
                          "PAD",
                          "UiPath",
                          "SQL",
                          "SharePoint",
                          "Other"
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => technology = val!),
                        decoration:
                            const InputDecoration(labelText: "Technology"),
                      ),
                      DropdownButtonFormField(
                        value: priority,
                        items: ["Low", "Medium", "High", "Critical"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => priority = val!),
                        decoration:
                            const InputDecoration(labelText: "Priority"),
                      ),
                      TextField(
                        controller: assignedController,
                        decoration:
                            const InputDecoration(labelText: "Assigned To"),
                      ),
                      DropdownButtonFormField(
                        value: status,
                        items: [
                          "New",
                          "In Progress",
                          "Waiting for Client",
                          "Resolved",
                          "Closed"
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => status = val!),
                        decoration: const InputDecoration(labelText: "Status"),
                      ),
                      TextField(
                        controller: summaryController,
                        decoration:
                            const InputDecoration(labelText: "Issue Summary"),
                      ),
                      DropdownButtonFormField(
                        value: rootCause,
                        items: [
                          "Infra",
                          "Code Bug",
                          "Data Issue",
                          "Credentials",
                          "Business Change",
                          "Access",
                          "Unknown"
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => rootCause = val!),
                        decoration:
                            const InputDecoration(labelText: "Root Cause"),
                      ),
                      TextField(
                        controller: actionController,
                        decoration:
                            const InputDecoration(labelText: "Action Taken"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (issue == null) {
                  // CREATE
                  final doc =
                      FirebaseFirestore.instance.collection("issues").doc();

                  await doc.set({
                    "issueId": doc.id,
                    "customer": customer,
                    "processName": processController.text,
                    "technology": technology,
                    "priority": priority,
                    "assignedTo": assignedController.text,
                    "status": status,
                    "issueSummary": summaryController.text,
                    "rootCauseCategory": rootCause,
                    "actionTaken": actionController.text,
                    "startDate": Timestamp.now(),
                    "closingDate": status == "Closed" ? Timestamp.now() : null,
                    "createdAt": Timestamp.now(),
                  });
                } else {
                  // UPDATE
                  await FirebaseFirestore.instance
                      .collection("issues")
                      .doc(issue.id)
                      .update({
                    "customer": customer,
                    "processName": processController.text,
                    "technology": technology,
                    "priority": priority,
                    "assignedTo": assignedController.text,
                    "status": status,
                    "issueSummary": summaryController.text,
                    "rootCauseCategory": rootCause,
                    "actionTaken": actionController.text,
                    "closingDate": status == "Closed" ? Timestamp.now() : null,
                  });
                }

                Navigator.pop(context);
              },
              child: Text(issue == null ? "Create" : "Update"),
            )
          ],
        );
      },
    );
  }
}
