class Geeta {
  final int book;
  final int chapter;
  final int verse;
  final String nepali;
  final String sanskrit;
  final String english;
  final int color;
  final int isBookmark;
  Geeta(
      {this.book,
      this.chapter,
      this.verse,
      this.nepali,
      this.sanskrit,
      this.english,
      this.color,
      this.isBookmark});
  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'nepali': nepali,
      'sanskrit': sanskrit,
      'english': english,
    };
  }
}