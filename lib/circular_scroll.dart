library circular_scroll;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that scrolls the list in a circular motion.
class CircularScroll extends StatefulWidget {

  /// assign the same ScrollController to the child widget.
  final ScrollController scrollController;

  /// The widget below this widget in the tree.
  final Widget child;

  /// If the button argument is null, the CircularScroll will use [DefaultButton].
  final Widget? button;

  /// If the tracker argument is null, the CircularScroll will use [DefaultTracker].
  final Widget? tracker;

  /// If the isProvideHapticFeedBack is true, The widget provide HapticFeedBack in a circular motion.
  /// [HapticFeedback.selectionClick()] is provided.
  final bool isProvideHapticFeedback;
  const CircularScroll(
      {super.key,
      required this.scrollController,
      required this.child,
      this.button,
      this.tracker,
      this.isProvideHapticFeedback = false});
  @override
  State<StatefulWidget> createState() {
    return _CircularScrollState();
  }
}

class _CircularScrollState extends State<CircularScroll> {
  Offset? _origin;
  Offset? _start;
  Offset _position = Offset(100, 100);

  double _angle = 0.0;
  String _direction = '';
  bool isOnPan = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        GestureDetector(
          onPanStart: (details) {
            setState(() {
              isOnPan = true;
            });
            print('onPanStart');
          },
          onPanEnd: (details) {
            setState(() {
              _start = null;
              _origin = null;
              isOnPan = false;
            });
            print('onPanEnd');
          },
          onPanUpdate: (details) {
            setState(() {
              _position = details.globalPosition;
              print(_position);
            });
            if (_origin == null) {
              _origin = details.globalPosition;
              return;
            }

            if (_start == null) {
              _start = details.globalPosition;
              return;
            }
            if (_start != null) {
              final end = details.globalPosition;
              final angle = crossProduct(_origin!, _start!, end);
              // print("$_origin, $_start, ${details.delta}, $angle");

              if (angle > 5) {
                print('right');
                widget.scrollController.position.moveTo(
                  widget.scrollController.offset + 25,
                );
                _origin = _start;
                _start = end;

              } else if (angle < -5) {
                // print('left');
                _origin = _start;
                _start = end;
                widget.scrollController.position.moveTo(
                  widget.scrollController.offset - 25,
                );

              } else {
                return;
              }
              if (widget.isProvideHapticFeedback) _provideHapticFeedback();
            }
          },
          child: Stack(
            children: [
              if (!isOnPan)
                Positioned(
                  // 真ん中
                  left: MediaQuery.of(context).size.width / 2 - 25,
                  bottom: 50,
                  child: widget.button ??
                      const DefaultButton(),
                ),
            ],
          ),
        ),
        if (isOnPan)
          widget.tracker ??
              Positioned(
                left: _position.dx,
                top: _position.dy,
                child: const DefaultTracker(),
              ),
      ],
    );
  }
}

class DefaultTracker extends StatelessWidget {
  const DefaultTracker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset:
                Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
    );
  }
}

class Vector2 {
  final double x, y;

  Vector2(this.x, this.y);

  @override
  String toString() {
    return '($x, $y)';
  }
}

double crossProduct(Offset oa, Offset ob, Offset oc) {
  final Offset ab = Offset(ob.dx - oa.dx, ob.dy - oa.dy);
  final Offset ac = Offset(oc.dx - oa.dx, oc.dy - oa.dy);
  return ab.dx * ac.dy - ab.dy * ac.dx;
}

void _provideHapticFeedback() {
  HapticFeedback.selectionClick();
}