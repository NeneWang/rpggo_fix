import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationService {
  final String key = "AIzaSyAHedcWWJ17w-V1js7ERyz3USvPosmjNKQ";

  Future<String> getPlaceId(String input) async {
    // print(input);
    String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    // print(url);
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    // print(json);

    var placeId = json['candidates'][0]['place_id'] as String;
    // print("PressID Pressed");
    // print(placeId);
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&inputtype=textquery&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json["result"] as Map<String, dynamic>;
    print(results);
    return results;
  }

  getDirections(String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    // print(url);
    var response = await http.get(Uri.parse(url));
    // print(response.body);
    var json = convert.jsonDecode(response.body);

    var results = {
      'bounds_me': json["routes"][0]["bounds"]["northeast"],
      'bounds_sw': json["routes"][0]["bounds"]["southwest"],
      'start_location': json["routes"][0]["legs"][0]["start_location"],
      'end_location': json["routes"][0]["legs"][0]["end_location"],
      'polyline': json["routes"][0]["overview_polyline"]["points"],
      'polyline_decode': PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points'])
    };

    return(results);
  }
}
