import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';

Future<void> downloadBook(BuildContext context, Book book) async {
  Dio dio = Dio();
  try {
    var dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/${book.title}.epub';
    await dio.download(book.downloadUrl, filePath);
    final snackBar = SnackBar(
      content: Text('Livro baixado com sucesso: ${book.title}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } catch (error) {
    final snackBar = SnackBar(
      content: Text('Erro ao baixar o livro: $error'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Erro ao baixar o livro: $error');
  }
}
