import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with BlocBuilder for real data
        itemBuilder: (context, index) {
          // This would be a ChatRoomEntity from your ChatListBloc
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('User ${index + 1}'),
            subtitle: const Text('Last message...'),
            trailing: const Text('10:47 PM'),
            onTap: () {
              // Navigate to the specific chat page
              // context.push('/chat/room-id-here');
            },
          );
        },
      ),
    );
  }
}