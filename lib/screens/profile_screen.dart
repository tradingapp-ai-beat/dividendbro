import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isEditing = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController.text = user.name;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@#$!%*?&]{8,}$');
    if (!regex.hasMatch(value)) {
      return 'Password must contain an uppercase letter, a lowercase letter, a number, and a special character';
    }
    return null;
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match");
      return;
    }

    final passwordValidation = _validatePassword(_newPasswordController.text);
    if (passwordValidation != null) {
      _showErrorDialog(passwordValidation);
      return;
    }

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updatePassword(_newPasswordController.text);
      _showSuccessDialog("Password updated successfully");
      setState(() {
        _isChangingPassword = false;
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: _isEditing
                              ? TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          )
                              : Text(
                            'Name: ${user.name}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isEditing ? Icons.check : Icons.edit),
                          onPressed: () async {
                            if (_isEditing) {
                              await Provider.of<UserProvider>(context, listen: false)
                                  .updateName(_nameController.text);
                            }
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 20),
                    _isChangingPassword
                        ? Column(
                      children: [
                        TextField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updatePassword,
                          child: Text('Update Password'),
                        ),
                      ],
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isChangingPassword = true;
                        });
                      },
                      child: Text('Change Password'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
