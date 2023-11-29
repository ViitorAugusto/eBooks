import 'package:flutter/material.dart';

class BookViewer extends StatelessWidget {
  final String filePath;

  const BookViewer({required this.filePath, required Key viewerKey})
      : super(key: viewerKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador de Livros'),
      ),
      body: BookViewer(
        filePath: filePath,
        viewerKey: UniqueKey(),
      ),
    );
  }
}
