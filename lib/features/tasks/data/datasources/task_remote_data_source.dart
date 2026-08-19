import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore? firestore;

  TaskRemoteDataSourceImpl({this.firestore});

  FirebaseFirestore get _firestore {
    try {
      return firestore ?? FirebaseFirestore.instance;
    } catch (e) {
      throw ServerException('Firebase is not initialized: $e');
    }
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.firestoreTasksCollection);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch tasks from Firestore: $e');
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _collection.doc(task.id).set(task.toFirestore());
    } catch (e) {
      throw ServerException('Failed to create task in Firestore: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _collection.doc(task.id).update(task.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update task in Firestore: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete task from Firestore: $e');
    }
  }
}
