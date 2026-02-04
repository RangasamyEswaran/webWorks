import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/network_info.dart';
import '../services/notification_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_firebase_datasource.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/save_fcm_token_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/events/data/datasources/events_local_datasource.dart';

import '../../features/events/data/datasources/events_remote_datasource.dart';
import '../../features/events/data/datasources/events_firestore_datasource.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/get_event_details_usecase.dart';
import '../../features/events/domain/usecases/get_events_usecase.dart';
import '../../features/events/domain/usecases/get_registered_events_usecase.dart';
import '../../features/events/domain/usecases/register_event_usecase.dart';
import '../../features/events/domain/usecases/unregister_event_usecase.dart';
import '../../features/events/presentation/bloc/event_details/event_details_bloc.dart';
import '../../features/events/presentation/bloc/events_bloc.dart';
import '../../features/events/presentation/bloc/registered_events_bloc.dart';
import '../../features/events/data/datasources/events_socket_datasource.dart';
import '../network/socket_service.dart';

import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../theme/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => ThemeBloc());

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      saveFcmTokenUseCase: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => SaveFcmTokenUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthFirebaseDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerFactory(() => EventsBloc(getEventsUseCase: sl()));
  sl.registerFactory(
    () => RegisteredEventsBloc(getRegisteredEventsUseCase: sl()),
  );
  sl.registerFactory(
    () => EventDetailsBloc(
      getEventDetailsUseCase: sl(),
      registerEventUseCase: sl(),
      unregisterEventUseCase: sl(),
      socketDataSource: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventDetailsUseCase(sl()));
  sl.registerLazySingleton(() => RegisterEventUseCase(sl()));
  sl.registerLazySingleton(() => UnregisterEventUseCase(sl()));
  sl.registerLazySingleton(() => GetRegisteredEventsUseCase(sl()));

  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<EventsRemoteDataSource>(
    () => EventsFirestoreDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<EventsSocketDataSource>(
    () => EventsSocketDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<EventsLocalDataSource>(
    () => EventsLocalDataSourceImpl(),
  );

  sl.registerFactory(
    () => ChatBloc(
      getChatMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => SocketService());
  sl.registerLazySingleton(() => NotificationService());

  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
