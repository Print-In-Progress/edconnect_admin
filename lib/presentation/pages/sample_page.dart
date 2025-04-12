import 'package:flutter/material.dart';

class SamplePage extends StatefulWidget {
  final String title;
  const SamplePage({super.key, this.title = 'Sample Page'});

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Text(widget.title),
    );
  }
}
