import 'package:flutter/material.dart';
import 'package:holz_logistik/edit_user/view/edit_user_page.dart';
import 'package:holz_logistik/user_list/view/view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const IndexedStack(
        children: [UserListPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Navigator.of(context).push(EditUserPage.route()),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeTabButton(
              // groupValue: HomeTab.groupValue,
              // value: HomeTab.todos,
              icon: Icon(Icons.list_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    // required this.groupValue,
    // required this.value,
    required this.icon,
  });

  // final HomeTab groupValue;
  // final HomeTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => {}, // context.read<HomeCubit>().setTab(value),
      // iconSize: 32,
      // color:
      // groupValue != value ? null : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}
