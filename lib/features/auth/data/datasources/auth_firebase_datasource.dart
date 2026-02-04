import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_response_dto.dart';
import '../models/user_dto.dart';
import 'auth_remote_datasource.dart';

class AuthFirebaseDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthFirebaseDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw ServerException(message: 'Login failed: User is null');
      }

      final token = await user.getIdToken();

      String name = user.displayName ?? '';
      if (name.isEmpty) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          name = doc.data()?['name'] ?? '';
        }
      }

      if (name.isEmpty) {
        name = email.split('@')[0];
      }

      final userDto = UserDto(
        id: user.uid,
        name: name,
        email: user.email ?? email,
        phone: user.phoneNumber,
        avatar: user.photoURL,
        createdAt: user.metadata.creationTime?.toIso8601String(),
      );

      return LoginResponseDto(token: token ?? '', user: userDto);
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        message: e.message ?? 'Login failed',
        statusCode: 400,
      );
    } catch (e) {
      log("message$e");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LoginResponseDto> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw ServerException(message: 'Signup failed: User is null');
      }

      await user.updateDisplayName(name);

      final userDto = UserDto(
        id: user.uid,
        name: name,
        email: user.email ?? email,
        phone: user.phoneNumber,
        avatar: user.photoURL,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final token = await user.getIdToken();

      return LoginResponseDto(token: token ?? '', user: userDto);
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }
      throw ServerException(message: message, statusCode: 400);
    } catch (e) {
      log("message$e");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserDto> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException(message: 'No user logged in', statusCode: 401);
      }

      String name = user.displayName ?? '';
      if (name.isEmpty) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          name = doc.data()?['name'] ?? '';
        }
      }
      if (name.isEmpty) {
        name = user.email?.split('@')[0] ?? 'User';
      }

      return UserDto(
        id: user.uid,
        name: name,
        email: user.email ?? '',
        phone: user.phoneNumber,
        avatar: user.photoURL,
        createdAt: user.metadata.creationTime?.toIso8601String(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveFcmToken(String token) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      log("Error saving FCM token: $e");
    }
  }
}
