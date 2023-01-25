import 'package:flutter/material.dart';
import '/constants.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // ignore: cast_nullable_to_non_nullable
              colors: [kContentColorLightTheme, kPrimaryColor],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.centerRight,
            ),
          ),
          child: InkWell(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 20,
                  ),
                  width: double.infinity,
                  //height: 600,
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 120,
                        backgroundImage: AssetImage(
                          "assets/images/pastor.png",
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "AI PASTOR",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Jacob",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                _buildButton(const Icon(Icons.help_outline), "How it Works",
                    const SizedBox()),
                _buildButton(const Icon(Icons.monetization_on_outlined),
                    "Donate", const SizedBox()),
                _buildButton(const Icon(Icons.star_outline_outlined),
                    "Rate the app", const SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(Icon icon, String title, Widget goto) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => goto,
            ));
          },
          child: Row(
            children: [
              icon,
              const SizedBox(
                width: 10,
              ),
              Text(title),
            ],
          )),
    );
  }
}
