class Book {
  final String title;
  final String coverUrl;
  final String downloadUrl;
  final String author;
  bool isFavorite;
  
  Book({
    required this.title, 
    required this.coverUrl, 
    required this.downloadUrl,
    required this.author,
    this.isFavorite = false});
}
