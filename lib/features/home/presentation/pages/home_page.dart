import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/home/presentation/bloc/home_bloc.dart';
import '../../../../injection_container.dart'; // For home_bloc

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide HomeBloc specific to this subtree
    return BlocProvider(
      create: (context) => sl<HomeBloc>(), // Get HomeBloc from DI
      child: Scaffold(
        appBar: AppBar(
          title: const Text('For You'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Dispatch signOut event from AuthBloc
                BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
              },
            ),
          ],
        ),
        body: Center(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeInitial) {
                // Dispatch event to load posts when page is first built
                context.read<HomeBloc>().add(LoadFeedPosts());
                return const CircularProgressIndicator();
              } else if (state is HomeLoading) {
                return const CircularProgressIndicator();
              } else if (state is HomeLoaded) {
                return ListView.builder(
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return ListTile(
                      title: Text(post.caption),
                      subtitle: Text('By: ${post.authorId}'),
                    );
                  },
                );
              } else if (state is HomeError) {
                return Text('Error: ${state.message}');
              }
              return const Text('Welcome to Home!');
            },
          ),
        ),
      ),
    );
  }
}