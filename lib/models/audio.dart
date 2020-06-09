class MyAudio {
final int chapter;
final int download;
final int id;
const MyAudio({this.chapter,this.download,this.id});
 Map<String, dynamic> toMap() {
    return {
      'chapter': chapter,
      'id': id,
    };
  }
}