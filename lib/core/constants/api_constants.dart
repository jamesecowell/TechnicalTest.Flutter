class ApiConstants {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String postsEndpoint = '/posts';
  static const String postByIdEndpoint = '/posts/{id}';
  
  static String getPostByIdUrl(int id) => '$baseUrl$postsEndpoint/$id';
  static String getPostsUrl() => '$baseUrl$postsEndpoint';
  static String getCommentsByPostIdUrl(int postId) => '$baseUrl$postsEndpoint/$postId/comments';
}

