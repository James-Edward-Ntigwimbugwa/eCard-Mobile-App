import 'package:ecard_app/providers/card_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AllCardsScreen extends StatefulWidget {
  @override
  _AllCardsScreenState createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen>
    with AutomaticKeepAliveClientMixin {
  late CardProvider provider;

  @override
  void initState(){
    super.initState();
    provider.fetchCards('45428d2a-96a6-483c-a0e8-43e8d3abfeb1');
  }
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<CardProvider>(context);
    super.build(context);
    return SafeArea(
        child: Center(
      child: Text('All cards'),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
