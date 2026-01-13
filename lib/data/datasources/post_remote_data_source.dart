import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tech_task/core/constants/api_constants.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPostById(int id);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final http.Client client;

  PostRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await client.get(Uri.parse(ApiConstants.getPostsUrl()));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerFailure('Server error: ${response.statusCode}');
      }
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw NetworkFailure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await client.get(Uri.parse(ApiConstants.getPostByIdUrl(id)));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PostModel.fromJson(json);
      } else {
        throw ServerFailure('Server error: ${response.statusCode}');
      }
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw NetworkFailure('Network error: ${e.toString()}');
    }
  }
}

