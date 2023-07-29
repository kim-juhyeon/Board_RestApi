// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class DismissibleItem extends StatelessWidget {
  final int keyId;
  final Widget child;
  final Function(int) onDismissed;

  DismissibleItem({
    Key? key,
    required Container background,
    required DismissDirection direction,
    required this.keyId,
    required this.child,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(keyId),
      background: Container(color: Colors.green),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => onDismissed(keyId),
      child: child,
    );
  }
}
