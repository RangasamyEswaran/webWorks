import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../../core/services/notification_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatMessagesUseCase getChatMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final NotificationService notificationService;
  StreamSubscription? _chatSubscription;

  ChatBloc({
    required this.getChatMessagesUseCase,
    required this.sendMessageUseCase,
    required this.notificationService,
  }) : super(ChatInitial()) {
    on<LoadChatMessagesEvent>(_onLoadChatMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ChatMessagesUpdatedEvent>(_onChatMessagesUpdated);
    on<ChatErrorEvent>(_onChatError);
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    _chatSubscription?.cancel();
    _chatSubscription = getChatMessagesUseCase(event.eventId).listen((result) {
      result.fold(
        (failure) => add(ChatErrorEvent(failure.message)),
        (messages) => add(ChatMessagesUpdatedEvent(messages)),
      );
    });
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(isSending: true));

      final message = ChatMessage(
        id: '',
        senderId: event.senderId,
        senderName: event.senderName,
        text: event.text,
        timestamp: DateTime.now(),
        eventId: event.eventId,
      );

      final result = await sendMessageUseCase(message);

      result.fold((failure) => emit(ChatError(failure.message)), (_) {
        emit(currentState.copyWith(isSending: false));
        notificationService.sendPushNotification(
          topic: 'event_${event.eventId}',
          title: 'New message in ${event.senderName}',
          body: event.text,
        );
      });
    }
  }

  void _onChatMessagesUpdated(
    ChatMessagesUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      emit(
        (state as ChatLoaded).copyWith(
          messages: event.messages,
          isSending: false,
        ),
      );
    } else {
      emit(ChatLoaded(messages: event.messages));
    }
  }

  void _onChatError(ChatErrorEvent event, Emitter<ChatState> emit) {
    emit(ChatError(event.message));
  }
}
