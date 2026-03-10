class FirestorePaths {
  static const users = 'users';
  static const tasks = 'tasks';

  static String userTasks(String userId) => '$users/$userId/$tasks';
}
