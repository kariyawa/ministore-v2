import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('ic_launcher');
    var IOS = new IOSInitializationSettings();
    var settings = new InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings);
    _showNotificationWithDefaultSound(flip);
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(flip) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
  );
  await flip.show(0, 'Mise à jour',
      'Voir les mises à jour à faire',
      platformChannelSpecifics, payload: 'Default_Sound'
  );
}

main2(){
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false
  );
  Workmanager().registerPeriodicTask(
    "2",
    "simplePeriodicTask",
    frequency: Duration(minutes: 15),
  );
}

class G extends StatelessWidget {
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
        String versionAppInstalled;
        String v;


        for(int i=0; i<listInstalledApp.length; i++){
          String nameAppInstalled= listInstalledApp[i]["app_name"];
          v=listInstalledApp[i]["version_name"];
          versionAppInstalled= listInstalledApp[i]["version_name"].replaceAll('.', '');
          if(nameAppInstalled == nameAppFile){
            if(int.parse(versionAppInstalled) < int.parse(versionAppFileWithoutDot)){
              main2();
              installedAppsInFile.add({"app_name": nameAppFile, "package_name": "com.android.chrome", "url": url, "versionCode": null, "version_name": v, "check": "green"});
            }else{
              installedAppsInFile.add({"app_name": nameAppFile, "package_name": "com.android.chrome", "url": url, "versionCode": null, "version_name": v, "check": "red"});
            }
          }
        }

      }
    });

    print(installedAppsInFile);
  }

  List<Map<String, String>> installedApps;
  List<Map<String, String>> installedAppsInFile = [];

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

  Widget getIcon(index) {
    var monWidget;
    if (index == "green") {
      monWidget = new Icon(Icons.arrow_circle_up_sharp, color: Colors.black);
    }else if (index == "red"){
      monWidget = Icon(Icons.check_circle, color: Colors.green,);
    }
    return monWidget;
  }

  bool getPermission(index) {
    bool buttonDisabled1;
    if (index == "green") {
      buttonDisabled1 = true;
    }else if (index == "red"){
      buttonDisabled1 = false;
    }
    return buttonDisabled1;
  }


  getPermissionString(index) {
    String monWidget;
    if (index == "green") {
      monWidget = " (mise à jour disponible)";
    }else if (index == "red"){
      monWidget = "A jour";
    }
    return monWidget;
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
        itemCount: installedAppsInFile == null ? 0 : installedAppsInFile.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(installedAppsInFile[index]["app_name"]),
            subtitle: RichText(
              text: new TextSpan(style: new TextStyle(color: Colors.black,),
                children: <TextSpan>[
                  new TextSpan(text: installedAppsInFile[index]["version_name"]),
                  new TextSpan(text: getPermissionString(installedAppsInFile[index]["check"]), style: new TextStyle(color: Colors.red)),
                ],
              ),),
            trailing: IconButton(
                icon: getIcon(installedAppsInFile[index]["check"]),
                onPressed: () {
                  if(getPermission(installedAppsInFile[index]["check"])==true){
                    Scaffold.of(context).hideCurrentSnackBar();
                    launchURL(installedAppsInFile[index]["url"]).then((_) {
                      print("Appli ${installedAppsInFile[index]["app_name"]} lancé!");
                    }).catchError((err) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Appli ${installedAppsInFile[index]["app_name"]} n'est pas trouvée")
                      ));
                      print(err);
                    });
                  }
                }
            ),
          );
        },
      ),
    );
  }
}