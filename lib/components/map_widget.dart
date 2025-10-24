import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

Widget buildMapView(Position position) {
  return SizedBox(
    height: 100,
    child: FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          position.latitude,
          position.longitude,
        ), // ✅ updated (new flutter_map API)
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 50,
              height: 50,
              point: LatLng(position.latitude, position.longitude),
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
