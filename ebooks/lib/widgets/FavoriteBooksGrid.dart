import 'package:ebooks/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter;

class FavoriteBooksGrid extends StatelessWidget {
  final List<Book> favoriteBooks;
  final Function(Book) onToggleFavorite;
  final Function(Book) onOpenBook;
  final Function(Book) onDownloadBook;

  const FavoriteBooksGrid({
    super.key,
    required this.favoriteBooks,
    required this.onToggleFavorite,
    required this.onOpenBook,
    required this.onDownloadBook,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: favoriteBooks.length,
      itemBuilder: (context, index) {
        final book = favoriteBooks[index];

        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  flutter.Image.network(
                    book.coverUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: -12,
                    right: -12,
                    child: IconButton(
                      icon: Icon(
                        book.isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: book.isFavorite ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        onToggleFavorite(book);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Text(
              book.title,
              textAlign: TextAlign.center,
            ),
            if (book.isFavorite)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye),
                    onPressed: () {
                      onOpenBook(book);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    onPressed: () {
                      onDownloadBook(book);
                    },
                  ),
                ],
              )
          ],
        );
      },
    );
  }
}
