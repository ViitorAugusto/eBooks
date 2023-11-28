// views/home_page.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Book>> _books;

  @override
  void initState() {
    super.initState();
    _books = BookService.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Estante de Livros'),
      ),
      body: FutureBuilder<List<Book>>(
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final book = snapshot.data![index];
                return Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(book.title),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
