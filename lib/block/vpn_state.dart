import 'package:installed_apps/app_info.dart';

abstract class VpnState {}

class Vpninitial extends VpnState{}

class Vpnconnecting extends VpnState{}

class Vpnconnected extends VpnState{
  String porotocol;
  String ip;

  Vpnconnected(this.porotocol,this.ip);
}

class Vpndisconnected extends VpnState{}

class VpnEror extends VpnState{
  final String  message;
  VpnEror(this.message);
}


abstract class ServerState {}
class ServerInitial extends ServerState{}
class ServerFetched extends ServerState {

  List servers;

  ServerFetched(this.servers);
}

abstract class LogState {}
class LogInitial extends LogState{}
class Log extends LogState{
  List<String> logs;

  Log(this.logs);
}

abstract class SplitState {}

class SplitInitial extends SplitState{}
class Splite extends SplitState{
  List<AppInfo> apps;

  Splite(this.apps);
}

abstract class SetingState{}

class InitialSeting extends SetingState{}

class SetingDone extends SetingState{
  bool isversion;

  SetingDone(this.isversion);
}
