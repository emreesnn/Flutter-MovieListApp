import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class CustomBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      
        shape: const CircularNotchedRectangle(),
        color: Colors.blueGrey[700],
        notchMargin: 5.0,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pushNamed(context, "/discover");
              },
            ),
            IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () {
                Navigator.pushNamed(context, "/list");
              },
            ),
            IconButton(
              icon: Icon(Icons.person_rounded),
              onPressed: () {
                AuthService().isUserAuthenticated()
                    ? Navigator.pushNamed(context, "/profile")
                    : Navigator.pushNamed(context, "/login");
              },
            ),
          ],
        ),
      
    );
  }
}
