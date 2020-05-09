import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';

import 'model/Planet.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin{
  Animation<Offset> animationPlanet;
  Animation<Offset> animationBullet;

  AnimationController animationController;
  AnimationController animationController2;

  int bullet = 5;

  int planetindex = 0;
  double shipx = 0.0;
  double bulletx = -0.5;

  bool BulletAnime = true;
  bool shootmove = true;
  bool lost = true;
  double bulletLastMove = 0.00;
  bool onetime = true;
  Animation<double> animation3;
  AnimationController controller;
  AudioCache cache = AudioCache();

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
        reverseDuration: Duration(seconds: 1));
    animationController2 =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    animationPlanet = Tween<Offset>(begin: Offset(-0.65, 0), end: Offset(0.65, 0))
        .animate(animationController);
    animationBullet = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -10.8))
        .animate(animationController2);

    void get() {
      print(animationBullet.value.dy);
      setState(() {});
      if (animationBullet.value.dy < -7) {
        if (animationBullet.value.dy < -9.5) {
        } else {
          if (animationPlanet.value.dx.isNegative && bulletLastMove.isNegative) {
            setState(() {
              if (onetime) {
                playLocalAsset();
                BulletAnime = true;
                onetime = false;
                _planet.removeAt(0);
              }
              Future.delayed(Duration(seconds: 1), () {
                onetime = true;
              });
            });
          } else if (!animationPlanet.value.dx.isNegative &&
              !bulletLastMove.isNegative) {
            setState(() {
              if (onetime) {
                playLocalAsset();
                BulletAnime = true;
                onetime = false;
                _planet.removeAt(0);
              }
              Future.delayed(Duration(seconds: 1), () {
                onetime = true;
              });
            });
          }
        }
      }
    }

    animationBullet.addListener(get);

    animationPlanet.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    animationBullet.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController2.reset();

        setState(() {
          bulletx = shipx;
          shootmove = true;
          BulletAnime = true;
        });
      }
    });
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (shootmove) {
      bulletx = shipx;
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/game_bg.png'),
                    fit: BoxFit.cover)),
          ),
          Positioned(
            top: size.height * 0.05,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Games made by me",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: size.height * 0.05,
              right: size.width * 0.01,
              child: SizedBox(
                height: size.height * 0.05,
                width: size.width * 0.2,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _planet.length,
                    itemBuilder: (_, index) {
                      return index == 0
                          ? SizedBox()
                          : Image.asset(
                        _planet[index].Image,
                      );
                    }),
              )),
          lost
              ? _planet.isNotEmpty
              ? Align(
            alignment: AlignmentDirectional(0.0, -0.8),
            child: SlideTransition(
                position: animationPlanet,
                child: Container(
                  height: size.height * 0.28,
                  width: size.width * 0.44,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_planet[planetindex].Image),
                      )),
                  child: Center(
                      child: Text(
                        _planet[planetindex].name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                )),
          )
              : Positioned.fill(
              child: Center(
                child: Text(
                  "You Win!",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ))
              : Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Game Over",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            bullet = 5;
                            lost = true;
                          });
                        },
                        child: Text(
                          "Replay",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              )),
          Align(
              alignment: AlignmentDirectional(shipx, 0.7),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_planet.isNotEmpty) {
                        if (bullet > 0) {
                          animationController2.forward();
                          BulletAnime = false;
                          bullet = bullet - 1;
                        } else {
                          lost = false;
                        }
                      }

                      shootmove = false;
                    });
                  },
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0) {
                      setState(() {
                        shipx = shipx + 0.017;
                        bulletLastMove = bulletLastMove + 0.20;
                        if (shootmove) {
                          bulletx = bulletx + 0.020;
                        } else {}
                      });
                    } else {
                      setState(() {
                        shipx = shipx - 0.017;
                        bulletLastMove = bulletLastMove - 0.20;
                      });
                    }
                  },
                  child: Image.asset(
                    "assets/ship.png",
                    height: size.height * 0.15,
                    width: size.width * 0.15,
                  ))),
          BulletAnime
              ? SizedBox()
              : Align(
            alignment: AlignmentDirectional(bulletx, 0.7),
            child: SlideTransition(
              position: animationBullet,
              child: Container(
                height: size.height * 0.09,
                width: size.width * 0.04,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/fire.png'),
                    )),
              ),
            ),
          ),
          lost
              ? Positioned(
            bottom: size.height * 0,
            right: size.width * 0.01,
            child: Transform.rotate(
                angle: 90 * 3.14159265359 / 180,
                child: SizedBox(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: bullet,
                      itemBuilder: (_, index) {
                        return Image.asset(
                          "assets/ship.png",
                          width: size.width * 0.04,
                        );
                      }),
                )),
          )
              : SizedBox()
        ],
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    animationController2.dispose();
    super.dispose();
  }

  List<Planet> _planet = [
    Planet("First", "assets/planet_1.png"),
    Planet("Second", "assets/planet_2.png"),
    Planet("Third", "assets/planet_3.png"),
  ];

  Future<AudioPlayer> playLocalAsset() async {
    return await cache.play("bomb.mp3");
  }
}
