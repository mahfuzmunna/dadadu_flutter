import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:dadadu_app/l10n/app_localizations.dart';
import 'package:dash_chat_3/dash_chat_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final String roomId;
  final String participantId;

  const ChatPage(
      {super.key, required this.roomId, required this.participantId});

  @override
  Widget build(BuildContext context) {
    // Add an event to load the specific room details in addition to messages
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ChatBloc>()..add(SubscribeToMessages(roomId)),
        ),
      ],
      // ..add(LoadChatRoomDetails(roomId)), // Assumes you have this event
      child: _ChatView(roomId: roomId, roomData: participantId),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String roomId;
  final String roomData;

  _ChatView({super.key, required this.roomId, required this.roomData});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  UserEntity? _otherParticipant;
  List<ChatMessage>? _chatMessageList;

  @override
  void initState() {
    if (mounted) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return Scaffold(
          body: Center(
              child: Text(AppLocalizations.of(context)!.notAuthenticated)));
    }
    final currentUser = authState.user;

    // The ChatUser for the person using the app
    final chatUser = ChatUser(
      id: currentUser.id,
      firstName: currentUser.fullName,
      profileImage: currentUser.profilePhotoUrl,
    );

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        // Show loading spinner until the chat details and messages are loaded
        if (state is ChatLoading || state is ChatInitial) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is ChatError) {
          return Scaffold(
              appBar: AppBar(), body: Center(child: Text(state.message)));
        }
        if (state is ChatLoaded) {
          final otherParticipantId = widget.roomData;
          // .firstWhere((id) => id != currentUser.id, orElse: () => '');

          // Dispatch the event to ProfileBloc to fetch the user's details.
          context
              .read<ProfileBloc>()
              .add(SubscribeToUserProfile(otherParticipantId));

          // List<ChatMessage> messages = state.messages.map((msg) {
          //   return ChatMessage(
          //     user: ChatUser(
          //       id: msg.senderId,
          //       // Pass other user's info for bubble avatars
          //       // profileImage: msg.senderId != currentUser.id
          //       //     ? state.otherParticipant?.profilePhotoUrl
          //       //     : null,
          //     ),
          //     text: msg.content,
          //     createdAt: msg.createdAt,
          //   );
          // }).toList();

          // debugPrint(messages.toString());
          final theme = Theme.of(context);
          return BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, pstate) {
            if (pstate is ProfileLoaded) {
              setState(() {
                _otherParticipant = pstate.user;

                _chatMessageList = state.messages.map((msg) {
                  return ChatMessage(
                    user: ChatUser(
                        id: msg.senderId,
                        // Pass other user's info for bubble avatars
                        profileImage: _otherParticipant?.profilePhotoUrl
                        //     ? state.otherParticipant?.profilePhotoUrl
                        //     : null,
                        ),
                    text: msg.content,
                    createdAt: msg.createdAt,
                  );
                }).toList();
              });
            }
          }, builder: (context, state) {
            return Scaffold(
              // ✅ A contextual AppBar showing who you're talking to
              appBar: AppBar(
                leadingWidth: 40,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          _otherParticipant?.profilePhotoUrl != null
                              ? CachedNetworkImageProvider(
                                  _otherParticipant!.profilePhotoUrl!)
                              : null,
                      child: _otherParticipant?.profilePhotoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _otherParticipant?.fullName ?? '',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '', // TODO: Replace with otherParticipants Data
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              body: DashChat3(
                currentUser: chatUser,
                onSend: (ChatMessage chatMessage) {
                  context.read<ChatBloc>().add(SendMessage(
                        roomId: widget.roomId,
                        content: chatMessage.text,
                        senderId: currentUser.id,
                      ));
                },
                messages: _chatMessageList ?? [],
                // ✅ CUSTOM STYLING to match Material 3 theme
                inputOptions: InputOptions(
                  inputDecoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.messageHint,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  sendButtonBuilder: (send) => IconButton(
                    icon: Icon(Icons.send_rounded,
                        color: theme.colorScheme.primary),
                    onPressed: send, // DashChat handles this
                  ),
                  // leading: [
                  //   IconButton(
                  //     icon: Icon(Icons.attach_file_rounded,
                  //         color: theme.colorScheme.onSurfaceVariant),
                  //     onPressed: () {
                  //     },
                  //   ),
                  // ],
                ),
                messageOptions: MessageOptions(
                  currentUserContainerColor: theme.colorScheme.primaryContainer,
                  currentUserTextColor: theme.colorScheme.onPrimaryContainer,
                  containerColor: theme.colorScheme.surfaceContainer,
                  textColor: theme.colorScheme.onSurface,
                  messageDecorationBuilder: (message, isCurrentUser, _) =>
                      BoxDecoration(
                    color: isCurrentUser != null
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            );
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}
