import 'package:flutter/material.dart';

class DrawerItems extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData traillingIcon;
  final VoidCallback onPressed;
  const DrawerItems({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.traillingIcon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          traillingIcon,
          color: Colors.black,
        ),
        onTap: onPressed,
      ),
    );
  }
}



class DrawerDivider extends StatelessWidget {
  const DrawerDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Divider(height: 2, color: Colors.grey[400], thickness: 1.0),
    );
  }
}