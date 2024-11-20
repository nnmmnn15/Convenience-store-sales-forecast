import 'package:convenience_sales_forecast_app/view/chat.dart';
import 'package:convenience_sales_forecast_app/view/map_location_pick.dart';
import 'package:convenience_sales_forecast_app/view/sales_history.dart';
import 'package:convenience_sales_forecast_app/vm/tab_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RailBar extends StatelessWidget {
  RailBar({super.key});
  final TabHandler controller = Get.put(TabHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI  STORE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              // Usezr().logout();
            },
            icon: const Icon(Icons.key_off)),
      ),
      body: Obx(
        () => Row(
          children: [
            NavigationRail(
              backgroundColor: const Color.fromRGBO(241, 239, 239, 1.0),
              selectedIndex: controller.currentScreenIndex.value,
              onDestinationSelected: (int index) {
                controller.tabController.index = index;
                controller.currentScreenIndex.value = index;
              },
              labelType: NavigationRailLabelType.selected,
              selectedIconTheme: const IconThemeData(color: Colors.blueGrey),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.grey,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  selectedIcon: Icon(Icons.home_filled),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: Text('Map'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('Reservation'),
                ),
              ],
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _buildSelectedScreen(controller.currentScreenIndex.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedScreen(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const Chat();
      case 1:
        return MapLocationPick();
      case 2:
        return const SalesHistory();
      default:
        return Container();
    }
  }
}
