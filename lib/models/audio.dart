class Audio {
  final int id;
  final int download;
  const Audio({this.id, this.download});
  Map<String, dynamic> toMap() {
    return {
      'download': download,
      'id': id,
    };
  }
}
