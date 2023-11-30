import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/book.dart';

Future<void> openBook(BuildContext context, Book book,
    List<String> _favoriteTitles, Future<List<Book>> _books) async {
  Dio dio = Dio();
  try {
    var dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/${book.title}.epub';
    await dio.download(book.downloadUrl, filePath);
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: book.title,
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: true,
    );
    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $locator');
    });

    VocsyEpub.open(filePath);

    // Add the book title to the list of favorites if not already added
    if (!_favoriteTitles.contains(book.title)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Livro aberto com sucesso: ${book.title}'),
        ),
      );
      _favoriteTitles.add(book.title);
      _saveFavorites(_favoriteTitles);
    }

    // Update the existing _books list with the new favorite status
    _books = _books.then((books) {
      return books.map((b) {
        if (b.title == book.title) {
          return Book(
            title: b.title,
            author: b.author,
            coverUrl: b.coverUrl,
            downloadUrl: b.downloadUrl,
            isFavorite: true,
          );
        }
        return b;
      }).toList();
    });
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao baixar e abrir o livro: $error'),
      ),
    );
    print('Erro ao baixar e abrir o livro: $error');
  }
}

void _saveFavorites(List<String> _favoriteTitles) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList('favorites', _favoriteTitles);
}
