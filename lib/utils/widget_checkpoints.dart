import 'package:flutter/material.dart';

class Checkpoints extends StatelessWidget {
  final int checkedTill;
  final List<String> checkpoints;
  final Color checkpointFilledColor;
  const Checkpoints({
    super.key,
    this.checkedTill = 1,
    required this.checkpoints,
    required this.checkpointFilledColor,
  });

  double get circleDia => 32;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, s) {
        final double cwidth = (s.maxWidth - (32.0 * (checkpoints.length + 1))) /
            (checkpoints.length - 1);
        return SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: checkpoints.map((e) {
                    final int index = checkpoints.indexOf(e);
                    return SizedBox(
                      height: circleDia,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: circleDia,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index <= checkedTill
                                  ? checkpointFilledColor
                                  : checkpointFilledColor.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          if (index != (checkpoints.length - 1))
                            Container(
                              color: index < checkedTill
                                  ? checkpointFilledColor
                                  : checkpointFilledColor.withOpacity(0.2),
                              height: 4,
                              width: cwidth,
                            )
                          else
                            Container()
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: checkpoints.map((e) {
                    return Text(
                      e,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
