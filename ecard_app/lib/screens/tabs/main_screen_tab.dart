import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
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
  bool _showSkeleton = true;
  final GlobalKey<FormState> _key = GlobalKey();
  final List<Widget> _tabs = [
    const AllCardsScreen(),
    const GroupCardsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fix: Use 'late' keyword instead of nullable and properly initialize
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Listen to tab changes to ensure UI is updated properly
    _tabController.addListener(_handleTabChange);

    // Fix: Properly structure loading state with setState
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showSkeleton = false;
        });
      }
    });

    // Fix: Retrieve saved tab index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenIndexProvider =
          Provider.of<TabIndexProvider>(context, listen: false);
      if (screenIndexProvider.currentScreenIndex != _tabController.index) {
        _tabController.animateTo(screenIndexProvider.currentScreenIndex);
      }
    });
  }

  void _handleTabChange() {
    // Only update provider when tab actually changes
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

    // Make sure UI reflects the current state
    if (_tabController.index != screenIndexProvider.currentScreenIndex) {
      // Use animateTo instead of just updating index for smooth transition
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.animateTo(screenIndexProvider.currentScreenIndex);
        }
      });
    }

    return Skeletonizer(
        key: _key,
        enabled: _showSkeleton,
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight + 48),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
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
                                text: 'All Cards',
                                color: Theme.of(context).canvasColor,
                                size: '19.0')),
                        Tab(
                          child: HeaderBoldWidget(
                              text: 'Groups',
                              color: Theme.of(context).canvasColor,
                              size: '19.0'),
                        )
                      ],
                      onTap: (value) {
                        // This will trigger the listener above
                        _tabController.animateTo(value);
                      },
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).canvasColor,
                      indicatorWeight: 5.0,
                      controller: _tabController,
                    ),
                  ),
                )),
            // Remove DefaultTabController as we're using our own TabController
            body: TabBarView(
              controller: _tabController,
              // Add physics for better swipe behavior
              physics:
                  const ClampingScrollPhysics(), // Important: use the same controller
              children: _tabs,
            )));
  }

  @override
  bool get wantKeepAlive => true;
}
