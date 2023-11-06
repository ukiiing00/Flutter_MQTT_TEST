import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient(dotenv.env['MQTT_BROKER']!, '');
Future<int> connect() async {
  client.port = 1883; // ( or whatever your wss port is)

  /// Set secure working
  // client.secure = true;

  /// Security context
  // final context = SecurityContext.defaultContext;
  // var data = await rootBundle.load('assets/emqxsl-ca.crt');

  // Note if you get a 'TlsException: Failure trusting builtin roots (OS Error:
  // 	CERT_ALREADY_IN_HASH_TABLE' error here comment out the following 2 lines
  // context.useCertificateChainBytes(data.buffer.asInt8List());

  client.logging(on: false);
  client.keepAlivePeriod = 60;
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('flutter_client')
      .authenticateAs(dotenv.env['USER_NAME'], dotenv.env['PASSWORD'])
      .withWillTopic('willtopic')
      .withWillMessage('My Will message')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  print('Client connecting....');
  client.connectionMessage = connMess;

  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    print('Client exception: $e');
    client.disconnect();
  } on SocketException catch (e) {
    print('Socket exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('Client connected');
  } else {
    print(
        'Client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    // exit(-1);
  }
  return 0;
}

/// The subscribed callback
void onSubscribed(String topic) {
  print('Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('OnDisconnected client callback - Client disconnection');
  if (client.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    print('OnDisconnected callback is solicited, this is correct');
  }
  // exit(-1);
}

/// The successful connect callback
void onConnected() {
  print('OnConnected client callback - Client connection was sucessful');
}

/// Pong callback
void pong() {
  print('Ping response client callback invoked');
}
