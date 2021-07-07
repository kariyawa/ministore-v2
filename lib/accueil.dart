import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'g.dart';
import 'gpas.dart';

class Accueil extends StatefulWidget {
  @override
  _CustomTabBarDemoState createState() => _CustomTabBarDemoState();
}

class _CustomTabBarDemoState extends State<Accueil> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length:list.length, vsync: this);// initialise it here
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> list = [
    Tab(icon: Icon(Icons.list, color: Colors.white)),
    Tab(icon: Icon(Icons.download_outlined, color: Colors.white)),
  ];

  textStyle() {
    return TextStyle(color: Colors.black, fontSize:20.0);
  }

  Widget getTabBar() {
    return TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(icon: Icon(Icons.list, color: Colors.white)),
          Tab(icon: Icon(Icons.download_outlined, color: Colors.white)),
        ]);
  }

  Widget getTabBarPages() {
    return TabBarView(controller: _tabController, children: <Widget>[
      G(),
      Gpas(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(icon: Icon(Icons.list, color: Colors.white)),
              Tab(icon: Icon(Icons.download_outlined, color: Colors.white)),
            ]),
        title: Image.asset('assets/images/unknown.png', width: MediaQuery.of(context).size.width,),
        backgroundColor: Color.fromRGBO(197, 19, 53, 1),
        toolbarHeight: 120,
      ),
        body: getTabBarPages()

    );
  }
}