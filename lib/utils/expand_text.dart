import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ExpandText extends StatefulWidget {
  const ExpandText(
      {super.key, required this.labelHeader, this.desc, this.shortDesc});

  final String labelHeader;
  final String? desc;
  final String? shortDesc;

  @override
  State<ExpandText> createState() => _ExpandTextState();
}

class _ExpandTextState extends State<ExpandText> {
  bool descTextShowFlag = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelHeader,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          HtmlWidget(
            descTextShowFlag ? widget.desc! : widget.shortDesc!,
            textStyle: const TextStyle(fontSize: 16.5),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  descTextShowFlag = !descTextShowFlag;
                });
              },
              child: Text(
                descTextShowFlag ? "reduce" : "read more",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
