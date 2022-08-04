import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
// import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quitsmoke/comps/cigaratte.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/constants.dart';
import 'package:quitsmoke/screens/guideview_screen.dart';
import 'package:quitsmoke/static/lang.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:shake/shake.dart';
import 'package:alan_voice/alan_voice.dart';

import '../size_config.dart';

class GuideScreen extends StatefulWidget {
  GuideScreen({Key key, this.cigaratteManager}) : super(key: key);
  final Cigaratte cigaratteManager;

  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  String lang = "";
  List<Widget> cards = [];
  final controller = ScrollController();
  double offset = 0;
  String searchtext = "";

  // stt.SpeechToText _speech;
  //stt.SpeechToText _speechG;
  // bool _isListening = false;
  ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    AlanSetup();
    // _speech = stt.SpeechToText();
    //_speechG = stt.SpeechToText();
    lang = getLang();

    setCards();

    controller.addListener(onScroll);

    detector = ShakeDetector.autoStart(onPhoneShake: () {
      print("shake it daddy");
      // print((langs[lang]["guide"].keys.toList()..shuffle()).first);
      // Navigator.push(context, MaterialPageRoute(builder: (_) {
      //   return GuideViewScreen(
      //       id: (langs[lang]["guide"].keys.toList()..shuffle()).first,
      //       lang: Platform.localeName.split("_")[0]);
      // }));

      _activate();
    });

    //_speak("Welcome to the Guide! How may i help you?");
    //_listenG();
  }

  AlanSetup() {
    AlanVoice.addButton(
        "d6e8bda17acc96d68d9af832ef4073252e956eca572e1d8b807a3e2338fdd0dc/stage");
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "random":
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return GuideViewScreen(
              id: (langs[lang]["guide"].keys.toList()..shuffle()).first,
              lang: Platform.localeName.split("_")[0]);
        }));
        break;
      case "return":
        Navigator.of(context).pop();
        break;
      case "search":
        searchtext = response["text"];

        // setCards();
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  /// Activate Alan Button programmatically
  void _activate() {
    AlanVoice.activate();
  }

  /// Deactivate Alan Button programmatically
  void _deactivate() {
    AlanVoice.deactivate();
  }

  /// Play any text via Alan Button
  void _playText(String s) {
    /// Provide text as string param
    AlanVoice.playText(s);
  }

  setCards() {
    cards = [];
    langs[lang]["guide"].forEach((k, v) => {
          if (v["title"].toLowerCase().contains(searchtext.toLowerCase()))
            cards.add(createCard(v, k)),
        });
    setState(() {});
  }

  // speak function
  // final FlutterTts flutterTts = FlutterTts();
  // Future _speak(String hell) async {
  //   await flutterTts.setVolume(1.0);
  //   //await print("pressed");
  //   //await print(content[1]["text"].toString());
  //   //await flutterTts.speak(content[1]["text"].toString());
  //   await flutterTts.speak(hell);
  // }

  @override
  void dispose() {
    controller.dispose();
    detector.stopListening();
    super.dispose();
    _deactivate();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  // void _listen() async {
  //   // _speak("Hello there, how can i help");
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) => print('onStatus: $val'),
  //       onError: (val) => print('onStatus: $val'),
  //     );
  //     if (available) {
  //       setState(() {
  //         _isListening = true;
  //       });
  //       _speech.listen(
  //         onResult: (val) => setState(() {
  //           searchtext = val.recognizedWords;
  //           if (val.finalResult) {
  //             _speak("Here's what i found for " + searchtext);
  //           }
  //           setCards();
  //         }),
  //       );
  //       _isListening = false;
  //     } else {
  //       setState(() {
  //         _isListening = false;
  //       });
  //       _speech.stop();
  //     }
  //   }
  // }

  // void _listenG() async {
  //   if (!_isListening) {
  //     bool available = await _speechG.initialize(
  //       onStatus: (val) => print('onStatus: $val'),
  //       onError: (val) => print('onStatus: $val'),
  //     );
  //     if (available) {
  //       setState(() {
  //         _isListening = true;
  //       });
  //       _speechG.listen(
  //         onResult: (val) => setState(() {
  //           searchtext = val.recognizedWords;
  //           if (val.finalResult) {
  //             _speak("Here's what i found for " + searchtext);
  //           }
  //         }),
  //       );
  //     } else {
  //       setState(() {
  //         _isListening = false;
  //       });
  //       _speechG.stop();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(context),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(context, offset),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: TextFormField(
                        onChanged: (value) {
                          searchtext = value;
                          setCards();
                        },
                        decoration: new InputDecoration(
                          labelText: langs[lang]["guideps"]["search"],
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.search),
                          ),
                          // suffixIcon: Padding(
                          //   padding: EdgeInsets.all(2),
                          //   child: AvatarGlow(
                          //     animate: _isListening,
                          //     glowColor: Theme.of(context).primaryColor,
                          //     endRadius: 2,
                          //     duration: const Duration(milliseconds: 2000),
                          //     repeatPauseDuration:
                          //         const Duration(milliseconds: 100),
                          //     repeat: true,
                          //     child: FloatingActionButton(
                          //       onPressed: _listen,
                          //       child: Icon(_isListening
                          //           ? Icons.mic
                          //           : Icons.mic_none),
                          //     ),
                          //   ),
                          // )
                          //fillColor: Colors.green
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      langs[lang]["guideps"]["guides"],
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: getProportionateScreenWidth(22),
                          color: Colors.black),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [for (Widget i in cards) i],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ClipPath buildHeader(BuildContext context, double offset) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(left: 40, top: 30, right: 20),
        height: getProportionateScreenHeight(350),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 223, 153, 230),
                Color.fromARGB(255, 147, 13, 141)
              ]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: (offset < 0) ? 0 : offset,
                    child: SvgPicture.asset("assets/images/lungs.svg",
                        width: getProportionateScreenWidth(130),
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter),
                  ),
                  Positioned(
                    top: (offset < 0)
                        ? 0
                        : offset + getProportionateScreenWidth(40),
                    left: getProportionateScreenWidth(140),
                    child: Text(
                      langs[lang]["guideps"]["guideto"],
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          color: Colors.white,
                          fontSize: getProportionateScreenWidth(32)),
                    ),
                  ),
                  Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createCard(Map i, String id) {
    print(i["content"][0]["text"].runtimeType == [].runtimeType);
    return PreventCard(
      text: i["content"][0]["text"][0].length == 1
          ? i["content"][0]["text"]
          : i["content"][0]["text"][0],
      image: i["image"],
      title: i["title"],
      id: id,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFD66D75),
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Hero(
            tag: "guide",
            child: Icon(
              Icons.book,
              color: Colors.white,
              size: getProportionateScreenWidth(26),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${langs[lang]["home"]["guide"]}",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Colors.white, fontSize: getProportionateScreenWidth(26)),
          )
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  final String id;
  const PreventCard({Key key, this.image, this.title, this.text, this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) {
        print(id);
        return GuideViewScreen(id: id, lang: Platform.localeName.split("_")[0]);
      })),
      child: Ink(
        child: SizedBox(
          height: 170,
          width: SizeConfig.screenWidth * .85,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Positioned(
                left: getProportionateScreenWidth(12),
                child: Container(
                  height: 136,
                  width: SizeConfig.screenWidth * .8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 8),
                        blurRadius: 12,
                        color: kShadowColor.withAlpha(40),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: getProportionateScreenWidth(16),
                child: Hero(tag: image, child: SvgPicture.asset(image)),
                width: getProportionateScreenWidth(100),
              ),
              Positioned(
                left: getProportionateScreenWidth(130),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  height: 136,
                  width: getProportionateScreenWidth(200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            fontSize: getProportionateScreenWidth(16),
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: AutoSizeText(
                          text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
