//check String and make sure they are of "+234xxxx" format else convert to that format
extension StringExtension on String {
  String formatPhoneNumber() {
    if (startsWith('+234')) {
      return this;
    } else if (startsWith('0')) {
      return '+234${substring(1)}'; //prepend +234 to the string if it doesn't start with +234
    } else if (startsWith('234')) {
      return '+$this'; //prepend +234 to the string if it doesn't start with +234
    } else {
      return '+234$this'; //prepend +234 to the string if it doesn't start with +234
    }
  }
}
