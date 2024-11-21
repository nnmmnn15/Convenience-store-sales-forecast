import 'package:convenience_sales_forecast_app/view/chat.dart';
import 'package:convenience_sales_forecast_app/view/map_location_pick.dart';
import 'package:convenience_sales_forecast_app/view/mypage.dart';
import 'package:convenience_sales_forecast_app/view/sales_history.dart';
import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:convenience_sales_forecast_app/vm/tab_handler.dart';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RailBar extends StatelessWidget {
  RailBar({super.key});
  final TabHandler controller = Get.put(TabHandler());
  final UserHandler userHandler = Get.put(UserHandler());
  // final MapHandler mapHandler = Get.put(MapHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo_.png', // 이미지 경로
              width: MediaQuery.of(context).size.width / 18,
              height: MediaQuery.of(context).size.height / 12,
            ),
            const Text(
              'AI STORE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await userHandler.getMyInfo(userHandler.box.read('userEmail'));
              Get.to(() => Mypage());
            },
            icon: const Icon(Icons.person),
          ),
        ],
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
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: Text('Map'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.edit_calendar),
                  selectedIcon: Icon(Icons.edit_calendar),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text('Chat'),
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
    if (selectedIndex != 1) {}
    switch (selectedIndex) {
      case 0:
        return MapLocationPick();
      case 1:
        Get.find<MapHandler>().isDetail.value = false;
        return SalesHistory();
      case 2:
        Get.find<MapHandler>().isDetail.value = false;
        return Chat();
      default:
        Get.find<MapHandler>().isDetail.value = false;
        return Container();
    }
  }
}
