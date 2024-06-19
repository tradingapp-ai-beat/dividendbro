import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_advice_app_v2/screens/auth_screen.dart';
import '../models/user_model.dart';
import 'dart:html' as html;

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
    uid: '', // Initialize uid
    isPaidSubscription: false,
    subscriptionEndDate: DateTime.now().add(Duration(days: 30)),
    password: '',
    paymentDate: DateTime.now(), // Initialize paymentDate
  );

  UserModel get user => _user;

  int? previousSubscriptionType;

  bool get hasActiveSubscription {
    if (_user.isCanceled && _user.subscriptionEndDate != null) {
      return DateTime.now().isBefore(_user.subscriptionEndDate);
    }
    if (_user.isPaidSubscription) {
      return DateTime.now().isBefore(_user.subscriptionEndDate);
    } else if (_user.isFreeTrial) {
      final trialEndDate = _user.signupDate.add(Duration(days: 14));
      return DateTime.now().isBefore(trialEndDate);
    }
    return false;
  }

  bool get isTrialPeriodActive {
    if (_user.isFreeTrial) {
      final trialEndDate = _user.signupDate.add(Duration(days: 14));
      return DateTime.now().isBefore(trialEndDate);
    }
    return false;
  }

  bool get isCanceled => _user.isCanceled;

  bool get isSubscriptionStillActive {
    if (_user.cancellationDate != null) {
      final activeUntil = _user.cancellationDate!.add(Duration(days: 30));
      return DateTime.now().isBefore(activeUntil);
    }
    return false;
  }

  bool get isSubscriptionActive {
    final now = DateTime.now();
    return now.isBefore(_user.paymentDate.add(Duration(days: 30)));
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  bool isTimeFrameInSubscription(String timeframe) {
    // Normalize the user's subscribed timeframes
    Set<String> normalizedTimeframes = _user.timeFrames
        .map((t) => t.toLowerCase())
        .expand((t) => [
      t,
      t.replaceAllMapped(
          RegExp(r'(\d+)([a-z]+)', caseSensitive: false), (Match m) => '${m[2]}${m[1]}')
    ])
        .toSet();

    // Normalize the extracted timeframe
    String normalizedExtractedTimeframe = timeframe.replaceAllMapped(
        RegExp(r'(\d+)([a-z]+)', caseSensitive: false), (Match m) => '${m[2]}${m[1]}');

    return normalizedTimeframes.contains(normalizedExtractedTimeframe);
  }

  Future<void> signUp(UserModel newUser) async {
    try {
      final usedEmailDoc = await _firestore.collection('usedFreeTrialEmails').doc(newUser.email).get();
      if (usedEmailDoc.exists && newUser.subscriptionType == 0) {
        throw Exception('This email has already used a free trial.');
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(newUser.email).get();
      if (userDoc.exists) {
        throw Exception('Email already exists');
      }

      newUser.isFreeTrial = newUser.subscriptionType == 0;
      newUser.isPaidSubscription = newUser.subscriptionType != 0; // Set isPaidSubscription
      newUser.signupDate = DateTime.now();
      await _firestore.collection('users').doc(newUser.email).set(newUser.toJson());
      _user = newUser;
      notifyListeners();
      print('User signed up successfully: ${newUser.email}');
    } catch (e) {
      print('Error signing up: $e');
      throw e;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      print('Signing in with email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      if (userDoc.exists) {
        _user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

        // Parse the history
        List<dynamic> historyJson = userDoc['history'] ?? [];
        _user.history = historyJson.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();

        notifyListeners();
        print('User signed in successfully: $email');
        return true;
      } else {
        print('User document not found for email: $email');
      }
    } catch (e) {
      print('Error signing in: $e');
    }
    return false;
  }

  Future<void> updateName(String newName) async {
    try {
      _user.name = newName;
      await _firestore.collection('users').doc(_user.email).update({'name': newName});
      notifyListeners();
      print('Name updated successfully to: $newName');
    } catch (e) {
      print('Error updating name: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        await _firestore.collection('users').doc(_user.email).update({'password': newPassword});
        notifyListeners();
        print('Password updated successfully');
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      print('Error updating password: $e');
    }
  }

  Future<void> updateSubscription(int subscriptionType, List<String> timeFrames) async {
    try {
      if (_user.email.isEmpty) {
        throw Exception("User is not signed in.");
      }

      print('Updating subscription for user: ${_user.email}');
      _user.subscriptionType = subscriptionType;
      _user.timeFrames = timeFrames;
      _user.subscriptionEndDate = DateTime.now().add(Duration(days: 30));
      _user.paymentDate = DateTime.now();
      _user.isCanceled = false;

      DocumentReference userDocRef = _firestore.collection('users').doc(_user.email);
      print('Document reference path: ${userDocRef.path}');

      DocumentSnapshot userDoc = await userDocRef.get();
      if (userDoc.exists) {
        await userDocRef.update(_user.toJson());
        notifyListeners();
        print('Subscription updated successfully');
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print('Error updating subscription: $e');
      throw e;
    }
  }

  Future<void> addHistoryEntry(HistoryEntry entry) async {
    try {
      _user.history.add(entry);
      await _firestore.collection('users').doc(_user.email).update({
        'history': FieldValue.arrayUnion([entry.toJson()]),
      });
      notifyListeners();
      print('History entry added successfully');
    } catch (e) {
      print('Error adding history entry: $e');
    }
  }

  Future<void> updateHistoryEntryRating(int index, int rating) async {
    try {
      _user.history[index].rating = rating;
      await _firestore.collection('users').doc(_user.email).update({
        'history': _user.history.map((e) => e.toJson()).toList(),
      });
      notifyListeners();
      print('History entry rating updated successfully');
    } catch (e) {
      print('Error updating history entry rating: $e');
    }
  }

  Future<void> cancelSubscription() async {
    try {
      _user.isCanceled = true;
      _user.cancellationDate = DateTime.now();

      DocumentReference userDocRef = _firestore.collection('users').doc(_user.email);

      DocumentSnapshot userDoc = await userDocRef.get();
      if (userDoc.exists) {
        await userDocRef.update(_user.toJson());
        notifyListeners();
        print('Subscription canceled successfully');
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print('Error canceling subscription: $e');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      if (_user != null) {
        // Mark the email as having used the free trial
        await _firestore.collection('usedFreeTrialEmails').doc(_user.email).set({'used': true});

        // Delete user files from Firebase Storage
        await _deleteUserFiles(_user.email);

        // Delete the user document from Firestore
        await _firestore.collection('users').doc(_user.email).delete();

        // Reset the user model
        _user = UserModel(
          email: '',
          name: '',
          subscriptionType: 0,
          timeFrames: [],
          history: [],
          isFreeTrial: false,
          signupDate: DateTime.now(),
          uid: '',
          subscriptionEndDate: DateTime.now(),
          password: '',
          paymentDate: DateTime.now(),
        );
        notifyListeners();

        // Navigate to AuthScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
              (Route<dynamic> route) => false,
        );
        print('Account deleted successfully');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  Future<void> _deleteUserFiles(String email) async {
    try {
      final storageRef = _storage.ref().child('user_images/$email');

      // List all files in the user's directory
      final ListResult result = await storageRef.listAll();

      // Delete each file
      for (var item in result.items) {
        await item.delete();
      }
      print('User files deleted successfully');
    } catch (e) {
      print('Error deleting user files: $e');
    }
  }

  Future<String> uploadImage(dynamic file) async {
    if (!isSubscriptionActive) {
      throw Exception('Your subscription has expired. Please renew to upload new images.');
    }

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = _storage.ref().child('user_images/${_user.email}/$fileName.jpg');

      UploadTask uploadTask;
      if (file is Uint8List) {
        print('Uploading a Uint8List file');
        uploadTask = storageRef.putData(file);
      } else if (file is File) {
        print('Uploading a File');
        uploadTask = storageRef.putFile(file);
      } else {
        print('Unsupported file type: ${file.runtimeType}');
        throw Exception('Unsupported file type');
      }

      final snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully, download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return '';
    }
  }

  Future<void> updateHistoryEntryName(int index, String newTitle) async {
    try {
      _user.history[index].title = newTitle;
      await _firestore.collection('users').doc(_user.email).update({
        'history': _user.history.map((e) => e.toJson()).toList(),
      });
      notifyListeners();
      print('History entry name updated successfully');
    } catch (e) {
      print('Error updating history entry name: $e');
    }
  }

  Future<void> deleteHistoryEntry(int index) async {
    try {
      _user.history.removeAt(index);
      await _firestore.collection('users').doc(_user.email).update({
        'history': _user.history.map((e) => e.toJson()).toList(),
      });
      notifyListeners();
      print('History entry deleted successfully');
    } catch (e) {
      print('Error deleting history entry: $e');
    }
  }

  Future<void> deleteHistory() async {
    try {
      _user.history.clear();
      await _firestore.collection('users').doc(_user.email).update({
        'history': [],
      });
      notifyListeners();
      print('History cleared successfully');
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      _user = UserModel(
        email: '',
        name: '',
        subscriptionType: 0,
        timeFrames: [],
        history: [],
        isFreeTrial: false,
        signupDate: DateTime.now(),
        uid: '',
        subscriptionEndDate: DateTime.now(),
        password: '', // Initialize uid
        paymentDate: DateTime.now(), // Initialize paymentDate
      );
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
            (Route<dynamic> route) => false,
      );

      // Optionally, force a full reload of the web page to clear any cached state.
      html.window.location.reload();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
