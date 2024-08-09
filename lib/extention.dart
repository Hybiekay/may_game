extension ConvertToUserName on String {
  String toUserName() {
    var splittedValue = split("@");
    String username = splittedValue[0];
    String value = username.length > 10 ? username.substring(0, 11) : username;

    return value;
  }
}
