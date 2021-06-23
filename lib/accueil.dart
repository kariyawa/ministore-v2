import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ministore/test.dart';

import 'g.dart';
import 'gpas.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => new _AccueilState();
}

class _AccueilState extends State<Accueil> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget getTabBar() {
    return TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(icon: Icon(Icons.list, color: Colors.white)),
          Tab(icon: Icon(Icons.download_outlined, color: Colors.white)),
        ]);
  }

  Widget getTabBarPages() {
    return TabBarView(controller: tabController, children: <Widget>[
      G(),
      Gpas(),
    ]);
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text("Êtes-vous sûr de vouloir quitter l'application?"),
        content: new Text("Voulez-vous quitter l'application?"),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Non'), ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Oui'),
          ),
        ],
      ),
    ) ?? false;
  }


  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop:_onWillPop,
        child: new Scaffold(
          appBar: new AppBar(
            toolbarHeight: 60,
            centerTitle: true,
            title: new Container(
              height: 50.0,
              width: 70.0,
            ),
            backgroundColor: Color.fromRGBO(197, 19, 53, 1),
            flexibleSpace: SafeArea(
              child: getTabBar(),
            ),
          ),
          body: getTabBarPages(),
        ));
  }
}