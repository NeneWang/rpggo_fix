import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rpggo/location_services.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _originController = TextEditingController();
  // ignore: non_constant_identifier_names
  late GoogleMapController _controller_on;

  // _originController

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  Location _location = Location();

  int _polygonIdCounter = 1;
  int _polylinesIdCounter = 2;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller_on = _cntlr;
    _location.onLocationChanged.listen((l) {
      print("location changed!");
      _controller_on.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
        ),
      );
    });
  }

  static final Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: "Google Plex"),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(37.42796133580664, -122.085749655962),
  );

  static final Marker _kLakeMarker = Marker(
    markerId: MarkerId('_kLakeMarker'),
    infoWindow: InfoWindow(title: "Lake"),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: LatLng(37.43296265331129, -122.08832357078792),
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  static final Polyline _kPolyline = Polyline(
    polylineId: PolylineId('_kPolyline'),
    points: [
      LatLng(37.43296265331129, -122.08832357078792),
      LatLng(37.43296265331129, -122.08832357078792)
    ],
    width: 5,
  );

  static final Polygon _kPolygon = Polygon(
    polygonId: PolygonId('_kPolygon'),
    points: [
      LatLng(37.43296265331129, -122.08832357078792),
      LatLng(37.42796133580664, -122.085749655962),
      LatLng(37.418, -122.092),
      LatLng(37.435, -122.092),
    ],
    strokeWidth: 5,
    fillColor: Colors.transparent,
  );

  @override
  void initState() {
    super.initState();

    _setMarker(LatLng(37.42796133580664, -122.085749655962));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent));
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylinesIdCounter';
    _polylinesIdCounter++;
    print("this is the polyline I received");
    print(polylineIdVal);
    _polylines.add(
      Polyline(
          polylineId: PolylineId(polylineIdVal),
          width: 2,
          color: Colors.blue,
          points: points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("Google Maps")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(children: [
                  TextFormField(
                    controller: _originController,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        InputDecoration(hintText: "You are here (Demo)"),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                  TextFormField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(hintText: "Search by City"),
                    onChanged: (value) {
                      print(value);
                    },
                  )
                ]),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     Expanded(
          //         child: TextFormField(
          //       controller: _searchController,
          //       textCapitalization: TextCapitalization.words,
          //       decoration: InputDecoration(hintText: "Search by City"),
          //       onChanged: (value) {
          //         print(value);
          //       },
          //     )),
          //     IconButton(
          //       onPressed: () async {
          //         var place =
          //             await LocationService().getPlace(_searchController.text);
          //         _goToPlace(place);
          //       },
          //       icon: Icon(Icons.search),
          //     )
          //   ],
          // ),
          IconButton(
            onPressed: () async {
              // print('origins: ${_originController.text}');
              var directions = await LocationService().getDirections(
                  _originController.text, _searchController.text);
              // var place =
              //     await LocationService().getPlace(_searchController.text);
              // _goToPlace(place);
              // print('Directions $directions');
              _goToPlace(
                  directions['start_location']['lat'],
                  directions['start_location']['lng'],
                  directions["boundsNe"],
                  directions["boundsSw"]);

              _setPolyline(directions['polyline_decode']);
            },
            icon: Icon(Icons.search),
          ),
          Expanded(
            child: GoogleMap(
                markers: _markers,
                mapType: MapType.hybrid,
                polylines: _polylines,
                polygons: _polygons,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (point) {
                  setState(() {
                    polygonLatLngs.add(point);
                    _setPolygon();
                  });
                }),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> _goToPlace(
    // Map<String, dynamic> place
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 12),
    ));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));

    _setMarker(LatLng(lat, lng));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
