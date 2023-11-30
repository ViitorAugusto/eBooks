import 'dart:async';
import 'package:flutter/widgets.dart' as flutter;
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/book.dart';
import '../models/book_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<Book>> _books;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _books = BookService.fetchBooks();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _openBook(Book book) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      String filePath = '${dir.path}/${book.title}.epub';
      await dio.download(book.downloadUrl, filePath);

      // Remova a linha abaixo
      // EpubBook epubBook = await EpubReader.readBook(File(filePath).readAsBytesSync());

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

      // Corrija esta linha para passar o caminho do arquivo (String)
      VocsyEpub.open(filePath);

      // Após fechar a visualização do livro, recarregue a lista de livros caso esteja na aba de Favoritos
      if (_tabController!.index == 1) {
        setState(() {
          _books = BookService.fetchBooks();
        });
      }
    } catch (error) {
      final snackBar = SnackBar(
        content: Text('Erro ao baixar e abrir o livro: $error'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      print('Erro ao baixar e abrir o livro: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Estante de Livros',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[800],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.grey[300],
          tabs: const [
            Tab(
              text: 'Livros',
            ),
            Tab(text: 'Favoritos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<Book>>(
            future: _books,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Nenhum livro encontrado.');
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.only(top: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final book = snapshot.data![index];
                    return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 16.0), // Espaçamento inferior
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                        color: book.isFavorite
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          book.isFavorite = !book.isFavorite;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              book.title,
                              textAlign: TextAlign
                                  .center, // Alinhamento centralizado do texto
                            ),
                          ],
                        ));
                  },
                );
              }
            },
          ),

          // Conteúdo para a aba 'Favoritos'
          FutureBuilder<List<Book>>(
            future: _books,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Nenhum livro favorito encontrado.');
              } else {
                // Filtrar os livros marcados como favoritos
                final List<Book> favoriteBooks =
                    snapshot.data!.where((book) => book.isFavorite).toList();

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
                                      color: book.isFavorite
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (_tabController!.index == 1) {
                                          if (book.isFavorite) {
                                            book.isFavorite = false;
                                            _books = _books.then((books) {
                                              books.remove(book);
                                              return Future.value(
                                                  List.from(books));
                                            });
                                          }
                                        } else {
                                          book.isFavorite = !book.isFavorite;
                                        }
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          book.title,
                          textAlign: TextAlign
                              .center, // Alinhamento centralizado do texto
                        ),
                        if (book.isFavorite)
                          IconButton(
                            icon: const Icon(Icons.file_download_outlined),
                            onPressed: () {
                              _openBook(book);
                            },
                          )
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
