import 'package:dadadu_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chatroom_bloc.dart';
import 'package:get_it/get_it.dart';

import 'domain/repositories/chat_repository.dart';
import 'domain/usecases/create_chat_room_usecase.dart';
import 'domain/usecases/send_message_usecase.dart';
import 'domain/usecases/stream_chat_rooms_usecase.dart';
import 'domain/usecases/stream_messages_usecase.dart';

// Use the same GetIt instance from your main injection container
final sl = GetIt.instance;

Future<void> chatInjection() async {
  // ===================================================================
  // CHAT FEATURE
  // ===================================================================

  // --- Presentation Layer (BLoCs) ---
  // A new instance of ChatBloc will be created every time it's requested.
  // This is crucial because each chat page needs its own independent BLoC.
  sl.registerFactory(
    () => ChatBloc(
      streamMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ChatListBloc(
      streamChatRoomsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ChatRoomBloc(
      createChatRoomUseCase: sl(),
    ),
  );

  // --- Domain Layer (Use Cases) ---
  // These are registered as lazy singletons because we only need one instance
  // of each use case in the entire application.
  sl.registerLazySingleton(() => StreamMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => StreamChatRoomsUseCase(sl()));
  sl.registerLazySingleton(() => CreateChatRoomUseCase(sl()));

  // --- Data Layer (Repositories) ---
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Data Layer (Data Sources) ---
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
