import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel _user;

  UserProvider()
      : _user = UserModel(
    email: '',
    name: '',
    subscriptionType: 0,
    timeFrames: [],
    history: [],
    isFreeTrial: false,
    signupDate: DateTime.now(),
  );

  UserModel get user => _user;

  int? previousSubscriptionType;

  bool get hasActiveSubscription {
    if (_user.isCanceled && _user.cancellationDate != null) {
      final activeUntil = _user.cancellationDate!.add(Duration(days: 30));
      return DateTime.now().isBefore(activeUntil);
    }

    if (_user.subscriptionType != null && _user.subscriptionType != 0

    ) {
      return true;
    } else if (_user.isFreeTrial) {
      final trialEndDate = _user.signupDate.add(Duration(days: 30));
      return DateTime.now().isBefore(trialEndDate);
    }
    return false;
  }

  bool get isTrialPeriodActive {
    final trialEndDate = _user.signupDate.add(Duration(days: 30));
    return DateTime.now().isBefore(trialEndDate);
  }

  bool get isCanceled => _user.isCanceled;

  bool get isSubscriptionStillActive {
    if (_user.cancellationDate != null) {
      final activeUntil = _user.cancellationDate!.add(Duration(days: 30));
      return DateTime.now().isBefore(activeUntil);
    }
    return false;
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking email existence: $e');
      return false; // Return false in case of any error
    }
  }

  Future<void> signUp(UserModel newUser) async {
    // Check if email has been used for free trial
    final usedEmailDoc = await _firestore.collection('usedFreeTrialEmails').doc(newUser.email).get();
    if (usedEmailDoc.exists && newUser.subscriptionType == 0) {
      throw Exception('This email has already used a free trial.');
    }

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(newUser.email).get();
    if (userDoc.exists) {
      throw Exception('Email already exists');
    }

    newUser.isFreeTrial = newUser.subscriptionType == 0; // Mark as free trial if subscription type is 0
    newUser.signupDate = DateTime.now(); // Set signup date
    await _firestore.collection('users').doc(newUser.email).set(newUser.toJson());
    _user = newUser;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      if (userDoc.exists) {
        _user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<void> updateName(String newName) async {
    _user.name = newName;
    await _firestore.collection('users').doc(_user.email).update({'name': newName});
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await currentUser.updatePassword(newPassword);
      // Optionally, you can store the hashed password in Firestore for security purposes
      // For demonstration, we store it directly
      await _firestore.collection('users').doc(_user.email).update({'password': newPassword});
      notifyListeners();
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  Future<void> updateSubscription(int subscriptionType, List<String> timeFrames) async {
    if (_user != null) {
      if (isTrialPeriodActive) {
        // If still in trial period, do not allow plan change
        return;
      }

      _user.subscriptionType = subscriptionType;
      _user.timeFrames = timeFrames;

      await _firestore.collection('users').doc(_user.email).update({
        'subscriptionType': _user.subscriptionType,
        'timeFrames': _user.timeFrames,
        'isFreeTrial': _user.isFreeTrial,
        'signupDate': _user.signupDate.toIso8601String(),
      });
      notifyListeners();
    }
  }

  Future<void> addHistoryEntry(HistoryEntry entry) async {
    _user.history.add(entry);
    await _firestore.collection('users').doc(_user.email).update({
      'history': FieldValue.arrayUnion([entry.toJson()]),
    });
    notifyListeners();
  }

  Future<void> updateHistoryEntryRating(int index, int rating) async {
    _user.history[index].rating = rating;
    await _firestore.collection('users').doc(_user.email).update({
      'history': _user.history.map((e) => e.toJson()).toList(),
    });
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    if (_user != null) {
      previousSubscriptionType = _user.subscriptionType;
      _user.isCanceled = true;
      _user.cancellationDate = DateTime.now();
      await _firestore.collection('users').doc(_user.email).update({
        'isCanceled': true,
        'cancellationDate': _user.cancellationDate!.toIso8601String(),
      });
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    if (_user != null) {
      await _firestore.collection('usedFreeTrialEmails').doc(_user.email).set({'used': true});
      await _firestore.collection('users').doc(_user.email).delete();
      _user = UserModel(
        email: '',
        name: '',
        subscriptionType: 0,
        timeFrames: [],
        history: [],
        isFreeTrial: false,
        signupDate: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = UserModel(
      email: '',
      name: '',
      subscriptionType: 0,
      timeFrames: [],
      history: [],
      isFreeTrial: false,
      signupDate: DateTime.now(),
    );
    notifyListeners();
  }
}