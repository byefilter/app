import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:nacotavpn/block/vpn_block.dart';
import 'package:nacotavpn/block/vpn_event.dart';
import 'package:nacotavpn/block/vpn_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/vpn_service.dart';
import 'mywidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:installed_apps/installed_apps.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String ServerName = "Select Server";
  String ActiveServer = "";
  String ConfigUrl = "";
  String username = "Null";
  String password = "Null";
  late final bloc = context.read<VpnBlock>();
  late Timer timer;
  bool isad=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    timer = Timer.periodic(Duration(seconds: 5), (_) {
      context.read<VpnBlock>().add(IpVpn());
    });
  }

  Future<void> openPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Server()),
    );

    if (result != null) {
      setState(() {
        ServerName = result["name"];
        ActiveServer = result["active"];
        ConfigUrl = result["url"];
        username = result["user"];
        password = result["pass"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF050609),
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsetsGeometry.only(top: 5),
            child: Row(
              children: [
                Icon(Icons.shield, color: Color(0xFF5B7FFF), size: 54),
                SizedBox(width: 5),
                Text(
                  'ByeFilter',
                  style: TextStyle(
                    color: Color(0xFFffffff),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/settings");
                  },
                  child: Container(
                    width: 42,
                    height: 41,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: Color(0xFF403737),
                    ),
                    child: Icon(
                      Icons.settings,
                      size: 30,
                      color: Color(0xFFffffff),
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              SizedBox(height: 30),
              Container(
                height: 65,
                padding: EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF403737),
                ),
                child: GestureDetector(
                  onTap: openPage,
                  child: Text(
                    ServerName,
                    style: TextStyle(
                      color: Color(0xFFffffff),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 70),
              BlocBuilder<VpnBlock, VpnState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () async {
                      if (ConfigUrl == "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Server not selected'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // final file = await VpnService().downloadConfig(
                        //   "https://ik.imagekit.io/frsktypfv6/AL.ovpn",
                        // );

                        final file = await VpnService().downloadConfig(
                          ConfigUrl,
                        );

                        // print(file.path);
                        // print(await file.exists());

                        // final config = await file.readAsString();

                        // debugPrint(config);

                        final conf = await file.readAsString();

                        // await VpnService().connect(
                        //   config: conf,
                        //   username: username,
                        //   password: password,
                        // );

                        if (state is Vpndisconnected) {
                          context.read<VpnBlock>().add(
                            ConnetcVpn(
                              conf: conf,
                              username: username,
                              password: password,
                            ),
                          );
                        }
                        // print(state);
                        if (state != Vpndisconnected) {
                          context.read<VpnBlock>().add(DisconectVpn());
                          print("dis : $state");
                        }
                      }
                    },
                    child: connectbtn(
                      type: state is Vpndisconnected
                          ? "Connect"
                          : state is Vpnconnecting
                          ? "Connecting..."
                          : "Connected",
                      color: state is Vpndisconnected
                          ? Color(0xFFffffff)
                          : Color(0xFF42F207),
                    ),
                  );
                },
              ),

              SizedBox(height: 50),
              BlocListener<VpnBlock, VpnState>(
                listenWhen: (previous, current) {
                  return previous !=current;
                },
                listener: (context, state) {
                  if(state is Vpnconnected && isad==false){
                    Navigator.pushNamed(context, "/ad");
                    isad=true;
                  }
                },
                child: BlocBuilder<VpnBlock, VpnState>(
                  builder: (context, state) {
                    if (state is Vpnconnected) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: detail(
                              name: "POROTOCOL",
                              Value: state.porotocol == "TCP"
                                  ? state.porotocol
                                  : "UDP",
                            ),
                          ),
                          SizedBox(width: 35),
                          Expanded(
                            child: detail(name: "IP", Value: state.ip),
                          ),
                        ],
                      );


                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: detail(name: "POROTOCOL", Value: ""),
                        ),
                        SizedBox(width: 35),
                        Expanded(
                          child: detail(name: "IP", Value: ""),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              BlocBuilder<LogBlock, LogState>(
                builder: (context, state) {
                  print(state);
                  if (state is Log) {
                    print("state ${state.logs}");
                    return LogWidget(logs: state.logs);
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Server extends StatefulWidget {
  const Server({super.key});

  @override
  State<Server> createState() => _ServerState();
}

class _ServerState extends State<Server> {
  @override
  void initState() {
    // TODO: implement initState

    context.read<ServerBlock>().add(ServerFetch());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF050609),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF050609),
          title: Text(
            "Select Server",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<ServerBlock, ServerState>(
          builder: (context, state) {
            if (state is ServerInitial) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is ServerFetched) {
              return ListView.builder(
                itemCount: state.servers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        "name": state.servers[index]["name"],
                        "active": state.servers[index]["name"],
                        "url": state.servers[index]["config_url"],
                        "user": state.servers[index]["username"],
                        "pass": state.servers[index]["password"],
                      });
                    },
                    child: Container(
                      height: 65,
                      padding: EdgeInsets.only(left: 14, top: 6),
                      margin: EdgeInsets.all(8),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Color(0xFF403737),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF808080)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            state.servers[index]["icon_url"],
                            width: 60,
                            height: 30,
                          ),
                          SizedBox(height: 2),
                          Text(
                            state.servers[index]["name"],
                            style: TextStyle(
                              color: Color(0xFFffffff),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050609),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Column(
          children: [
            BlocListener<SetingBlock,SetingState>(
              listener: (context, state) {

                if(state is SetingDone){
                  if(state.isversion==true){

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Update is avaliable")));
                  }
                }

              },
              child: BlocBuilder<SetingBlock, SetingState>(
                builder: (context, state) {
                  if (state is InitialSeting) {

                    return CircularProgressIndicator();
                  }

                  if (state is SetingDone) {

                    return GestureDetector(onTap: (){
                      context.read<SetingBlock>().add(checkversion());
                    },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 115,
                        decoration: BoxDecoration(
                          color: Color(0xFF403737),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF808080)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xFF403737),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Color(0xFF808080)),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.arrowsRotate,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Check for Updates",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "check if a new version is available",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFBDBDBD),
                                        fontSize: 10,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsetsGeometry.all(2),
                                      alignment: Alignment.center,
                                      width: 120,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF403737),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Color(0x50D754E8),
                                        ),
                                      ),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        "Current version 1.0.0",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFCD42E3),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },

              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/about");
              },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 115,
                decoration: BoxDecoration(
                  color: Color(0xFF403737),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF808080)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF403737),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF808080)),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.info,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "About Us",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Learn more about ByrFilter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBDBDBD),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(onTap: () async {
              await launchUrl(
              Uri.parse(
                "https://github.com/byefilter/app",
              ),
              mode: LaunchMode.externalApplication,
              );
            },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 115,
                decoration: BoxDecoration(
                  color: Color(0xFF403737),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF808080)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF403737),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF808080)),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.github,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Github Project",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "View source code on Github",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBDBDBD),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/split");
              },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 115,
                decoration: BoxDecoration(
                  color: Color(0xFF403737),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF808080)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF403737),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF808080)),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.codeBranch,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Splite Tunneling",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Choose apps to bypass Vpn",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBDBDBD),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/donate");
              },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 115,
                decoration: BoxDecoration(
                  color: Color(0xFF403737),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF808080)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF403737),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF808080)),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.handHoldingDollar,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Donte",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Donate for Support",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBDBDBD),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050609),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'AboutUs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.shield, size: 75, color: Color(0xFF5B7FFF)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bye",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "Filter",
                      style: TextStyle(
                        color: Color(0xFFEB91D6),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Secure. Fast. Unlimited",
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsetsGeometry.all(2),
                  alignment: Alignment.center,
                  width: 88,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color(0xFF403737),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0x50D754E8)),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    "version 1.0.0",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCD42E3),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF403737),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF808080)),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Column(
                  children: [
                    aboutitem(
                      icon: Icon(
                        Icons.shield,
                        size: 35,
                        color: Color(0x82DE5DDA),
                      ),
                      title: "About ByeFilter",
                      description:
                          "Bye Filter is a Simple and powerful Vpn app built to protect your privacy,unlock content and keep you secure online",
                    ),
                    SizedBox(height: 30),
                    aboutitem(
                      icon: Icon(
                        Icons.rocket,
                        size: 35,
                        color: Color(0x82DE5DDA),
                      ),
                      title: "Our Mission",
                      description:
                          "We aim to provide a fast, stable and secure conection for everyone,everywhre",
                    ),
                    SizedBox(height: 30),
                    aboutitem(
                      icon: Icon(
                        Icons.lock,
                        size: 35,
                        color: Color(0x82DE5DDA),
                      ),
                      title: "Privacy First",
                      description:
                          "Your privacy is our priiority. we donot log,track or share your data",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Splittunnel extends StatefulWidget {
  const Splittunnel({super.key});

  @override
  State<Splittunnel> createState() => _SplittunnelState();
}

class _SplittunnelState extends State<Splittunnel> {
  late List<String> selectapps = [];
  @override
  @override
  void initState() {
    // TODO: implement initState

    getselectapps();

    context.read<SplitBlock>().add(Getapp());

    super.initState();
  }

  void getselectapps() async {
    final prefs = await SharedPreferences.getInstance();
    selectapps = prefs.getStringList("selectedapps") ?? [];
    print(selectapps);
    setState(() {});
  }

  void setSelectedapps() async {
    print('object');
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList("selectedapps", selectapps);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050609),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Split Tunnel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsetsGeometry.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF403737),
                border: Border.all(color: Color(0xFF808080)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What is Split Tunnling?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFffffff),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Splt Tunnling allows you to choose which apps use the Vpn connection and which apps access the internet directly",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBDBDBD),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            BlocBuilder<SplitBlock, SplitState>(
              builder: (context, state) {
                if (state is Splite) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.apps.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsetsGeometry.all(5),
                          padding: EdgeInsetsGeometry.all(8),
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFF403737),
                            border: Border.all(color: Color(0xFF808080)),
                          ),

                          child: Row(
                            children: [
                              Image.memory(
                                state.apps[index].icon!,
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.apps[index].name,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Checkbox(
                                value: selectapps.contains(
                                  state.apps[index].packageName,
                                ),
                                onChanged: (value) async {
                                  if (value!) {
                                    selectapps.add(
                                      state.apps[index].packageName,
                                    );

                                    setSelectedapps();

                                    setState(() {});
                                  } else {
                                    selectapps.remove(
                                      state.apps[index].packageName,
                                    );
                                    setSelectedapps();
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class donte extends StatelessWidget {
  const donte({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050609),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Donate',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Color(0xFF403737),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF808080)),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Support",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFffffff),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "ByeFilter",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFEB91D6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Your support helps us keep the app free,improve it and bring new featurs for everyone",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFBDBDBD),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Every donation makes a difrance",
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFEB91D6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      "assets/images/tondoni.png",
                      width: 84,
                      height: 145,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10),
              child: Text(
                "Donate With Gram(TON)",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFffffff),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10),
              child: Text(
                "send Gram(TON) to the wallet address below",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFBDBDBD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFF403737),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF808080)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WALLET ADDRESS",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEB91D6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Donateitem(
                    FaIcon(FontAwesomeIcons.wallet, color: Color(0xFFEB91D6)),
                    "UQAfmtn2POXDcDRE58XW51g5FEZHLxvZoGxFlflFhURh0FX8",
                  ),
                  SizedBox(height: 10),
                  Text(
                    "COMMENT/MEMO",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEB91D6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  Donateitem(
                    FaIcon(FontAwesomeIcons.comment, color: Color(0xFFEB91D6)),
                    "donate_byfilter",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class WebViewPage extends StatefulWidget {
  final String url="https://byefilter.dpdns.org/ads";



  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050609),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Ad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}












class Donateitem extends StatelessWidget {
  FaIcon icon;
  String name;

  Donateitem(this.icon, this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF403737),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Color(0xFF808080)),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFFffffff),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: name));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("copy Successfully")),
              );
            },
            child: FaIcon(FontAwesomeIcons.copy, color: Color(0xFFEB91D6)),
          ),
        ],
      ),
    );
  }
}
