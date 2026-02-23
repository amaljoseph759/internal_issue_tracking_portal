import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDateTime(Timestamp? timestamp) {
  if (timestamp == null) return "-";
  final date = timestamp.toDate();
  return DateFormat('dd MMM yyyy • hh:mm a').format(date);
}
