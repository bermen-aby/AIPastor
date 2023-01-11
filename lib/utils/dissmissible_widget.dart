import 'package:flutter/material.dart';

class DissmissibleWidget<T> extends StatelessWidget {
  const DissmissibleWidget({
    required this.child,
    required this.item,
    required this.onDismissed,
    Key? key,
  }) : super(key: key);
  final Widget child;
  final T item;
  final DismissDirectionCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: onDismissed,
      key: ObjectKey(item),
      background: _buildLeftSwipeAction(),
      child: child,
    );
  }

  Widget _buildLeftSwipeAction() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
