class Notifications {
  final String title;
  final String body;

  Notifications({this.title, this.body});

  Map<String, dynamic> toMap(){
    return {
      'title': title,
      'body': body,
    };
  }
}