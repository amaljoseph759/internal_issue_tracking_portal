import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internal_issue_tracking_portal/core/utils/format_date_time.dart';
import 'package:internal_issue_tracking_portal/presentation/widgets/common_app_bar.dart';
import 'package:internal_issue_tracking_portal/presentation/widgets/issue_dialog.dart';
import 'package:internal_issue_tracking_portal/presentation/widgets/priority_badge.dart';
import 'package:internal_issue_tracking_portal/presentation/widgets/stat_card.dart';
import 'package:internal_issue_tracking_portal/presentation/widgets/status_chip.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 251, 1),
      appBar: const CommonAppBar(
        title: "Issue Dashboard",
        showLogout: true,
        useGradient: true,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1E40AF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const IssueDialog(),
            );
          },
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            "New Issue",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
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

  // 🔷 STATS CARDS
  Widget _buildStats(List docs) {
    final total = docs.length;
    final open = docs.where((e) => e["status"] != "Closed").length;
    final closed = docs.where((e) => e["status"] == "Closed").length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          StatCard(title: "Total", value: total.toString(), color: Colors.blue),
          const SizedBox(width: 12),
          StatCard(title: "Open", value: open.toString(), color: Colors.orange),
          const SizedBox(width: 12),
          StatCard(
              title: "Closed", value: closed.toString(), color: Colors.green),
        ],
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
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP ROW (Summary + Priority)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        issue["issueSummary"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PriorityBadge(
                      priority: getPriorityFromString(issue["priority"]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// Assignment ID
                Text(
                  issue.data().toString().contains("assignmentId")
                      ? issue["assignmentId"]
                      : "-",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                /// Customer & Technology
                Text(
                  "${issue["customer"]} • ${issue["technology"]}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                /// Assigned To
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      issue["assignedTo"] ?? "-",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// Dates Section
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Start: ${formatDateTime(issue["startDate"])}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.lock_clock, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Closed: ${formatDateTime(issue["closingDate"])}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// Bottom Row (Status + Edit)
                Row(
                  children: [
                    StatusChip(
                      status: getStatusFromString(issue["status"]),
                    ),
                    const Spacer(),

                    /// Edit Button
                    Tooltip(
                      message: "Edit Issue",
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => IssueDialog(issue: issue),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        // Card(
        //   color: Colors.white,
        //   elevation: 2,
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   child: Padding(
        //     padding: const EdgeInsets.all(16),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Row(
        //           children: [
        //             Expanded(
        //               child: Text(
        //                 issue["issueSummary"],
        //                 style: const TextStyle(
        //                     fontSize: 16, fontWeight: FontWeight.bold),
        //               ),
        //             ),
        //             PriorityBadge(
        //               priority: getPriorityFromString(issue["priority"]),
        //             )
        //           ],
        //         ),
        //         const SizedBox(height: 8),
        //         Text(
        //           "${issue["customer"]} • ${issue["technology"]}",
        //           style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        //         ),
        //         const SizedBox(height: 12),
        //         Row(
        //           children: [
        //             const StatusChip(
        //               status: IssueStatus.inProgress,
        //             ),
        //             const Spacer(),
        //             Tooltip(
        //               message: "Edit Issue",
        //               child: InkWell(
        //                 borderRadius: BorderRadius.circular(12),
        //                 onTap: () {
        //                   showDialog(
        //                     context: context,
        //                     builder: (_) => IssueDialog(issue: issue),
        //                   );
        //                 },
        //                 child: Container(
        //                   padding: const EdgeInsets.all(8),
        //                   decoration: BoxDecoration(
        //                     color: Colors.blue.withOpacity(0.08),
        //                     borderRadius: BorderRadius.circular(12),
        //                     border:
        //                         Border.all(color: Colors.blue.withOpacity(0.2)),
        //                   ),
        //                   child: const Icon(
        //                     Icons.edit_rounded,
        //                     size: 18,
        //                     color: Colors.blue,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         )
        //       ],
        //     ),
        //   ),
        // );
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

  IssuePriority getPriorityFromString(String priority) {
    switch (priority) {
      case "Low":
        return IssuePriority.low;
      case "Medium":
        return IssuePriority.medium;
      case "High":
        return IssuePriority.high;
      case "Critical":
        return IssuePriority.critical;
      default:
        return IssuePriority.low;
    }
  }

  IssueStatus getStatusFromString(String status) {
    switch (status) {
      case "New":
        return IssueStatus.newIssue;
      case "In Progress":
        return IssueStatus.inProgress;
      case "Resolved":
        return IssueStatus.resolved;
      case "Closed":
        return IssueStatus.closed;
      case "Waiting for Client":
        return IssueStatus.waitingForClient;
      default:
        return IssueStatus.newIssue;
    }
  }

  // 🔷 ISSUE DIALOG (Create + Edit)
}
