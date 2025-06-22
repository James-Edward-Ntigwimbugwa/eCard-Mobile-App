import 'package:ecard_app/services/card_request_implementation.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
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

  void _showAdminMessagesDialog() {
    // Prepare recipient names from saved people
    List<String> recipientNames = [];
    int additionalCount = 0;

    if (filteredPeople.isNotEmpty) {
      // Take first 2 names for display
      recipientNames = filteredPeople
          .take(2)
          .map((person) => person.name)
          .toList();

      // Calculate additional count
      if (filteredPeople.length > 2) {
        additionalCount = filteredPeople.length - 2;
      }
    }

    // Fallback to mock data if no saved people
    if (recipientNames.isEmpty) {
      recipientNames = ["John Doe", "Jane Smith"];
      additionalCount = 8;
    }

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
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

class AdminMessagesDialog extends StatefulWidget {
  final List<String> recipientNames;
  final int additionalRecipientsCount;

  const AdminMessagesDialog({
    Key? key,
    required this.recipientNames,
    this.additionalRecipientsCount = 0,
  }) : super(key: key);

  @override
  State<AdminMessagesDialog> createState() => _AdminMessagesDialogState();
}

class _AdminMessagesDialogState extends State<AdminMessagesDialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      text: "Welcome everyone! This is an important announcement.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      senderName: "Admin",
      senderAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
    ),
    Message(
      text: "Please review the new guidelines that have been shared in the documents section.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      senderName: "Admin",
      senderAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
    ),
    Message(
      text: "The meeting scheduled for tomorrow has been moved to 3 PM. Please update your calendars accordingly.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      senderName: "Admin",
      senderAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            text: _messageController.text.trim(),
            timestamp: DateTime.now(),
            senderName: "Admin",
            senderAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
          ),
        );
      });
      _messageController.clear();
    }
  }

  String get recipientsText {
    if (widget.recipientNames.isEmpty) return "No recipients";

    if (widget.recipientNames.length == 1) {
      return "You are sending messages to ${widget.recipientNames.first}";
    } else if (widget.recipientNames.length == 2) {
      return "You are sending messages to ${widget.recipientNames[0]} and ${widget.recipientNames[1]}";
    } else {
      String baseText = "You are sending messages to ${widget.recipientNames[0]}, ${widget.recipientNames[1]}";
      if (widget.additionalRecipientsCount > 0) {
        baseText += " and ${widget.additionalRecipientsCount}+ others";
      }
      return baseText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Theme.of(context).indicatorColor,
                Theme.of(context).primaryColor,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Recipients header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        recipientsText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(message: _messages[index]);
                  },
                ),
              ),

              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Type your message...",
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(6),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(6),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Sender avatar
                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          message.senderAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.withOpacity(0.3),
                              child: Icon(
                                Icons.person,
                                size: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }
}

class Message {
  final String text;
  final DateTime timestamp;
  final String senderName;
  final String senderAvatar;

  Message({
    required this.text,
    required this.timestamp,
    required this.senderName,
    required this.senderAvatar,
  });
}

// Usage example:
void showAdminMessagesDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AdminMessagesDialog(
      recipientNames: ["Alice Johnson", "Bob Smith"],
      additionalRecipientsCount: 15,
    ),
  );
}