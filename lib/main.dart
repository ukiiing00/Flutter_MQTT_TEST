import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_test/as_process.dart';

void main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: "assets/config/.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MqttServiceScreen(),
    );
  }
}

class MqttServiceScreen extends StatefulWidget {
  const MqttServiceScreen({super.key});

  @override
  State<MqttServiceScreen> createState() => _MqttServiceScreenState();
}

class _MqttServiceScreenState extends State<MqttServiceScreen> {
  final topic = "/nodejs/mqtt";

  final subTopic = 'test/s1';

  final pubTopic = 'test/s1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ElevatedButton(
              onPressed: connect,
              child: Text('Connect'),
            ),
            ElevatedButton(
              child: const Text('Subscribe'),
              onPressed: () {
                print('Subscribing to the $subTopic topic');

                client.subscribe(subTopic, MqttQos.exactlyOnce);
                client.updates!
                    .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
                  final recMess = c![0].payload as MqttPublishMessage;
                  final pt = MqttPublishPayload.bytesToStringAsString(
                      recMess.payload.message);
                  print(
                      'Received message: topic is ${c[0].topic}, payload is $pt');
                });
                client.published!.listen((MqttPublishMessage message) {
                  print(
                      'Published topic: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
                });
              },
            ),
            ElevatedButton(
              child: const Text('Publish'),
              onPressed: () {
                final builder = MqttClientPayloadBuilder();
                builder.addString('Hello from flutter');

                print('Subscribing to the $pubTopic topic');
                client.subscribe(pubTopic, MqttQos.exactlyOnce);

                print('Publishing our topic');
                client.publishMessage(
                    pubTopic, MqttQos.exactlyOnce, builder.payload!,
                    retain: true);
              },
            ),
            ElevatedButton(
              child: const Text('Unsubscribe'),
              onPressed: () {
                print('Unsubscribing');
                client.unsubscribe(subTopic);
                client.unsubscribe(pubTopic);
              },
            ),
            ElevatedButton(
              child: const Text('Disconnect'),
              onPressed: () {
                print('Disconnecting');
                client.disconnect();
              },
            ),
          ],
        ),
      ),
    );
  }
}
