import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/event.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_event.dart';
import '../bloc/registered_events_bloc.dart';
import '../bloc/registered_events_event.dart';
import '../bloc/event_details/event_details_bloc.dart';
import '../bloc/event_details/event_details_event.dart';
import '../bloc/event_details/event_details_state.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<EventDetailsBloc>()..add(LoadEventDetailsEvent(eventId)),
      child: BlocListener<EventDetailsBloc, EventDetailsState>(
        listenWhen: (previous, current) {
          if (previous is EventDetailsLoaded && current is EventDetailsLoaded) {
            return previous.event.isRegistered != current.event.isRegistered;
          }
          return false;
        },
        listener: (context, state) {
          if (state is EventDetailsLoaded) {
            context.read<EventsBloc>().add(RefreshEventsEvent());
            context.read<RegisteredEventsBloc>().add(
              LoadRegisteredEventsEvent(),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: BlocBuilder<EventDetailsBloc, EventDetailsState>(
            builder: (context, state) {
              if (state is EventDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is EventDetailsError) {
                return Center(child: Text(state.message));
              } else if (state is EventDetailsLoaded) {
                return _buildEventDetails(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context, EventDetailsLoaded state) {
    final event = state.event;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (event.imageUrl != null)
                  Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                  )
                else
                  Container(
                    color: theme.primaryColor,
                    child: const Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusChip(event),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'EEEE, MMMM d, yyyy • h:mm a',
                        ).format(event.startDate),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "About this event",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (event.latitude != null && event.longitude != null) ...[
                    _buildMapSection(context, event),
                    const SizedBox(height: 24),
                  ],
                  _buildAttendeesInfo(context, event),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context, Event event) {
    if (event.latitude == null || event.longitude == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final position = LatLng(event.latitude!, event.longitude!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Location Map",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 14),
              markers: {
                Marker(
                  markerId: MarkerId(event.id),
                  position: position,
                  infoWindow: InfoWindow(title: event.title),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,

              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(Event event) {
    Color color;
    switch (event.status.toLowerCase()) {
      case 'upcoming':
        color = Colors.blue;
        break;
      case 'ongoing':
        color = Colors.green;
        break;
      case 'ended':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        event.status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAttendeesInfo(BuildContext context, Event event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFull = event.isFull;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Attendees", style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                "${event.currentAttendees ?? 0} / ${event.maxAttendees ?? '∞'}",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFull ? Colors.red : null,
                ),
              ),
            ],
          ),
          if (event.status == 'upcoming' || event.status == 'ongoing')
            _buildActionButton(context, event),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Event event) {
    return BlocBuilder<EventDetailsBloc, EventDetailsState>(
      builder: (context, state) {
        final isLoading = state is EventDetailsLoaded && state.isRegistering;

        if (event.isRegistered) {
          return OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.read<EventDetailsBloc>().add(
                      UnregisterFromEventEvent(event.id),
                    );
                  },
            icon: isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.check_circle, color: Colors.green),
            label: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Registered"),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),
          );
        } else {
          final isFull = event.isFull;
          return FilledButton.icon(
            onPressed: isFull || isLoading
                ? null
                : () {
                    context.read<EventDetailsBloc>().add(
                      RegisterForEventEvent(event.id),
                    );
                  },
            icon: isLoading ? const SizedBox.shrink() : const Icon(Icons.add),
            label: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(isFull ? "Full" : "Register"),
          );
        }
      },
    );
  }
}
