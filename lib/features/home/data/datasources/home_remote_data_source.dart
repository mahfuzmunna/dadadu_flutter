// lib/features/home/data/datasources/home_remote_data_source.dart

// No more Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/auth/data/models/user_model.dart'; // Ensure UserModel is updated for Supabase
import 'package:dadadu_app/features/upload/data/models/post_model.dart'; // Ensure PostModel is updated for Supabase
import 'package:supabase_flutter/supabase_flutter.dart'; // NEW: Supabase Client

abstract class HomeRemoteDataSource {
  /// Fetches a list of posts for the home feed with pagination.
  /// [limit] specifies the number of posts to fetch.
  /// [startAfterTimestamp] (optional) is the timestamp of the last post from the previous fetch,
  /// used for cursor-based pagination to get the next set of posts.
  Future<List<PostModel>> fetchPosts(int limit, {String? startAfterTimestamp});

  /// Fetches a UserModel by UID.
  Future<UserModel> fetchUserInfo(String uid);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient _supabaseClient; // Changed from FirebaseFirestore

  HomeRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<PostModel>> fetchPosts(int limit,
      {String? startAfterTimestamp}) async {
    try {
      // Supabase query to get posts ordered by timestamp (descending)
      PostgrestFilterBuilder query = _supabaseClient
          .from('posts') // Your posts table
          .select(); // Select all columns

      // Apply ordering for the feed
      // query = query.order('timestamp', ascending: false);

      // Apply cursor-based pagination if startAfterTimestamp is provided
      if (startAfterTimestamp != null && startAfterTimestamp.isNotEmpty) {
        // 'lt' means 'less than' - get posts with timestamps older than the last one
        query = query.lt('timestamp', startAfterTimestamp);
      }

      // Apply limit
      final List<Map<String, dynamic>> response = await query.limit(limit);

      // Map the raw List<Map<String, dynamic>> to List<PostModel>
      return response.map((map) => PostModel.fromMap(map)).toList();
    } on PostgrestException catch (e) {
      // Supabase database errors
      throw ServerException('Supabase Error fetching posts: ${e.message}',
          code: e.code ?? 'POSTGREST_ERROR', details: e.details, hint: e.hint);
    } catch (e) {
      throw ServerException('Unexpected error fetching posts: ${e.toString()}',
          code: 'UNKNOWN_ERROR');
    }
  }

  @override
  Future<UserModel> fetchUserInfo(String uid) async {
    try {
      // Supabase equivalent: select a single user row by 'id' (or 'uid' if that's your column name)
      final response = await _supabaseClient
          .from('users') // Your users table
          .select()
          .eq('id',
              uid) // Assuming 'id' is the primary key for users in Supabase
          // If you store user IDs as 'uid' column in Supabase, use .eq('uid', uid)
          .single();

      if (response == null) {
        throw ServerException('User not found for UID: $uid',
            code: 'USER_NOT_FOUND');
      }

      // Assuming UserModel has a fromMap factory constructor
      return UserModel.fromMap(
          response); // response is already a Map<String, dynamic>
    } on PostgrestException catch (e) {
      throw ServerException(
          'Supabase Error fetching user info for $uid: ${e.message}',
          code: e.code ?? 'POSTGREST_ERROR',
          details: e.details,
          hint: e.hint);
    } catch (e) {
      throw ServerException(
          'Unexpected error fetching user info for $uid: ${e.toString()}',
          code: 'UNKNOWN_ERROR');
    }
  }
}