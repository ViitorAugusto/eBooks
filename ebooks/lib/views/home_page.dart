import 'dart:async';
import 'package:ebooks/utils/book_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../services/book_open_service.dart';
import '../services/book_downloadBook_service.dart';
import '../widgets/book_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<Book>> _books;
  TabController? _tabController;
  List<String> _favoriteTitles = [];
  bool _isViewingBook = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _books = BookService.fetchBooks();
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteTitles = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _toggleFavorite(Book book) async {
    setState(() {
      if (_tabController!.index == 1) {
        if (book.isFavorite) {
          book.isFavorite = false;
          _books = _books.then((books) {
            books.remove(book);
            return Future.value(List.from(books));
          });
        }
      } else {
        book.isFavorite = !book.isFavorite;
      }
      _saveFavorites();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favoriteTitles);
  }

  Future<void> _downloadBook(Book book) async {
    downloadBook(context, book);
  }

  Future<void> _openBook(Book book) async {
    openBook(context, book, _favoriteTitles, _books);
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
                return BookGrid(
                  books: snapshot.data!,
                  onToggleFavorite: _toggleFavorite,
                  onOpenBook: _openBook,
                  onDownloadBook: _downloadBook,
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
                final List<Book> favoriteBooks =
                    snapshot.data!.where((book) => book.isFavorite).toList();

                return BookGrid(
                  books: favoriteBooks,
                  onToggleFavorite: _toggleFavorite,
                  onOpenBook: _openBook,
                  onDownloadBook: _downloadBook,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
