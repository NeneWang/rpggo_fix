import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

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
}
