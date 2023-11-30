import 'package:flutter/material.dart';
import '../models/book.dart';

class BookGrid extends StatelessWidget {
  final List<Book> books;
  final Function(Book) onToggleFavorite;
  final Function(Book) onOpenBook;
  final Function(Book) onDownloadBook;

  BookGrid({
    super.key,
    required this.books,
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
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Image.network(
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
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                book.author,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey[900],
                ),
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
                ),
            ],
          ),
        );
      },
    );
  }
}
