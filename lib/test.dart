import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:http/http.dart' as http;

class Test extends MaterialApp {
  @override
  Widget get home => HomeScreen();
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("Installed Apps"),
                subtitle: Text(
                    "Get installed apps on device. With options to exclude system app, get app icon & matching package name prefix."),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InstalledAppsScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class InstalledAppsScreen extends StatelessWidget {

  AsyncSnapshot<List<AppInfo>> snapshot;
  //Map data = Map<int, String>();
  List appFileData;
  Future getData() async {
    print(snapshot.hasData);
      List<AppInfo> apps = await InstalledApps.getInstalledApps();
      print(apps);


  }


  List<Map<String, String>> installedAppsInFile = [];
  List<Map<String, String>> iOSApps = [
    {
      "app_name": "Calendar",
      "package_name": "calshow://"
    },
    {
      "app_name": "Facebook",
      "package_name": "fb://"
    },
    {
      "app_name": "Whatsapp",
      "package_name": "whatsapp://"
    }
  ];

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true),
        builder:
            (BuildContext buildContext, AsyncSnapshot<List<AppInfo>> snapshot) {
          return snapshot.connectionState == ConnectionState.done ? snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        AppInfo app = snapshot.data[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image.memory(app.icon),
                            ),
                            title: Text(app.name),
                            subtitle: Text(app.getVersionInfo()),
                            onTap: () =>
                                InstalledApps.startApp(app.packageName),
                            onLongPress: () =>
                                InstalledApps.openSettings(app.packageName),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                          "Error occurred while getting installed apps ...."))
              : Center(child: Text("Getting installed apps ...."));
        },
      ),
    );
  }
}
