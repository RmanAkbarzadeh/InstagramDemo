import 'package:flutter/material.dart';

class StoryBar extends StatefulWidget {
  final Animation<double> _animationController;
  final int storyLength;
  final int index;
  final int _currentIndex;

  StoryBar(this._animationController, this.storyLength, this.index,
      this._currentIndex);

  static bool isInit = false;

  @override
  _StoryBarState createState() => _StoryBarState();
}

class _StoryBarState extends State<StoryBar> {

  int myIndex = 0 ;



  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    if(widget._animationController.value < 0.95 && widget._animationController.value != 0.0) {
      myIndex = widget._currentIndex;
    }
    if(widget._animationController.value > 0.95){
      setState(() {
        myIndex=widget._currentIndex+1;
      });
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: ((deviceSize.width - (6*widget.storyLength)) / widget.storyLength),
            height: 2,
            decoration: BoxDecoration(
                border: widget.index < myIndex
                    ? Border.all(width: 1, color: Colors.white)
                    : Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (widget._currentIndex == widget.index)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: ((deviceSize.width - (6*widget.storyLength)) /
                  widget.storyLength)*
                  widget._animationController.value,
              height: 2,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(10)),
            ),
          )
      ],
    );
  }
}
