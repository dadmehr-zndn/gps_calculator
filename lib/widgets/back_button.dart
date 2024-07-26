import 'package:flutter/material.dart';
import 'package:snapp_sample/constants/constants.dart';

class SnappBackButton extends StatelessWidget {
  SnappBackButton({
    required this.onPressed,
    super.key,
  });

  Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: Dimens.medium,
      left: Dimens.medium,
      child: SizedBox(
        width: 45,
        height: 45,
        child: FloatingActionButton(
          onPressed: onPressed,
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
