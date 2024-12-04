import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget> with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late AnimationController _controllerRotation;
  late AnimationController _controllerPulse;
  late AnimationController _controllerClouds;
  late AnimationController _controllerFloatAway;

  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotation;
  late Animation<double> _animationPulse;
  late Animation<double> _animationClouds;
  late Animation<double> _animationFloatAway;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controllerFloatUp = AnimationController(duration: Duration(seconds: 8), vsync: this);
    _controllerGrowSize = AnimationController(duration: Duration(seconds: 4), vsync: this);
    _controllerRotation = AnimationController(duration: Duration(seconds: 8), vsync: this);
    _controllerPulse = AnimationController(duration: Duration(seconds: 1), vsync: this)..repeat(reverse: true);
    _controllerClouds = AnimationController(duration: Duration(seconds: 10), vsync: this)..repeat(reverse: true);
    _controllerFloatAway = AnimationController(duration: Duration(seconds: 1),vsync: this);
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotation.dispose();
    _controllerPulse.dispose();
    _controllerClouds.dispose();
    _controllerFloatAway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / 2;
    double _balloonWidth = MediaQuery.of(context).size.height / 3;
    double _balloonBottomLocation = MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
        CurvedAnimation(parent: _controllerFloatUp, curve: Curves.easeInOut) //curve improvement
    );

    _animationGrowSize = Tween(begin: 50.0, end: _balloonWidth).animate(
        CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeInOut) //curve improvement
    );
    _animationRotation = Tween(begin: 1.5, end: 0.1).animate(
        CurvedAnimation(parent: _controllerRotation, curve: Curves.easeInOut)
    );
    _animationPulse = Tween(begin: 0.5, end: 1.05).animate(
        CurvedAnimation(parent: _controllerPulse, curve: Curves.easeInOut)
    );
    _animationClouds = Tween(begin: -1.0, end: 1.5).animate(
        CurvedAnimation(parent: _controllerClouds, curve: Curves.easeInOut)
    );
    _animationFloatAway = Tween(begin: 0.0, end: -MediaQuery.of(context).size.height).animate(
        CurvedAnimation(parent: _controllerFloatAway, curve: Curves.easeInOut)
    );

    _controllerFloatUp.forward();
    _controllerGrowSize.forward();
    _controllerRotation.forward();

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationClouds, //Background animation
          builder: (context, child) {
            return Positioned(
              top: 50.0,
              left: _animationClouds.value * MediaQuery.of(context).size.width,
              child: Image(
                image: NetworkImage('assets/images/bird1.png'),
                width: 200.0,
                height: 100.0,
              ),
            );
          },
        ),
        ...List.generate(3, (index) { //Multiple balloon
          return AnimatedBuilder(
            animation: _animationFloatUp,
            builder: (context, child) {
              return Transform.scale(
                scale: _animationPulse.value,
                child: Transform.rotate(
                  angle: _animationRotation.value + (index * 0.1), // Slightly varied rotation
                  child: ClipRRect( // Clip the child with rounded corners
                    borderRadius: BorderRadius.circular(_balloonWidth / 4), // Adjust as needed
                    child: Container( // Container for additional properties
                      child: child,
                      margin: EdgeInsets.only(
                        top: _animationFloatUp.value + (index * 200), // Slightly varied position
                      ),
                      width: _animationGrowSize.value,
                      decoration: BoxDecoration(  //balloon texture
                        gradient: LinearGradient(
                          colors: [Colors.redAccent, Colors.orangeAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [ //balloon shadow
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                if (_controllerFloatUp.isCompleted) {
                  _controllerFloatUp.reverse();
                  _controllerGrowSize.reverse();
                  _controllerRotation.reverse();
                  _controllerPulse.reverse();
                  _controllerFloatAway.forward().then((_){ //sequentail animation balloon float away
                    _controllerFloatAway.reverse();
                  });
                } else {
                  _controllerFloatUp.forward();
                  _controllerGrowSize.forward();
                  _controllerRotation.forward();
                  _controllerPulse.forward();
                }
              },
              child: InteractiveViewer( //user interaction
                maxScale: 5.0,
                minScale: 0.01,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: Image.asset(
                  'assets/images/balloon2.png',
                  height: _balloonHeight,
                  width: _balloonWidth,
                ),
              ),
            ),
          );
        }),
        Center(
          child: ElevatedButton( //sound effect
            child: Text('Sound Effect'),
            onPressed: () {
              _audioPlayer.play('assets/audio/sound.wav');
            },
          ),
        ),
      ],
    );
  }
}

