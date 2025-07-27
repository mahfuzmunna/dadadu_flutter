import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatListBloc>()..add(SubscribeToChatRooms()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading || state is ChatListInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatListError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is ChatListLoaded) {
              final rooms = state.rooms;
              if (rooms.isEmpty) {
                return const Center(child: Text('No conversations yet.'));
              }
              return ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final otherUser = room.otherParticipant;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUser.profilePhotoUrl != null
                          ? CachedNetworkImageProvider(
                              otherUser.profilePhotoUrl!)
                          : null,
                      child: otherUser.profilePhotoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(otherUser.fullName ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      room.lastMessage?.content ?? '...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      room.lastMessage != null
                          ? DateFormat.jm()
                              .format(room.lastMessage!.createdAt.toLocal())
                          : '',
                    ),
                    onTap: () {
                      context.push('/chat/${room.id}');
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}