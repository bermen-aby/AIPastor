import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:newapp/pages/chat_page/chat_page.dart';

import '../../constants.dart';
import '../components/drawer_menu.dart';
import 'components/body.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({Key? key}) : super(key: key);

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      drawer: const DrawerMenu(),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: buildAppBar(),
        body: Body(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _advancedDrawerController.showDrawer();
          },
          backgroundColor: kPrimaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        //bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text("Chats"),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
