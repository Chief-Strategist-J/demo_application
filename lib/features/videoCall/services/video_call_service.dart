import 'dart:convert';
import 'package:demo_application/core/constants.dart';
import 'package:http/http.dart' as http;

Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': videoCallSdkToken},
  );

  return json.decode(httpResponse.body)['roomId'];
}
