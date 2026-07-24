abstract class VpnEvent {}

class ConnetcVpn extends VpnEvent {
  final String conf;
  final String username;
  final String password;

  ConnetcVpn({
    required this.conf,
    required this.username,
    required this.password,
  });
}

class DisconectVpn extends VpnEvent{}
class VpnstateChanged extends VpnEvent{
  final String stage;

  VpnstateChanged(this.stage);
}
class InitializVpn extends VpnEvent{}

class IpVpn extends VpnEvent{}



abstract class ServerEvent {}

class ServerFetch extends ServerEvent{}

abstract class LogEvent {}

class AddLog extends LogEvent{
  String Log;

  AddLog(this.Log);
}

abstract class SplitEvent {}

class Getapp extends SplitEvent{}

abstract class SetingEvent {}

class checkversion extends SetingEvent{}
