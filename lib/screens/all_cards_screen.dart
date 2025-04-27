import 'package:ecard_app/providers/card_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/card_display_widget.dart';
import '../modals/card_modal.dart';

class AllCardsScreen extends StatefulWidget {
  const AllCardsScreen({super.key});
  @override
  State<StatefulWidget> createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, dynamic>> _cardsFuture;
  bool _isInitialized = false;
  bool _isEmpty = false;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    final provider = Provider.of<CardProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    // final String _userUuid = 'e5936449-aa00-4065-abe6-f864c782abc8';
    final String userUuid = prefs.getString("userUuid").toString();
    setState(() {
      _cardsFuture = provider.fetchCards(userUuid).then((data) {
        if (data['status'] == true) {
          List<CustomCard> cards = data['cards'];
          if (mounted) {
            setState(() {
              _isEmpty = cards.isEmpty;
              _showBanner = _isEmpty;
            });
          }
        }
        return data;
      }).catchError((error) {
        return {'status': false, 'message': error.toString()};
      });
      _isInitialized = true;
    });
  }

  Widget _buildDismissibleBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
                'You don\'t have any cards right now. Press the "+" icon to add cards.',
                style: const TextStyle(fontSize: 16.0)),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showBanner = false;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isInitialized) {
      return Center(
        child: LoadingAnimationWidget.stretchedDots(
            color: Theme.of(context).primaryColor, size: 24.0),
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_showBanner && _isEmpty) _buildDismissibleBanner(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _cardsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: LoadingAnimationWidget.stretchedDots(
                            color: Theme.of(context).primaryColor, size: 24.0));
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Container();
                  }
                  if (snapshot.data!['status'] == false) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 24, color: Colors.orange),
                          const SizedBox(height: 16),
                          Text('${snapshot.data!['message']}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeData,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  final List<CustomCard> cards = snapshot.data!['cards'];
                  if (cards.isEmpty) {
                    return Container();
                  } else {
                    return ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CardDisplayWidget(card: cards[index]);
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(CupertinoIcons.add),
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
