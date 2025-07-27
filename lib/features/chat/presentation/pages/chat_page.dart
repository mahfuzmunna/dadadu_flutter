import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:dash_chat_3/dash_chat_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final String roomId;

  const ChatPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatBloc>()..add(SubscribeToMessages(roomId)),
      child: _ChatView(roomId: roomId),
    );
  }
}

class _ChatView extends StatelessWidget {
  final String roomId;

  const _ChatView({required this.roomId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not Authenticated')));
    }
    final currentUser = authState.user;

    final chatUser = ChatUser(
      id: currentUser.id,
      firstName: currentUser.fullName,
      profileImage: currentUser.profilePhotoUrl,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          if (state is ChatLoaded) {
            final messages = state.messages.map((msg) {
              return ChatMessage(
                user: ChatUser(id: msg.senderId),
                text: msg.content,
                createdAt: msg.createdAt,
              );
            }).toList();

            return DashChat3(
              currentUser: chatUser,
              onSend: (ChatMessage chatMessage) {
                context.read<ChatBloc>().add(SendMessage(
                      roomId: roomId,
                      content: chatMessage.text,
                      senderId: currentUser.id, // Pass senderId
                    ));
              },
              messages: messages,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
