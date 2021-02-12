import 'package:ai_radio/model/radio.dart';
import 'package:ai_radio/utils/ai_util.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }

      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "74e2c81e6c61b0137716cc72ff0f7b642e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(colors: [
                  AIColors.primaryColor2,
                  _selectedColor ?? AIColors.primaryColor1
                ], begin: Alignment.topLeft, end: Alignment.bottomRight))
                .make(),
            AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.purple300, secondaryColor: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ).h(100.0).p16(),
            radios != null
                ? VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: 1.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index) {
                      final colorHex = radios[index].color;
                      _selectedColor = Color(int.tryParse(colorHex));
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final rad = radios[index];

                      return VxBox(
                              child: ZStack([
                        Positioned(
                            top: 0,
                            right: 0,
                            child: VxBox(
                                    child: rad.category.text.uppercase.white
                                        .make()
                                        .px16())
                                .height(40)
                                .black
                                .alignCenter
                                .withRounded(value: 10)
                                .make()),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make()
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: [
                              Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "Double tap to play".text.gray300.make()
                            ].vStack())
                      ]))
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)))
                          .border(color: Colors.black, width: 5)
                          .withRounded(value: 60)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    }).centered()
                : Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white)),
            Align(
                    alignment: Alignment.bottomCenter,
                    child: [
                      if (_isPlaying)
                        "Playing Now - ${_selectedRadio.name} FM"
                            .text
                            .white
                            .makeCentered(),
                      Icon(
                              _isPlaying
                                  ? CupertinoIcons.stop_circle
                                  : CupertinoIcons.play_circle,
                              color: Colors.white,
                              size: 50)
                          .onInkTap(() {
                        if (_isPlaying) {
                          _audioPlayer.stop();
                        } else {
                          _playMusic(_selectedRadio.url);
                        }
                      })
                    ].vStack())
                .pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
        ));
  }
}
