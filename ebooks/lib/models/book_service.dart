import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book.dart';

class BookService {
  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('https://escribo.com/books.json'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((bookData) {
        return Book(
          title: bookData['title'],
          coverUrl: bookData['cover_url'],
          downloadUrl: bookData['download_url'],
        );
      }).toList();
    } else {
      throw Exception('Falha ao carregar livros');
    }
  }
}
