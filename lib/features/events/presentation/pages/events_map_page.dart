import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_state.dart';
import '../../domain/entities/event.dart';

class EventsMapPage extends StatefulWidget {
  const EventsMapPage({super.key});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EventsBloc, EventsState>(
        listener: (context, state) {
          if (state is EventsLoaded || state is EventsLoadingMore) {
            final events = (state is EventsLoaded)
                ? state.events
                : (state as EventsLoadingMore).events;

            final markers = _getMarkersFromEvents(events);
            if (markers.isNotEmpty) {
              _fitBounds(markers);
            }
          }
        },
        child: BlocBuilder<EventsBloc, EventsState>(
          builder: (context, state) {
            List<Event> events = [];
            if (state is EventsLoaded) {
              events = state.events;
            } else if (state is EventsLoadingMore) {
              events = state.events;
            }

            final markers = _getMarkersFromEvents(events);

            return GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kDefaultPosition,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                if (markers.isNotEmpty) {
                  _fitBounds(markers);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Set<Marker> _getMarkersFromEvents(List<Event> events) {
    return events.where((e) => e.latitude != null && e.longitude != null).map((
      e,
    ) {
      return Marker(
        markerId: MarkerId(e.id),
        position: LatLng(e.latitude!, e.longitude!),
        infoWindow: InfoWindow(
          title: e.title,
          snippet: e.location,
          onTap: () {
            Navigator.of(context).pushNamed('/event-details', arguments: e.id);
          },
        ),
      );
    }).toSet();
  }

  Future<void> _fitBounds(Set<Marker> markers) async {
    final GoogleMapController controller = await _controller.future;
    if (markers.isEmpty) return;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLong = markers.first.position.longitude;
    double maxLong = markers.first.position.longitude;

    for (var m in markers) {
      if (m.position.latitude < minLat) minLat = m.position.latitude;
      if (m.position.latitude > maxLat) maxLat = m.position.latitude;
      if (m.position.longitude < minLong) minLong = m.position.longitude;
      if (m.position.longitude > maxLong) maxLong = m.position.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLong),
          northeast: LatLng(maxLat, maxLong),
        ),
        50,
      ),
    );
  }
}
