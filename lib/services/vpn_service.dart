import 'package:flutter/foundation.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class VpnService {
  // static final VpnService _instance = VpnService._internal();
  //
  // factory VpnService() => _instance;
  //
  // VpnService._internal() {
  //   engine = OpenVPN(
  //     onVpnStatusChanged: (status) {
  //       debugPrint("VPN Status: $status");
  //     },
  //     onVpnStageChanged: (stage, raw) {
  //       debugPrint("VPN Stage: $stage");
  //     },
  //   );
  // }
  //
  // late final OpenVPN engine;
  //
  // Future<void> initialize() async {
  //   await engine.initialize(
  //     groupIdentifier: "group.com.example.vpn",
  //     providerBundleIdentifier: "com.example.vpn.VPNExtension",
  //     localizedDescription: "My VPN",
  //     lastStage: (stage) {
  //       debugPrint("Last Stage: $stage");
  //     },
  //     lastStatus: (status) {
  //       debugPrint("Last Status: $status");
  //     },
  //   );
  // }

  Future<File> downloadConfig(String url) async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/config.ovpn");

    await Dio().download(
      url,
      file.path,
    );

    return file;
  }

  // Future<void> connect({
  //   required String config,
  //   String? username,
  //   String? password,
  // }) async {
  //   await engine.connect(
  //     config,
  //     "Nacota VPN",
  //     username: username,
  //     password: password,
  //   );
  // }
  // void disconnected(){
  //   engine.disconnect();
  // }
}