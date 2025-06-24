import 'package:ecard_app/services/cad_service.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
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

    // Get both tokens
    final String userUuid = prefs.getString("userUuid") ?? "";
    final String accessToken = prefs.getString("accessToken") ?? "";

    if (userUuid.isEmpty || accessToken.isEmpty) {
      // Handle missing authentication
      setState(() {
        _isEmpty = true;
        _showBanner = true;
        _isInitialized = true;
        _cardsFuture = Future.value({
          'status': false,
          'message': 'Authentication required. Please login again.',
          'cards': <CustomCard>[]
        });
      });

      // Optional: Redirect to login
      // Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    debugPrint(
        "User UUID in allCards Screen ======= \n $userUuid \n ================");
    debugPrint("Access token available: ${accessToken.isNotEmpty}");

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
        } else if (data['message']?.contains('Authentication required') ==
            true) {
          // Handle authentication error specifically
          // Navigator.of(context).pushReplacementNamed('/login');
        }
        return data;
      }).catchError((error) {
        return {'status': false, 'message': error.toString()};
      });
      _isInitialized = true;
    });
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
      body: Container(
        color: Theme.of(context).highlightColor,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 5.0, right: 5.0, bottom: 2.0, top: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              if (_showBanner && _isEmpty)
                Container(
                  padding: const EdgeInsets.all(0.5),
                  child: Column(
                    children: [
                      Lottie.asset(LottieAnimes.noContent),
                      const SizedBox(height: 16),
                      const Text(
                        "Create your first Card",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _cardsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: LoadingAnimationWidget.stretchedDots(
                              color: Theme.of(context).primaryColor,
                              size: 24.0));
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/new_card');
        },
        mini: false,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 25),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
