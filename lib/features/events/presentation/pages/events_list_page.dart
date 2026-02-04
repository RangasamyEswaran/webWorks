import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_event.dart';
import '../bloc/events_state.dart';
import '../widgets/event_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../../../../core/widgets/empty_state_widget.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    context.read<EventsBloc>().add(LoadEventsEvent());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<EventsBloc>().add(LoadMoreEventsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return const LoadingWidget(message: 'Loading events...');
              }

              if (state is EventsError) {
                return custom.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<EventsBloc>().add(LoadEventsEvent());
                  },
                );
              }

              if (state is EventsLoaded) {
                if (state.events.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No events available',
                    icon: Icons.event_busy,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<EventsBloc>().add(RefreshEventsEvent());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.events.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.events.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final event = state.events[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/event-details', arguments: event.id);
                        },
                      );
                    },
                  ),
                );
              }

              if (state is EventsLoadingMore) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<EventsBloc>().add(RefreshEventsEvent());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.events.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.events.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final event = state.events[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/event-details', arguments: event.id);
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
