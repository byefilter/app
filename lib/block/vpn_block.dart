import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'vpn_event.dart';
import 'vpn_state.dart';

import 'package:flutter/foundation.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VpnBlock extends Bloc<VpnEvent, VpnState> {
  late final OpenVPN engine;
  String protocol = "";
  String ip = "";
  final LogBlock logBlock;

  VpnBlock(this.logBlock) : super(Vpninitial()) {
    engine = OpenVPN(
      onVpnStatusChanged: _onstatusChanged,
      onVpnStageChanged: _onStageChanged,
    );
    on<InitializVpn>(_initialize);
    on<ConnetcVpn>(_connect);
    on<DisconectVpn>(_disconnect);
    on<VpnstateChanged>(_statechanged);
    on<IpVpn>(_ipchanged);
  }

  _onstatusChanged(VpnStatus? data) {}

  _onStageChanged(VPNStage stage, String rawStage) {
    print(" poro: ${rawStage}");

    logBlock.add(AddLog(stage.name));

    add(VpnstateChanged(stage.name));
  }

  FutureOr<void> _initialize(InitializVpn event, Emitter<VpnState> emit) async {
    await engine.initialize(
      groupIdentifier: "group.com.example.vpn",
      providerBundleIdentifier: "com.example.vpn.VPNExtension",
      localizedDescription: "My VPN",
      lastStage: (stage) {
        debugPrint("Last Stage: $stage");
      },
      lastStatus: (status) {
        debugPrint("Last Status: $status");
      },
    );
  }

  FutureOr<void> _connect(ConnetcVpn event, Emitter<VpnState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('object');
      if (event.username == "Null") {
        await engine.connect(
          event.conf,
          "Bye Filter",
          bypassPackages: prefs.getStringList("selectedapps") ?? [],
        );
      } else {
        await engine.connect(
          event.conf,
          "Bye Filter",
          username: event.username,
          password: event.password,
          bypassPackages: prefs.getStringList("selectedapps") ?? [],
        );
      }
    } catch (e, stackTrace) {
      print(e);
      logBlock.add(AddLog(e.toString()));
    }
  }

  FutureOr<void> _disconnect(DisconectVpn event, Emitter<VpnState> emit) {
    engine.disconnect();
  }

  FutureOr<void> _statechanged(
    VpnstateChanged event,
    Emitter<VpnState> emit,
  ) async {
    if (event.stage == "connected") {
      emit(Vpnconnected(protocol, ip));
    }

    if (event.stage == "disconnected") {
      emit(Vpndisconnected());
    }

    if (event.stage == "wait_connection") {
      emit(Vpnconnecting());
    }

    if (event.stage == "tcp_connect") {
      protocol = "TCP";
    } else if (event.stage == "udp_connect") {
      protocol = "UDP";
    }
  }

  FutureOr<void> _ipchanged(IpVpn event, Emitter<VpnState> emit) async {
    if (state is Vpnconnected) {
      var respons = await http.get(
        Uri.parse("https://api.ipify.org/?format=json"),
      );
      var ip = jsonDecode(respons.body);

      ip = ip['ip'];
      emit(Vpnconnected(protocol, ip));
    }
  }
}

class ServerBlock extends Bloc<ServerEvent, ServerState> {
  ServerBlock() : super(ServerInitial()) {
    on<ServerFetch>(_serverfetch);
  }

  FutureOr<void> _serverfetch(
    ServerFetch event,
    Emitter<ServerState> emit,
  ) async {
    var response = await http.get(
      Uri.parse(""),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      var servers = result['configs'];
      emit(ServerFetched(servers));
    }
  }
}

class LogBlock extends Bloc<LogEvent, LogState> {
  final List<String> logs = [];
  LogBlock() : super(LogInitial()) {
    on<AddLog>(_addlog);
  }

  FutureOr<void> _addlog(AddLog event, Emitter<LogState> emit) {
    logs.add(event.Log);

    print("event");

    emit(Log(logs));
    print("state emite");
  }
}

class SplitBlock extends Bloc<SplitEvent, SplitState> {
  SplitBlock() : super(SplitInitial()) {
    on<Getapp>(_getapps);
  }

  FutureOr<void> _getapps(Getapp event, Emitter<SplitState> emit) async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(
      withIcon: true,
      excludeSystemApps: false,
      excludeNonLaunchableApps: true,
    );
    emit(Splite(apps));
  }
}

class SetingBlock extends Bloc<SetingEvent, SetingState> {
  SetingBlock() : super(SetingDone(false)) {
    on<checkversion>(_checkversion);
  }

  FutureOr<void> _checkversion(
    checkversion event,
    Emitter<SetingState> emit,
  ) async {
    emit(InitialSeting());
    var response = await http.get(
      Uri.parse(""),
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      String version = result['version'];
      String appversion = "1.0.0";
      List<int> api = version.split('.').map(int.parse).toList();
      List<int> app = appversion.split('.').map(int.parse).toList();

      if (api[0] > app[0]) {
        Future.delayed(Duration(seconds: 5),() async {
          
          await launchUrl(
          Uri.parse(
            "https://byefilter.dpdns.org/#download",
          ),
          mode: LaunchMode.externalApplication,
          );
        },);
        emit(SetingDone(false));
      } else if (api[0] == app[0] && api[1] > app[1]) {

        Future.delayed(Duration(seconds: 5),() async {
          
          await launchUrl(
            Uri.parse(
              "https://byefilter.dpdns.org/#download",
            ),
            mode: LaunchMode.externalApplication,
          );
        },);
        emit(SetingDone(false));
      } else if (api[0] == app[0] && api[1] == app[1] && api[2] > app[2]) {

        Future.delayed(Duration(seconds: 5),() async {
          
          await launchUrl(
            Uri.parse(
              "https://byefilter.dpdns.org/#download",
            ),
            mode: LaunchMode.externalApplication,
          );
        },);
        emit(SetingDone(false));
      } else {

        emit(SetingDone(true));
        
      }
    }
  }
}
