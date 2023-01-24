import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomStepper extends StatefulWidget {
  CustomStepper({
    required this.lowerLimit,
    required this.upperLimit,
    required this.value,
    required this.iconSize,
    required this.stepValue,
    required this.onChanged,
  });

  final int lowerLimit;
  final int upperLimit;
  final int stepValue;
  final double iconSize;
  int value;
  final ValueChanged<dynamic> onChanged;

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 118,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            //color: Theme.of(context).shadowColor,
            blurRadius: 0.5,
            spreadRadius: 0.2,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove,
              color: Colors.black,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                widget.value = widget.value == widget.lowerLimit
                    ? widget.lowerLimit
                    : widget.value -= widget.stepValue;

                widget.onChanged(widget.value);
              });
            },
          ),
          SizedBox(
            width: widget.iconSize,
            child: Text(
              '${widget.value}',
              style: const TextStyle(fontSize: 20 * 0.8, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.black,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                widget.value = widget.value == widget.upperLimit
                    ? widget.upperLimit
                    : widget.value += widget.stepValue;

                widget.onChanged(widget.value);
              });
            },
          ),
        ],
      ),
    );
  }
}
