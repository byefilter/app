import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nacotavpn/block/vpn_block.dart';
import 'package:nacotavpn/block/vpn_event.dart';
import 'package:nacotavpn/block/vpn_state.dart';
import 'Ui/pages.dart';
import 'services/vpn_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final vpnService = VpnService();


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_)=>LogBlock()),
        BlocProvider(create: (context) => VpnBlock(context.read<LogBlock>())..add(InitializVpn())),
        BlocProvider(create: (_) => ServerBlock()),
        BlocProvider(create: (_) => SplitBlock()),
        BlocProvider(create: (_) => SetingBlock())
      ],

      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nacota VPN',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/server': (context) => const Server(),
        '/about': (context) => const AboutUs(),
        '/split': (context) => const Splittunnel(),
        "/donate":(context)=>const donte(),
        "/ad":(context)=> WebViewPage()
      },
    );
  }
}
