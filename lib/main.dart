import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESports LOL',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "VFŞL",
            style: new TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black54,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(70, 70, 70, 1),
        body: new Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Lane(
                    player: 1,
                  ),
                  Lane(
                    player: 6,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Lane(
                    player: 2,
                  ),
                  Lane(
                    player: 7,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Lane(
                    player: 3,
                  ),
                  Lane(
                    player: 8,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Lane(
                    player: 4,
                  ),
                  Lane(
                    player: 9,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Lane(
                    player: 5,
                  ),
                  Lane(
                    player: 10,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Lane extends StatefulWidget {
  Lane({this.player});
  final int player;
  LaneState createState() => LaneState(player: player);
}

class LaneState extends State<Lane> {
  LaneState({this.player});
  var player;
  var tge = 0;
  var gold = 0;
  var hero = "", name = "", champ = "";
  var kill = 0, die = 0, assists = 0, cs = 0, lvl = 0;
  updater() async {
    var now = new DateTime.now()
        .subtract(new Duration(seconds: 25))
        .toUtc()
        .toIso8601String();
    now = now.substring(0, 18) + "0.000Z";
    var request2 = await HttpClient().getUrl(Uri.parse(
        'https://feed.lolesports.com/livestats/v1/details/103495781305002083?startingTime=$now&participantIds=$player'));
    // sends the request
    var response2 = await request2.close();

    // transforms and prints the response
    await for (var contents in response2.transform(Utf8Decoder())) {
      //  print(contents);
      if (tge ==
          json.decode(contents)["frames"][0]["participants"][0]
              ["totalGoldEarned"]) {
        continue;
      }
      tge = json.decode(contents)["frames"][0]["participants"][0]
          ["totalGoldEarned"];
      for (var i = 0; i < json.decode(contents)["frames"].length; i++) {
        setState(() {
          gold = json.decode(contents)["frames"][i]["participants"][0]
              ["totalGoldEarned"];
          kill = json.decode(contents)["frames"][i]["participants"][0]["kills"];
          die = json.decode(contents)["frames"][i]["participants"][0]["deaths"];
          assists =
              json.decode(contents)["frames"][i]["participants"][0]["assists"];
          cs = json.decode(contents)["frames"][i]["participants"][0]
              ["creepScore"];
          lvl = json.decode(contents)["frames"][i]["participants"][0]["level"];
        });
      }
    }
  }

  setNames() async {
    var request2 = await HttpClient().getUrl(Uri.parse(
        'https://feed.lolesports.com/livestats/v1/window/103495781305002083'));
    // sends the request
    var response2 = await request2.close();
    await for (var contents in response2.transform(Utf8Decoder())) {
      setState(() {
        name = json.decode(contents)["gameMetadata"]
                    [player < 6 ? "blueTeamMetadata" : "redTeamMetadata"]
                ["participantMetadata"][player < 6 ? player - 1 : player - 6]
            ["summonerName"];
        champ = json.decode(contents)["gameMetadata"]
                    [player < 6 ? "blueTeamMetadata" : "redTeamMetadata"]
                ["participantMetadata"][player < 6 ? player - 1 : player - 6]
            ["championId"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var timer =
        Timer.periodic(new Duration(seconds: 10), (Timer timer) => {updater()});
    setNames();
    return Container(
      width: width / 2,
      padding: EdgeInsets.only(bottom: 20, left: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(50, 50, 50, 1))),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              "$name",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 16),
            ),
            margin: new EdgeInsets.all(10),
          ),
          Row(
            children: <Widget>[
              new Container(
                margin: EdgeInsets.only(top: 5),
                child: Badge(
                    badgeContent: Text(
                      "$lvl",
                      style: new TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    badgeColor: Colors.black38,
                    child: new CircleAvatar(
                      child: ClipOval(
                        child: Image.network(
                          "http://ddragon.leagueoflegends.com/cdn/10.3.1/img/champion/$champ.png",
                          fit: BoxFit.cover,
                          scale: 3.10,
                        ),
                      ),
                      radius: 20.0,
                      backgroundColor: (player > 5)
                          ? Colors.red
                          : Color.fromRGBO(0, 255, 210, 1),
                    )),
              ),
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      "K/D/A : $kill/$die/$assists",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      "Minyon : $cs",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      "Altın : $gold",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
