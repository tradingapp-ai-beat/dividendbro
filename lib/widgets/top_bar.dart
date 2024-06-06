import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

import '../screens/sign_in_screen.dart'; // Import the SignInScreen for logout navigation

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;

  TopBar({required this.name});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Trading App'),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(child: Text(name)),
        ),
        DropdownButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          items: <String>['Profile', 'Settings', 'Logout'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            if (value == 'Logout') {
              _showLogoutConfirmationDialog(context);
            }
            // Handle other menu options here
          },
        ),
      ],
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
