import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:url_launcher/url_launcher.dart';

class Gpas extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAppE(),
    );
  }
}
class MyAppE extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyAppE> {
  Map data = Map<int, String>();
  List appFileData;

  Future getData() async {
    final listInstalledApp= await getApps();
    http.Response response = await http.get(Uri.parse("https://cm2.cmconnect.fr/version/dataapp.json"));
    data = json.decode(response.body);
    setState(() {

      appFileData = data["data"];
      for(int i=0; i<appFileData.length; i++){
        String nameAppFile= appFileData[i]["NomApp"];
        String versionAppFile= appFileData[i]["IdVersion"];
        String versionAppFileWithoutDot= appFileData[i]["IdVersion"].replaceAll('.', '');
        String url= appFileData[i]["url"];

        bool drapeau=false;
        for(int i=0; i<listInstalledApp.length; i++){
          String nameAppInstalled= listInstalledApp[i]["app_name"];
          String versionAppInstalled= listInstalledApp[i]["version_name"].replaceAll('.', '');
          if(nameAppInstalled == nameAppFile){
            drapeau=true;
          }
        }

        if (drapeau == false){
          notInstalledAppsInFile.add({"app_name": nameAppFile, "package_name": "com.android.chrome", "url": url, "versionCode": null, "version_name": versionAppFile});
        }
      }
    });
    print(notInstalledAppsInFile);
  }

  List<Map<String, String>> installedApps;
  List<Map<String, String>> notInstalledAppsInFile = [];

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<List<Map<String, String>>> getApps() async {
    List<Map<String, String>> _installedApps;

    if (Platform.isAndroid) {
      _installedApps = await AppAvailability.getInstalledApps();

    }

    setState(() {
      installedApps = _installedApps;
    });

    return installedApps;
  }

  launchURL(String url) async {
    if (await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (installedApps == null)
      getData();


    return Scaffold(
      body: ListView.builder(
        itemCount: notInstalledAppsInFile == null ? 0 : notInstalledAppsInFile.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notInstalledAppsInFile[index]["app_name"]),
            subtitle: Text(notInstalledAppsInFile[index]["version_name"]),
            trailing: IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () {
                  Scaffold.of(context).hideCurrentSnackBar();
                  launchURL(notInstalledAppsInFile[index]["url"]).then((_) {
                    print("Appli ${notInstalledAppsInFile[index]["app_name"]} lancé!");
                  }).catchError((err) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Appli ${notInstalledAppsInFile[index]["app_name"]} n'est pas trouvée")
                    ));
                    print(err);
                  });
                }
            ),
          );
        },
      ),
    );
  }
}