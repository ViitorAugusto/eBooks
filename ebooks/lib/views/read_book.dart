import 'dart:async';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class ReadBookPage extends StatelessWidget {
  final String filePath; // Caminho do arquivo EPUB

  ReadBookPage(this.filePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitura do Livro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.pop(context); // Retorna à estante de livros
            },
          ),
        ],
      ),
      body: EpubView(
        controller: EpubController(
          document: EpubReader.readBook(filePath as FutureOr<List<int>>),
        ),
      ),
    );
  }
}
