import 'package:ecard_app/services/cad_service.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../components/alert_reminder.dart';
import '../modals/person_who_saved_card.dart' as model_person_save;
import 'admin_message_dialog.dart';

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
  List<model_person_save.PersonSave> savedPeople = [];
  bool isLoading = true;
  String? errorMessage;
  List<model_person_save.PersonSave> filteredPeople = [];
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
    try {
      await Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isLoading = true;
            errorMessage = null;
          });
        }
      });

      final savedCards =
          await CardProvider.getSavedCardsWithAuth(cardId: widget.cardId);
      if (mounted) {
        setState(() {
          savedPeople = savedCards
              .map((savedCard) =>
                  model_person_save.PersonSave.fromSavedCardResponse(savedCard))
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

  void _showAdminMessagesDialog() {
    // Prepare recipient names from saved people
    List<String> recipientNames = [];
    int additionalCount = 0;

    // If savedPeople is empty, show warning and exit early
    if (savedPeople.isEmpty) {
      Alerts.showWarning(
        context: context,
        message: "No card saves",
        icon: Lottie.asset(LottieAnimes.warning, width: 130, height: 130),
      );
      return;
    }

    if (filteredPeople.isNotEmpty) {
      // Take first 2 names for display
      recipientNames =
          filteredPeople.take(2).map((person) => person.name).toList();

      // Calculate additional count
      if (filteredPeople.length > 2) {
        additionalCount = filteredPeople.length - 2;
      }
    }

    // If recipientNames is empty (e.g., due to filtering), show warning and exit
    if (recipientNames.isEmpty) {
      Alerts.showWarning(
        context: context,
        message: "No matching card saves",
        icon: Lottie.asset(LottieAnimes.warning, width: 130, height: 130),
      );
      return;
    }

    // Only show the modal if there are recipients
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminMessagesDialog(
        recipientNames: recipientNames,
        additionalRecipientsCount: additionalCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAdminMessagesDialog,
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
  final model_person_save.PersonSave person;

  const PersonCard({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Add any tap functionality here if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: person.imageUrl != null && person.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              person.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            person.role,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Saved: ${person.cardName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card saved',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.6),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.check,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        Icons.person,
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        size: 24,
      ),
    );
  }
}
