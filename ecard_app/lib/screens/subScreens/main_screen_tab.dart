import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../utils/resources/images/images.dart';
import 'all_cards_screen.dart';
import 'group_cards_screen.dart';

class MainScreenTab extends StatefulWidget {
  const MainScreenTab({super.key});

  @override
  State<MainScreenTab> createState() => _MainScreenTabState();
}

class _MainScreenTabState extends State<MainScreenTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSkeleton = false;
  GlobalKey<FormState> _key = GlobalKey();
  final List<Widget> _tabs = [
    AllCardsScreen(),
    GroupCardsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    setState(() {
      Future.delayed(Duration(seconds: 2), () {
        _showSkeleton = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabIndexProvider screenIndexProvider =
        Provider.of<TabIndexProvider>(context);
    int currentScreenTabIndex = screenIndexProvider.currentScreenIndex;

    return Skeletonizer(
        key: _key,
        enabled: _showSkeleton,
        child: DefaultTabController(
            length: _tabs.length,
            child: Scaffold(
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight + 48),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0)),
                      child: AppBar(
                        title: HeaderBoldWidget(
                            text: "My Cards",
                            color: Theme.of(context).canvasColor,
                            size: '20.0'),
                        backgroundColor: Theme.of(context).primaryColor,
                        centerTitle: true,
                        leading: Container(
                          margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                          child: CircleAvatar(
                            child: Image.asset(Images.profileImage),
                          ),
                        ),
                        automaticallyImplyLeading: false,
                        bottom: TabBar(
                          tabs: [
                            Tab(
                                child: HeaderBoldWidget(
                                    text: currentScreenTabIndex == 0
                                        ? 'All Cards'
                                        : 'All Cards',
                                    color: Theme.of(context).canvasColor,
                                    size: '19.0')),
                            Tab(
                              child: HeaderBoldWidget(
                                  text: currentScreenTabIndex == 1
                                      ? 'Groups'
                                      : 'Groups',
                                  color: Theme.of(context).canvasColor,
                                  size: '19.0'),
                            )
                          ],
                          onTap: (value) =>
                              screenIndexProvider.setCurrentIndex(value),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorColor: Theme.of(context).canvasColor,
                          indicatorWeight: 5.0,
                        ),
                      ),
                    )),
                body: TabBarView(children: _tabs))));
  }
}
