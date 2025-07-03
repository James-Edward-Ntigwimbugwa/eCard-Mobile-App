import 'package:ecard_app/services/cad_service.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/card_display_widget.dart';
import '../modals/card_modal.dart';

class SavedCardsScreen extends StatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<List<CustomCard>> _savedCardsFuture;
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
    // final provider = Provider.of<CardProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // Get both tokens
    final String userId = prefs.getString("userId") ?? "";
    final String accessToken = prefs.getString("accessToken") ?? "";

    if (userId.isEmpty || accessToken.isEmpty) {
      // Handle missing authentication
      setState(() {
        _isEmpty = true;
        _showBanner = true;
        _isInitialized = true;
        _savedCardsFuture = Future.value(<CustomCard>[]);
      });

      // Optional: Redirect to login
      // Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    debugPrint(
        "User UUID in savedCards Screen ======= \n $userId \n ================");
    debugPrint("Access token available: ${accessToken.isNotEmpty}");

    setState(() {
      _savedCardsFuture = CardProvider.userSavedCards(userId: userId).then((cards) {
        if (mounted) {
          setState(() {
            _isEmpty = cards.isEmpty;
            _showBanner = _isEmpty;
          });
        }
        return cards;
      }).catchError((error) {
        debugPrint("Error fetching saved cards: $error");
        if (mounted) {
          setState(() {
            _isEmpty = true;
            _showBanner = true;
          });
        }
        return <CustomCard>[];
      });
      _isInitialized = true;
    });
  }

  Future<void> _refreshSavedCards() async {
    setState(() {
      _isInitialized = false;
    });
    _initializeData();
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
                        "No saved cards yet",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Cards you save will appear here",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: FutureBuilder<List<CustomCard>>(
                  future: _savedCardsFuture,
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

                    final List<CustomCard> savedCards = snapshot.data!;
                    if (savedCards.isEmpty) {
                      return Container();
                    } else {
                      return RefreshIndicator(
                        onRefresh: _refreshSavedCards,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: savedCards.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CardDisplayWidget(
                                card: savedCards[index],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}