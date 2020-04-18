class Geeta {
  final int book;
  final int chapter;
  final int verse;
  final String nepali;
  final String sanskrit;
  final String english;
  final int color;
  Geeta(
      {this.book,
      this.chapter,
      this.verse,
      this.nepali,
      this.sanskrit,
      this.english,
      this.color});
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
  // @override
  // String toString() {
  //   return 'Geeta{book:$book, chapter:$chapter,verse:$verse}';
  // }
}