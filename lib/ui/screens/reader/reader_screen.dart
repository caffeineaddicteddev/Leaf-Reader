import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
        actions: const <Widget>[
          Icon(Icons.content_copy_outlined),
          SizedBox(width: 16),
          Icon(Icons.share_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: const Color(0xFFF8F7F4),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SingleChildScrollView(
            child: Text(
              'The concept of digital archiving has evolved significantly over the past decade.\n\n'
              'What once began as simple cloud storage has transformed into an intelligent ecosystem '
              'capable of semantic understanding.\n\n'
              'In this manuscript, we explore the convergence of Optical Character Recognition (OCR) '
              'and Large Language Models. By treating every scanned pixel as a potential data point, '
              'we bridge the gap between physical paper and actionable intelligence.\n\n'
              'Key Findings:\n'
              '1. Precision is non-negotiable in architectural documentation.\n'
              '2. Latency remains the primary hurdle for mobile-first deployments.\n'
              '3. The aesthetic of the interface directly correlates with user trust in the underlying algorithm.\n',
              style: TextStyle(
                fontSize: 18,
                height: 1.7,
                color: Color(0xFF2C2C2A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
