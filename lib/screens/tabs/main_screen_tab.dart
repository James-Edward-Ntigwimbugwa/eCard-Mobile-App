import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../utils/resources/images/images.dart';
import '../all_cards_screen.dart';
import '../group_cards_screen.dart';

class MainScreenTab extends StatefulWidget {
  const MainScreenTab({super.key});
  @override
  State<MainScreenTab> createState() => _MainScreenTabState();
}

class _MainScreenTabState extends State<MainScreenTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  int _notificationCount = 3;
  bool _showSkeleton = true;
  final GlobalKey<FormState> _key = GlobalKey();
  final List<Widget> _tabs = [
    const AllCardsScreen(),
    const GroupCardsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showSkeleton = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenIndexProvider =
          Provider.of<TabIndexProvider>(context, listen: false);
      if (screenIndexProvider.currentScreenIndex != _tabController.index) {
        _tabController.animateTo(screenIndexProvider.currentScreenIndex);
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _tabController.previousIndex) {
      final screenIndexProvider =
          Provider.of<TabIndexProvider>(context, listen: false);
      screenIndexProvider.setCurrentIndex(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenIndexProvider = Provider.of<TabIndexProvider>(context);

    if (_tabController.index != screenIndexProvider.currentScreenIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.animateTo(screenIndexProvider.currentScreenIndex);
        }
      });
    }

    return Container(
      key: _key,
      child: Scaffold(
        backgroundColor: Theme.of(context).highlightColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).highlightColor,
          title: HeaderBoldWidget(
              text: "My Cards",
              color: Theme.of(context).indicatorColor,
              size: '20.0'),
          leading: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0),
            child: CircleAvatar(
              radius: 18,
              child: Image.asset(Images.profileImage),
            ),
          ),
          actions: [
            DecoratedBox(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).indicatorColor,
                  size: 24.0,
                ),
                onPressed: () {
                  // Search functionality
                },
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Stack(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.bell,
                      color: Theme.of(context).indicatorColor,
                      size: 24.0,
                    ),
                    onPressed: () {
                      // Search functionality
                    },
                  ),
                ),
                Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Text(
                        '$_notificationCount',
                        style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ))
              ],
            ),
            const SizedBox(
              width: 4,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: 'All Cards',
                  ),
                  Tab(
                    text: 'Groups',
                  ),
                ],
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3.5,
              ),
            ),
            // TabBarView
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  controller: _tabController,
                  physics: const ClampingScrollPhysics(),
                  children: _tabs,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
