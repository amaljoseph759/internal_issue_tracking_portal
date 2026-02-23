import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internal_issue_tracking_portal/core/utils/id_generator.dart';

class IssueDialog extends StatefulWidget {
  final DocumentSnapshot? issue;

  const IssueDialog({super.key, this.issue});

  @override
  State<IssueDialog> createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController processController;
  late TextEditingController assignedController;
  late TextEditingController summaryController;
  late TextEditingController actionController;

  String customer = "Ecocash";
  String technology = "UiPath";
  String priority = "Low";
  String status = "New";
  String rootCause = "Unknown";

  DateTime? selectedClosingDate;

  @override
  void initState() {
    super.initState();

    final issue = widget.issue;

    processController = TextEditingController(text: issue?["processName"]);
    assignedController = TextEditingController(text: issue?["assignedTo"]);
    summaryController = TextEditingController(text: issue?["issueSummary"]);
    actionController = TextEditingController(text: issue?["actionTaken"]);

    if (issue != null) {
      customer = issue["customer"] ?? customer;
      technology = issue["technology"] ?? technology;
      priority = issue["priority"] ?? priority;
      status = issue["status"] ?? status;
      rootCause = issue["rootCauseCategory"] ?? rootCause;

      if (issue["closingDate"] != null) {
        selectedClosingDate = (issue["closingDate"] as Timestamp).toDate();
      }
    }
  }

  @override
  void dispose() {
    processController.dispose();
    assignedController.dispose();
    summaryController.dispose();
    actionController.dispose();
    super.dispose();
  }

  Future<void> _pickClosingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedClosingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedClosingDate = picked;
      });
    }
  }

  Future<void> _saveIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final collection = FirebaseFirestore.instance.collection("issues");

    final assignmentId = widget.issue == null
        ? IdGenerator.generateAssignmentId()
        : widget.issue!["assignmentId"];

    final data = {
      "assignmentId": assignmentId,
      "customer": customer,
      "processName": processController.text.trim(),
      "technology": technology,
      "priority": priority,
      "assignedTo": assignedController.text.trim(),
      "status": status,
      "issueSummary": summaryController.text.trim(),
      "rootCauseCategory": rootCause,
      "actionTaken": actionController.text.trim(),
      "closingDate": selectedClosingDate != null
          ? Timestamp.fromDate(selectedClosingDate!)
          : null,
      "updatedAt": Timestamp.now(),
    };

    if (widget.issue == null) {
      final doc = collection.doc();
      await doc.set({
        "issueId": doc.id,
        ...data,
        "startDate": Timestamp.now(),
        "createdAt": Timestamp.now(),
      });
    } else {
      await collection.doc(widget.issue!.id).update(data);
    }

    setState(() => _isLoading = false);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.issue != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEdit ? "Edit Issue" : "Create Issue",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// FORM FIELDS
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildDropdown(
                                "Customer",
                                customer,
                                [
                                  "Ecocash",
                                  "Econet",
                                  "CWS",
                                  "EMM",
                                  "EthioTelecom"
                                ],
                                (val) => setState(() => customer = val)),
                            _buildTextField(processController, "Process Name"),
                            _buildDropdown(
                                "Technology",
                                technology,
                                [
                                  "Power Automate Cloud",
                                  "PAD",
                                  "UiPath",
                                  "SQL",
                                  "SharePoint",
                                  "Other"
                                ],
                                (val) => setState(() => technology = val)),
                            _buildDropdown(
                                "Priority",
                                priority,
                                ["Low", "Medium", "High", "Critical"],
                                (val) => setState(() => priority = val)),
                            _buildTextField(assignedController, "Assigned To"),
                            _buildDropdown(
                                "Status",
                                status,
                                [
                                  "New",
                                  "In Progress",
                                  "Waiting for Client",
                                  "Resolved",
                                  "Closed"
                                ],
                                (val) => setState(() => status = val)),
                            _buildTextField(summaryController, "Issue Summary",
                                maxLines: 2),
                            _buildDropdown(
                                "Root Cause",
                                rootCause,
                                [
                                  "Infra",
                                  "Code Bug",
                                  "Data Issue",
                                  "Credentials",
                                  "Business Change",
                                  "Access",
                                  "Unknown"
                                ],
                                (val) => setState(() => rootCause = val)),
                            _buildTextField(actionController, "Action Taken",
                                maxLines: 2),
                            _buildDateField(),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _saveIssue,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isEdit ? "Update" : "Create"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    // Dialog(
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(24),
    //   ),
    //   child: Container(
    //     padding: const EdgeInsets.all(39),
    //     width: MediaQuery.of(context).size.width * 0.7,
    //     child: Form(
    //       key: _formKey,
    //       child: SingleChildScrollView(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             /// HEADER
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Text(
    //                   isEdit ? "Edit Issue" : "Create Issue",
    //                   style: const TextStyle(
    //                     fontSize: 22,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 IconButton(
    //                   onPressed: () => Navigator.pop(context),
    //                   icon: const Icon(Icons.close),
    //                 ),
    //               ],
    //             ),

    //             const SizedBox(height: 24),

    //             /// FORM FIELDS
    //             Wrap(
    //               spacing: 20,
    //               runSpacing: 20,
    //               children: [
    //                 _buildDropdown(
    //                     "Customer",
    //                     customer,
    //                     ["Ecocash", "Econet", "CWS", "EMM", "EthioTelecom"],
    //                     (val) => setState(() => customer = val)),
    //                 _buildTextField(processController, "Process Name"),
    //                 _buildDropdown(
    //                     "Technology",
    //                     technology,
    //                     [
    //                       "Power Automate Cloud",
    //                       "PAD",
    //                       "UiPath",
    //                       "SQL",
    //                       "SharePoint",
    //                       "Other"
    //                     ],
    //                     (val) => setState(() => technology = val)),
    //                 _buildDropdown(
    //                     "Priority",
    //                     priority,
    //                     ["Low", "Medium", "High", "Critical"],
    //                     (val) => setState(() => priority = val)),
    //                 _buildTextField(assignedController, "Assigned To"),
    //                 _buildDropdown(
    //                     "Status",
    //                     status,
    //                     [
    //                       "New",
    //                       "In Progress",
    //                       "Waiting for Client",
    //                       "Resolved",
    //                       "Closed"
    //                     ],
    //                     (val) => setState(() => status = val)),
    //                 _buildTextField(summaryController, "Issue Summary",
    //                     maxLines: 2),
    //                 _buildDropdown(
    //                     "Root Cause",
    //                     rootCause,
    //                     [
    //                       "Infra",
    //                       "Code Bug",
    //                       "Data Issue",
    //                       "Credentials",
    //                       "Business Change",
    //                       "Access",
    //                       "Unknown"
    //                     ],
    //                     (val) => setState(() => rootCause = val)),
    //                 _buildTextField(actionController, "Action Taken",
    //                     maxLines: 2),
    //                 _buildDateField(),
    //               ],
    //             ),

    //             const SizedBox(height: 30),

    //             /// BUTTONS
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 OutlinedButton(
    //                   onPressed: () => Navigator.pop(context),
    //                   child: const Text("Cancel"),
    //                 ),
    //                 const SizedBox(width: 12),
    //                 ElevatedButton(
    //                   onPressed: _isLoading ? null : _saveIssue,
    //                   style: ElevatedButton.styleFrom(
    //                     padding: const EdgeInsets.symmetric(
    //                         horizontal: 30, vertical: 16),
    //                     shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(12)),
    //                   ),
    //                   child: _isLoading
    //                       ? const SizedBox(
    //                           height: 18,
    //                           width: 18,
    //                           child: CircularProgressIndicator(
    //                             strokeWidth: 2,
    //                             color: Colors.white,
    //                           ),
    //                         )
    //                       : Text(isEdit ? "Update" : "Create"),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return SizedBox(
      width: 350,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (val) =>
            val == null || val.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String) onChanged) {
    return SizedBox(
      width: 350,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => onChanged(val ?? value),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return SizedBox(
      width: 350,
      child: InkWell(
        onTap: _pickClosingDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedClosingDate == null
                      ? "Select Closing Date"
                      : DateFormat('dd MMM yyyy').format(selectedClosingDate!),
                  style: TextStyle(
                    color: selectedClosingDate == null
                        ? Colors.grey
                        : Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
