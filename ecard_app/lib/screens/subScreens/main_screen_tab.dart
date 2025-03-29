import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainScreenTab extends StatefulWidget {
  const MainScreenTab({super.key});

  @override
  State<MainScreenTab> createState() => _MainScreenTabState();
}

class _MainScreenTabState extends State<MainScreenTab> {
  bool _showSkeleton = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      Future.delayed(Duration(seconds: 2), () {
        _showSkeleton = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: _showSkeleton,
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight + 48),
              child: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 1.5,
                centerTitle: true,
                leading: Center(
                    child: CircleAvatar(
                  child: Image.asset(Images.profileImage),
                )),
                title: HeaderBoldWidget(
                    text: Headlines.myCards,
                    color: Theme.of(context).highlightColor,
                    size: '24.0'),
                bottom: const TabBar(
                  tabs: [
                    Tab(
                      text: 'All cards',
                    ),
                    Tab(
                      text: 'Groups',
                    ),
                  ],
                ),
              ),
            ))));
  }
}
