import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Vocabulary {
  final String word;
  final String type;
  final String definition;

  Vocabulary({this.word, this.type, this.definition});

  String toString() {
    return "Word: $word, price: $type, today gain: $definition";
  }

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      word: json['Word'],
      type: json['Type'],
      definition: json['Definition'],
    );
  }
}

Future<List<Vocabulary>> fetchVocabulary() async {
  final response =
  await http.get('http://192.168.0.15:8081/', headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var list = json.decode(response.body) as List;
    List<Vocabulary> vocabularys = list.map((e) => Vocabulary.fromJson(e)).toList();
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
  int _index = 0;

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

  void _handlePageChange(int index) => setState(() => _index = index);

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
          appBar: AppBar(centerTitle: true, title: new Text(_index.toString(),)),
          body: FutureBuilder<List<Vocabulary>>(
              future: futureVocabulary,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Vocabulary v = snapshot.data[_index];
                  return PageView.builder(
                    itemBuilder: (context, position) {
                      return Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text((v.word + ' (' + v.type + ')'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                              Text(('Definition: ' + v.definition),
                                  style: TextStyle(fontSize: 20))]),
                      );
                    },
                    itemCount: snapshot.data.length,
                    controller: _controller,
                    onPageChanged: _handlePageChange,
                  );}
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              })
        )
    );
  }
}
