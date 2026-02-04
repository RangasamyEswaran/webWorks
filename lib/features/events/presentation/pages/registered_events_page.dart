import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registered_events_bloc.dart';
import '../bloc/registered_events_event.dart';
import '../bloc/registered_events_state.dart';
import '../widgets/event_card.dart';

class RegisteredEventsPage extends StatefulWidget {
  const RegisteredEventsPage({super.key});

  @override
  State<RegisteredEventsPage> createState() => _RegisteredEventsPageState();
}

class _RegisteredEventsPageState extends State<RegisteredEventsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RegisteredEventsBloc>().add(LoadRegisteredEventsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisteredEventsBloc, RegisteredEventsState>(
      builder: (context, state) {
        if (state is RegisteredEventsInitial ||
            state is RegisteredEventsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RegisteredEventsError) {
          return Center(child: Text(state.message));
        } else if (state is RegisteredEventsLoaded) {
          if (state.events.isEmpty) {
            return const Center(
              child: Text('You have not registered for any events yet.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RegisteredEventsBloc>().add(
                LoadRegisteredEventsEvent(),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/event-details',
                      arguments: event.id,
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
