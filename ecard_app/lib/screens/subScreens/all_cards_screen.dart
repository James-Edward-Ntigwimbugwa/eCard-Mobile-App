import 'package:ecard_app/providers/card_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AllCardsScreen extends StatefulWidget {
  const AllCardsScreen({super.key});

  @override
  _AllCardsScreenState createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.fetchCards('e5936449-aa00-4065-abe6-f864c782abc8');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        child: Center(
      child: Text('All cards'),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
