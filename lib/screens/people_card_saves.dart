import 'package:flutter/material.dart';

class PeopleCardSaves extends StatefulWidget {
  const PeopleCardSaves({super.key});

  @override
  State<StatefulWidget> createState() => _PeopleCardSavesState();
}

class _PeopleCardSavesState extends State<PeopleCardSaves> {
  // Sample data - replace with your actual data source
  final List<PersonSave> savedPeople = [
    PersonSave(
      name: "Loni Bowsher",
      role: "Senior Consultant",
      cardName: "Business Card",
      imageUrl: "assets/images/person1.jpg",
    ),
    PersonSave(
      name: "Charles Davies",
      role: "App Engineer",
      cardName: "Developer Card",
      imageUrl: "assets/images/person2.jpg",
    ),
    PersonSave(
      name: "Beatriz Brito",
      role: "Sales Associate",
      cardName: "Sales Card",
      imageUrl: "assets/images/person3.jpg",
    ),
    PersonSave(
      name: "Jonghang Jun Seo",
      role: "Sales Representative",
      cardName: "Corporate Card",
      imageUrl: "assets/images/person4.jpg",
    ),
  ];

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
                                color: Theme.of(context).highlightColor.withOpacity(0.2),
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
                          // Spacer to balance the back button
                          const SizedBox(width: 44),
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: savedPeople.length,
                  itemBuilder: (context, index) {
                    final person = savedPeople[index];
                    return PersonCard(person: person);
                  },
                ),
              ),
            ),
          ],
        ),
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
            child: person.imageUrl.startsWith('assets/')
                ? ClipOval(
                    child: Image.asset(
                      person.imageUrl,
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
  final String imageUrl;

  PersonSave({
    required this.name,
    required this.role,
    required this.cardName,
    required this.imageUrl,
  });
}