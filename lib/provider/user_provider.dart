import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:trading_advice_app_v2/screens/auth_screen.dart';
import 'dart:io';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      t.replaceAllMapped(RegExp(r'(\d+)([a-z]+)', caseSensitive: false), (Match m) => '${m[2]}${m[1]}')
    ])
        .toSet();

    // Normalize the extracted timeframe
    String normalizedExtractedTimeframe = timeframe.replaceAllMapped(
        RegExp(r'(\d+)([a-z]+)', caseSensitive: false), (Match m) => '${m[2]}${m[1]}');

    return normalizedTimeframes.contains(normalizedExtractedTimeframe);
  }

  Future<void> signUp(UserModel newUser) async {
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
      await _firestore.collection('users').doc(_user.email).update({'password': newPassword});
      notifyListeners();
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  Future<void> updateSubscription(int subscriptionType, List<String> timeFrames) async {
    _user.subscriptionType = subscriptionType;
    _user.timeFrames = timeFrames;
    _user.subscriptionEndDate = DateTime.now().add(Duration(days: 30));
    _user.isCanceled = false;

    DocumentReference userDocRef = _firestore.collection('users').doc(_user.email);

    DocumentSnapshot userDoc = await userDocRef.get();
    if (userDoc.exists) {
      await userDocRef.update(_user.toJson());
    } else {
      throw Exception('User document does not exist.');
    }

    notifyListeners();
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
    _user.isCanceled = true;
    _user.cancellationDate = DateTime.now();

    DocumentReference userDocRef = _firestore.collection('users').doc(_user.email);

    DocumentSnapshot userDoc = await userDocRef.get();
    if (userDoc.exists) {
      await userDocRef.update(_user.toJson());
    } else {
      throw Exception('User document does not exist.');
    }

    notifyListeners();
  }

  Future<void> deleteAccount(BuildContext context) async {
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
        uid: '',
        subscriptionEndDate: DateTime.now(), // Initialize uid
      );
      notifyListeners();
      // Navigate to AuthScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<String> uploadImage(dynamic file) async {
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
    _user.history[index].title = newTitle;
    await _firestore.collection('users').doc(_user.email).update({
      'history': _user.history.map((e) => e.toJson()).toList(),
    });
    notifyListeners();
  }

  Future<void> deleteHistoryEntry(int index) async {
    _user.history.removeAt(index);
    await _firestore.collection('users').doc(_user.email).update({
      'history': _user.history.map((e) => e.toJson()).toList(),
    });
    notifyListeners();
  }

  Future<void> deleteHistory() async {
    _user.history.clear();
    await _firestore.collection('users').doc(_user.email).update({
      'history': [],
    });
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
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
      subscriptionEndDate: DateTime.now(), // Initialize uid
    );
    notifyListeners();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
          (Route<dynamic> route) => false,
    );
  }
}
