import 'package:flutter/material.dart';

/// Five tappable stars. [value] is 0 when the user has not rated yet.
class RatingInput extends StatelessWidget {
  const RatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        IconButton(
          tooltip: '$i од',
          iconSize: size,
          color: Colors.amber,
          icon: Icon(i <= value ? Icons.star : Icons.star_border),
          onPressed: () => onChanged(i),
        ),
    ],
  );
}
