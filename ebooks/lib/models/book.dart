class Book {
  final String title;
  final String coverUrl;
  final String downloadUrl;
  bool isFavorite;
  
  Book({
    required this.title, 
    required this.coverUrl, 
    required this.downloadUrl,
    this.isFavorite = false});
}
