import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Vocabulary {
  final String word;
  final String type;
  final String definition;
  final String usage;

  Vocabulary({this.word, this.type, this.definition, this.usage});

  String toString() {
    return "Word: $word, price: $type, today gain: $definition";
  }

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
        word: json['Word'],
        type: json['Type'],
        definition: json['Definition'],
        usage: json['Usage']);
  }
}

Future<List<Vocabulary>> fetchVocabulary() async {
  final response = await http.get('http://192.168.0.17:8081/',
      headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var list = json.decode(response.body) as List;
    List<Vocabulary> vocabularys =
        list.map((e) => Vocabulary.fromJson(e)).toList();
    return vocabularys;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to fetch vocabulary');
  }
}

void main() => runApp(MyHomePage());

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Vocabulary>> futureVocabulary;

  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    futureVocabulary = fetchVocabulary();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
        title: 'iSpell',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            body: FutureBuilder<List<Vocabulary>>(
                future: futureVocabulary,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final double height = MediaQuery.of(context).size.height;
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: height,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                      ),
                      items: snapshot.data
                          .map((v) => Container(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                    Text((v.word + ' (' + v.type + ')'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold)),
                                    Text(('Definition: ' + v.definition),
                                        style: TextStyle(fontSize: 20)),
                                    Text(('Usage: ' + v.usage),
                                        style: TextStyle(fontSize: 20))
                                  ])))
                          .toList(),
                    );
                  }
                  // By default, show a loading spinner.
                  return Center(child: CircularProgressIndicator());
                })));
  }
}
