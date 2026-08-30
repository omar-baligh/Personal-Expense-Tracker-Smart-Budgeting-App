import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/goal.dart';
import 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _goalSubscription;
  StreamSubscription? _userSubscription;

  GoalCubit() : super(GoalInitial()) {
    _userSubscription = _auth.userChanges().listen((user) {
      if (user != null) {
        _initGoals(user.uid);
      } else {
        _goalSubscription?.cancel();
        emit(GoalInitial());
      }
    });
  }

  void _initGoals(String uid) {
    _goalSubscription?.cancel();
    _goalSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .listen((snapshot) {
      final goals = snapshot.docs
          .map((doc) => Goal.fromMap(doc.data(), doc.id))
          .toList();
      emit(GoalLoaded(goals));
    });
  }

  Future<void> addGoal(Goal goal) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .add(goal.toMap());
      } catch (e) {
        emit(GoalError('Operation failed: $e'));
      }
    }
  }

  Future<void> addAmount(String id, double amount) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .doc(id);
        
        await _firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            final current = (snapshot.data()?['currentAmount'] ?? 0).toDouble();
            transaction.update(docRef, {'currentAmount': current + amount});
          }
        });
      } catch (e) {
        emit(GoalError('Operation failed: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _goalSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
