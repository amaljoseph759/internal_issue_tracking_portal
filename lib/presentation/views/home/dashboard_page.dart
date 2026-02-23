// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:internal_issue_tracking_portal/presentation/views/auth/login.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Issue Dashboard"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: "Logout",
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();

//               if (!context.mounted) return;

//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginPage()),
//                 (route) => false,
//               );
//             },
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _openIssueDialog(context),
//         child: const Icon(Icons.add),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection("issues")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final issues = snapshot.data!.docs;

//           if (issues.isEmpty) {
//             return const Center(child: Text("No Issues Found"));
//           }

//           return ListView.builder(
//             itemCount: issues.length,
//             itemBuilder: (context, index) {
//               final issue = issues[index];

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// Priority Indicator
//                       Container(
//                         width: 6,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: _priorityColor(issue["priority"]),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(width: 12),

//                       /// Issue Content
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             /// Issue Summary
//                             Text(
//                               issue["issueSummary"],
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 6),

//                             /// Customer + Technology
//                             Text(
//                               "${issue["customer"]} • ${issue["technology"]}",
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             const SizedBox(height: 8),

//                             /// Status + Priority Chips
//                             Row(
//                               children: [
//                                 _statusChip(issue["status"]),
//                                 const SizedBox(width: 8),
//                                 _priorityChip(issue["priority"]),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       /// Edit Button
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () =>
//                             _openIssueDialog(context, issue: issue),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Color _priorityColor(String priority) {
//     switch (priority) {
//       case "Critical":
//         return Colors.red;
//       case "High":
//         return Colors.orange;
//       case "Medium":
//         return Colors.amber;
//       default:
//         return Colors.green;
//     }
//   }

//   Widget _priorityChip(String priority) {
//     return Chip(
//       label: Text(
//         priority,
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       ),
//       backgroundColor: _priorityColor(priority),
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//     );
//   }

//   Widget _statusChip(String status) {
//     Color color;
//     switch (status) {
//       case "New":
//         color = Colors.blue;
//         break;
//       case "In Progress":
//         color = Colors.orange;
//         break;
//       case "Waiting for Client":
//         color = Colors.purple;
//         break;
//       case "Resolved":
//         color = Colors.green;
//         break;
//       case "Closed":
//         color = Colors.grey;
//         break;
//       default:
//         color = Colors.blueGrey;
//     }

//     return Chip(
//       label: Text(
//         status,
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       ),
//       backgroundColor: color,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//     );
//   }

//   // 🔥 Common dialog for Create + Edit
//   void _openIssueDialog(BuildContext context, {DocumentSnapshot? issue}) {
//     final processController =
//         TextEditingController(text: issue?["processName"]);
//     final assignedController =
//         TextEditingController(text: issue?["assignedTo"]);
//     final summaryController =
//         TextEditingController(text: issue?["issueSummary"]);
//     final actionController = TextEditingController(text: issue?["actionTaken"]);

//     String customer = issue?["customer"] ?? "Ecocash";
//     String technology = issue?["technology"] ?? "UiPath";
//     String priority = issue?["priority"] ?? "Low";
//     String status = issue?["status"] ?? "New";
//     String rootCause = issue?["rootCauseCategory"] ?? "Unknown";

//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text(issue == null ? "Create Issue" : "Edit Issue"),
//           content: SizedBox(
//             width: MediaQuery.of(context).size.width * 0.65, // 60% screen width

//             child: StatefulBuilder(
//               builder: (context, setState) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       DropdownButtonFormField(
//                         value: customer,
//                         items: [
//                           "Ecocash",
//                           "Econet",
//                           "CWS",
//                           "EMM",
//                           "EthioTelecom"
//                         ]
//                             .map((e) =>
//                                 DropdownMenuItem(value: e, child: Text(e)))
//                             .toList(),
//                         onChanged: (val) => setState(() => customer = val!),
//                         decoration:
//                             const InputDecoration(labelText: "Customer"),
//                       ),
//                       TextField(
//                         controller: processController,
//                         decoration:
//                             const InputDecoration(labelText: "Process Name"),
//                       ),
//                       DropdownButtonFormField(
//                         value: technology,
//                         items: [
//                           "Power Automate Cloud",
//                           "PAD",
//                           "UiPath",
//                           "SQL",
//                           "SharePoint",
//                           "Other"
//                         ]
//                             .map((e) =>
//                                 DropdownMenuItem(value: e, child: Text(e)))
//                             .toList(),
//                         onChanged: (val) => setState(() => technology = val!),
//                         decoration:
//                             const InputDecoration(labelText: "Technology"),
//                       ),
//                       DropdownButtonFormField(
//                         value: priority,
//                         items: ["Low", "Medium", "High", "Critical"]
//                             .map((e) =>
//                                 DropdownMenuItem(value: e, child: Text(e)))
//                             .toList(),
//                         onChanged: (val) => setState(() => priority = val!),
//                         decoration:
//                             const InputDecoration(labelText: "Priority"),
//                       ),
//                       TextField(
//                         controller: assignedController,
//                         decoration:
//                             const InputDecoration(labelText: "Assigned To"),
//                       ),
//                       DropdownButtonFormField(
//                         value: status,
//                         items: [
//                           "New",
//                           "In Progress",
//                           "Waiting for Client",
//                           "Resolved",
//                           "Closed"
//                         ]
//                             .map((e) =>
//                                 DropdownMenuItem(value: e, child: Text(e)))
//                             .toList(),
//                         onChanged: (val) => setState(() => status = val!),
//                         decoration: const InputDecoration(labelText: "Status"),
//                       ),
//                       TextField(
//                         controller: summaryController,
//                         decoration:
//                             const InputDecoration(labelText: "Issue Summary"),
//                       ),
//                       DropdownButtonFormField(
//                         value: rootCause,
//                         items: [
//                           "Infra",
//                           "Code Bug",
//                           "Data Issue",
//                           "Credentials",
//                           "Business Change",
//                           "Access",
//                           "Unknown"
//                         ]
//                             .map((e) =>
//                                 DropdownMenuItem(value: e, child: Text(e)))
//                             .toList(),
//                         onChanged: (val) => setState(() => rootCause = val!),
//                         decoration:
//                             const InputDecoration(labelText: "Root Cause"),
//                       ),
//                       TextField(
//                         controller: actionController,
//                         decoration:
//                             const InputDecoration(labelText: "Action Taken"),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (issue == null) {
//                   // CREATE
//                   final doc =
//                       FirebaseFirestore.instance.collection("issues").doc();

//                   await doc.set({
//                     "issueId": doc.id,
//                     "customer": customer,
//                     "processName": processController.text,
//                     "technology": technology,
//                     "priority": priority,
//                     "assignedTo": assignedController.text,
//                     "status": status,
//                     "issueSummary": summaryController.text,
//                     "rootCauseCategory": rootCause,
//                     "actionTaken": actionController.text,
//                     "startDate": Timestamp.now(),
//                     "closingDate": status == "Closed" ? Timestamp.now() : null,
//                     "createdAt": Timestamp.now(),
//                   });
//                 } else {
//                   // UPDATE
//                   await FirebaseFirestore.instance
//                       .collection("issues")
//                       .doc(issue.id)
//                       .update({
//                     "customer": customer,
//                     "processName": processController.text,
//                     "technology": technology,
//                     "priority": priority,
//                     "assignedTo": assignedController.text,
//                     "status": status,
//                     "issueSummary": summaryController.text,
//                     "rootCauseCategory": rootCause,
//                     "actionTaken": actionController.text,
//                     "closingDate": status == "Closed" ? Timestamp.now() : null,
//                   });
//                 }

//                 Navigator.pop(context);
//               },
//               child: Text(issue == null ? "Create" : "Update"),
//             )
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internal_issue_tracking_portal/presentation/views/auth/login.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Issue Dashboard",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _openIssueDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("New Issue"),
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

          return Column(
            children: [
              _buildHeader(),
              _buildStats(issues),
              Expanded(
                child: issues.isEmpty
                    ? _buildEmptyState()
                    : _buildIssueList(context, issues),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🔷 HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Back 👋",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Track and manage automation issues",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 🔷 STATS CARDS
  Widget _buildStats(List docs) {
    final total = docs.length;
    final open = docs.where((e) => e["status"] != "Closed").length;
    final closed = docs.where((e) => e["status"] == "Closed").length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _statCard("Total", total.toString(), Colors.blue),
          const SizedBox(width: 12),
          _statCard("Open", open.toString(), Colors.orange),
          const SizedBox(width: 12),
          _statCard("Closed", closed.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // 🔷 ISSUE LIST
  Widget _buildIssueList(
      BuildContext context, List<QueryDocumentSnapshot> issues) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        issue["issueSummary"],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _priorityChip(issue["priority"]),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${issue["customer"]} • ${issue["technology"]}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statusChip(issue["status"]),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _openIssueDialog(context, issue: issue),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔷 EMPTY STATE
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No Issues Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 🔷 PRIORITY COLOR
  Color _priorityColor(String priority) {
    switch (priority) {
      case "Critical":
        return Colors.red;
      case "High":
        return Colors.orange;
      case "Medium":
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  Widget _priorityChip(String priority) {
    return Chip(
      label: Text(priority,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: _priorityColor(priority),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "New":
        color = Colors.blue;
        break;
      case "In Progress":
        color = Colors.orange;
        break;
      case "Resolved":
        color = Colors.green;
        break;
      case "Closed":
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Chip(
      label: Text(status,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // 🔷 ISSUE DIALOG (Create + Edit)
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
