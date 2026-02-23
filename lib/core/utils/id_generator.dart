import 'dart:math';

class IdGenerator {
  static String generateAssignmentId() {
    final random = Random();

    // Generate 2 random capital letters
    String letters = String.fromCharCode(random.nextInt(26) + 65) +
        String.fromCharCode(random.nextInt(26) + 65);

    // Generate 3 random digits
    int numbers = random.nextInt(900) + 100;

    return "$letters-$numbers";
  }
}
