import 'package:flutter/material.dart';

class ReusableItemAppBar extends PopupMenuEntry<dynamic> {
  final VoidCallback onTap;
  final IconData icon;
  final String text;

  const ReusableItemAppBar({
    super.key,
    required this.onTap,
    required this.icon,
    required this.text,
  });

  @override
  double get height => kMinInteractiveDimension;

  @override
  bool represents(dynamic value) => false;

  @override
  State<StatefulWidget> createState() => _ReusableItemAppBarState();
}

class _ReusableItemAppBarState extends State<ReusableItemAppBar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.black),
            const SizedBox(width: 10),
            Text(widget.text),
          ],
        ),
      ),
    );
  }
}
