import 'package:ecard_app/services/card_request_implementation.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../modals/saved_card_response.dart';

class PeopleCardSaves extends StatefulWidget {
  final int cardId;

  const PeopleCardSaves({
    super.key,
    required this.cardId,
  });

  @override
  State<StatefulWidget> createState() => _PeopleCardSavesState();
}

class _PeopleCardSavesState extends State<PeopleCardSaves> {
  List<PersonSave> savedPeople = [];
  bool isLoading = true;
  String? errorMessage;
  List<PersonSave> filteredPeople = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
    _searchController.addListener(_filterPeople);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCards() async {
    // Show loading state immediately
    try {
      await Future.delayed(const Duration(seconds: 2), () {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            isLoading = true;
            errorMessage = null;
          });
        }
      });

      final savedCards =
      await CardProvider.getSavedCardsWithAuth(cardId : widget.cardId);
      if (mounted) {
        setState(() {
          savedPeople = savedCards
              .map((savedCard) => PersonSave.fromSavedCardResponse(savedCard))
              .toList();
          filteredPeople = List.from(savedPeople);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterPeople() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPeople = List.from(savedPeople);
      } else {
        filteredPeople = savedPeople.where((person) {
          return person.name.toLowerCase().contains(query) ||
              person.role.toLowerCase().contains(query) ||
              person.cardName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _refreshData() async {
    await _loadSavedCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .highlightColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).indicatorColor,
                                size: 20,
                              ),
                            ),
                          ),
                          // Title centered
                          Expanded(
                            child: Center(
                              child: Text(
                                'Card Saves',
                                style: TextStyle(
                                  color: Theme.of(context).indicatorColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Refresh button
                          GestureDetector(
                            onTap: _refreshData,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .highlightColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.refresh,
                                color: Theme.of(context).indicatorColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Theme.of(context).hintColor),
                        decoration: InputDecoration(
                          hintText: 'Search for Team members',
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).hintColor.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // People list section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              LottieAnimes.loading,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading saved cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredPeople.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              savedPeople.isEmpty
                  ? 'No saved cards found'
                  : 'No matching results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              savedPeople.isEmpty
                  ? 'This card has not been saved by anyone yet.'
                  : 'Try adjusting your search terms.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: filteredPeople.length,
        itemBuilder: (context, index) {
          final person = filteredPeople[index];
          return PersonCard(person: person);
        },
      ),
    );
  }
}

class PersonCard extends StatelessWidget {
  final PersonSave person;

  const PersonCard({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile image
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: person.imageUrl != null && person.imageUrl!.isNotEmpty
                ? ClipOval(
              child: person.imageUrl!.startsWith('http')
                  ? Image.network(
                person.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(context);
                },
              )
                  : Image.asset(
                person.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(context);
                },
              ),
            )
                : _buildDefaultAvatar(context),
          ),

          const SizedBox(width: 16),

          // Person info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  person.role,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                // Card name
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Saved: ${person.cardName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Check icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.check,
              color: Theme.of(context).highlightColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Theme.of(context).hintColor.withOpacity(0.6),
        size: 30,
      ),
    );
  }
}

class PersonSave {
  final String name;
  final String role;
  final String cardName;
  final String? imageUrl;
  final String? email;
  final String? phoneNumber;
  final String? company;

  PersonSave({
    required this.name,
    required this.role,
    required this.cardName,
    this.imageUrl,
    this.email,
    this.phoneNumber,
    this.company,
  });

  // Factory constructor to create PersonSave from SavedCardResponse
  factory PersonSave.fromSavedCardResponse(SavedCardResponse savedCard) {
    return PersonSave(
      name: savedCard.user.fullName.isNotEmpty
          ? savedCard.user.fullName
          : '${savedCard.user.firstName} ${savedCard.user.lastName}'.trim(),
      role: savedCard.user.jobTitle.isNotEmpty
          ? savedCard.user.jobTitle
          : 'Employee',
      cardName: savedCard.card.title.isNotEmpty
          ? savedCard.card.title
          : 'Business Card',
      imageUrl: savedCard.user.profilePhoto,
      email: savedCard.user.email,
      phoneNumber: savedCard.user.phoneNumber,
      company: savedCard.user.companyName,
    );
  }
}