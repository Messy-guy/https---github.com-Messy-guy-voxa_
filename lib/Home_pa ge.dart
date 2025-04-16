import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/ai_service.dart';
import 'package:voice_assistant/feature_box.dart';
import 'package:voice_assistant/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 final speechToText = SpeechToText(); 
 String lastWords = "";
 final aiService = AiService();
 final flutterTts = FlutterTts();
 String? generatedImageUrl;
  String? generatedContent;

int start = 300;
int delay = 400;


 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechtoText();
    initTTS();
  }

  Future<void> initTTS() async {
    await flutterTts.setSharedInstance(true);

  }

 void initSpeechtoText() async {
  bool available = await speechToText.initialize(
    onStatus: (status) async {
      print('✅ Speech status: $status');

      // When speech ends automatically (user stops talking)
      if (status == 'done') {
        final speech = await aiService.isArtPromptAPI(lastWords);
        if (speech.contains("data:image")) {
          generatedImageUrl = speech;
          generatedContent = null;
          setState(() {});
          await Systemspeak("Here is the image you requested.");
          print("🎨 Generated Image Data: $generatedImageUrl");
        } else {
          generatedContent = speech;
          generatedImageUrl = null;
          setState(() {});
          await Systemspeak(generatedContent!);
          print("💬 Generated Content: $generatedContent");
        }
      }
    },
    onError: (error) {
      print('❌ Speech error: ${error.errorMsg}');
    },
  );

  if (available) {
    print('🎤 Speech-to-Text initialized');
  } else {
    print('❌ Speech recognition not available');
  }
}



  Future<void> startListening() async {
  await speechToText.listen(
    onResult: onSpeechResult,
    listenFor: Duration(seconds: 10),
    pauseFor: Duration(seconds: 3),
    partialResults: false,
    localeId: 'en_US',
  );
  setState(() {});
}

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

 void onSpeechResult(SpeechRecognitionResult result) {
  setState(() {
    lastWords = result.recognizedWords;
  });
  print('🗣️ You said: ${result.recognizedWords}');
}

Future<void> Systemspeak(String content) async {
await flutterTts.speak(content);
}


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.scaffoldBackgroundColor,
      appBar: AppBar(
        title:  BounceInDown(child: Shimmer.fromColors(baseColor: Colors.black,
        highlightColor: Colors.white,
        child: Text("VOXA",style:
        TextStyle(
          fontFamily: 'Cera Pro',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: Pallete.mainFontColor,
        )
        ,))),
        centerTitle: true,
        leading : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu button press
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: EdgeInsets.only(top:20),
                      decoration: BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage("assets/images/virtualAssitant.png")),
                    ),
                  )
                ],
              ),
            ),
            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    )
                  ),
                  child: Text( generatedContent == null ? "Good Morning! How can I help you today?": generatedContent!,style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontSize: generatedContent==null ?25 : 17,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cero Pro'
                  ),),
                ),
              ),
            ),
            if (generatedImageUrl != null && generatedImageUrl!.startsWith('data:image')) 
     Image.memory(
    base64Decode(generatedImageUrl!.split(',').last),
    width: 300,
    height: 300,
    fit: BoxFit.contain,
  ),
            SlideInLeft(
              child: Visibility(
                visible: generatedImageUrl == null && generatedContent == null,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 20,left: 20),
                  child: const Text("Here are some suggestions:",style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cero Pro'
                  ),),
                ),
              ),
            ),
            //suggestion boxes
            SizedBox(
              height: 20,
            ),
            Visibility(
              visible:generatedImageUrl == null && generatedContent == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: "Chatgpt",
                      descriptionText: "A smarter way to stay organized and informed with ChatGPT",
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+delay),
                    child: FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: "Dall-E",
                      descriptionText: "Get inspired and stay creative with your personal assistant powered by Dall-E",
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+2*delay),
                    child: FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: "Smart Voice Assistant",
                      descriptionText: "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        child: FloatingActionButton(
        onPressed: () async {
  bool hasPermission = await speechToText.hasPermission;
  print("🎤 hasPermission: $hasPermission");
  print("🎤 isListening: ${speechToText.isListening}");

  if (!hasPermission) {
    initSpeechtoText(); // Re-initialize if not permitted
    return;
  }

  if (!speechToText.isListening) {
    // Start listening
    await startListening();
  } else {
    // Stop listening and handle response
    await stopListening();

    final speech = await aiService.isArtPromptAPI(lastWords);
    if (speech.contains("data:image")) {  // Changed from contains("https://")
      generatedImageUrl = speech;
      generatedContent = null;
      setState(() {});
      await Systemspeak("Here is the image you requested.");
      print("🎨 Generated Image Data: $generatedImageUrl");
    } else {
      generatedContent = speech;
      generatedImageUrl = null;
      setState(() {});
      await Systemspeak(generatedContent!);
      print("💬 Generated Content: $generatedContent");
    }
  }
},
          child: Icon(speechToText.isListening? Icons.stop :Icons.mic),
          backgroundColor: const Color.fromARGB(255, 229, 235, 237),
        ),
      ),
    );
  }
}