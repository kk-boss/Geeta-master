class MyAudio {
int chapter;
int download;
int id;
MyAudio({this.chapter,this.download,this.id});
 Map<String, dynamic> toMap() {
    return {
      'chapter': chapter,
      'id': id,
    };
  }
}