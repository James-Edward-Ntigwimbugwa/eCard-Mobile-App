import 'package:ecard_app/models/nearby_cards_spatial_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyScannedCardDetailsScreen extends StatefulWidget {
  final BusinessCard card;

  const NearbyScannedCardDetailsScreen({
    super.key,
    required this.card,
  });

  @override
  State<NearbyScannedCardDetailsScreen> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<NearbyScannedCardDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Updated distance color method with expanded range (0m - 50000m)
  Color _getDistanceColor(double distance) {
    if (distance <= 50) {
      return Colors.green; // Very close - green
    } else if (distance <= 500) {
      return Colors.lightGreen; // Close - light green
    } else if (distance <= 1000) {
      return Colors.yellow; // Medium close - yellow
    } else if (distance <= 2500) {
      return Colors.orange; // Medium - orange
    } else if (distance <= 5000) {
      return Colors.deepOrange; // Far - deep orange
    } else if (distance <= 10000) {
      return Colors.red; // Very far - red
    } else if (distance <= 25000) {
      return Colors.purple; // Extremely far - purple
    } else {
      return Colors.indigo; // Maximum distance - indigo
    }
  }

  // Get distance category for display
  String _getDistanceCategory(double distance) {
    if (distance <= 100) {
      return 'Very Close';
    } else if (distance <= 500) {
      return 'Close';
    } else if (distance <= 1000) {
      return 'Near';
    } else if (distance <= 2000) {
      return 'Moderate';
    } else if (distance <= 5000) {
      return 'Far';
    } else if (distance <= 10000) {
      return 'Very Far';
    } else if (distance <= 20000) {
      return 'Distant';
    } else if (distance <= 35000) {
      return 'Very Distant';
    } else if (distance <= 50000) {
      return 'Extremely Far';
    } else {
      return 'Out of Range';
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('$label copied to clipboard'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: widget.card.email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: widget.card.phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchMaps() async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {
        'api': '1',
        'query': '${widget.card.latitude},${widget.card.longitude}',
      },
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildTravelInfoSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Card Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorLight ??
                    Theme.of(context).primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share,
            color: Colors.white,
          ),
          onPressed: () {
            // Share card details
            _shareCard();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            // Add to favorites
            _addToFavorites();
          },
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight ??
                  Theme.of(context).primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profile_${widget.card.title}',
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(45),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: widget.card.hasProfilePhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.network(
                              widget.card.profilePhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Theme.of(context).primaryColor,
                                  size: 45,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 45,
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.card.organization,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getDistanceColor(widget.card.distance)
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.card.distance >= 1000
                                  ? '${(widget.card.distance / 1000).toStringAsFixed(1)}km away'
                                  : '${widget.card.distance.toStringAsFixed(0)}m away',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.card.hasLogo) ...[
              const SizedBox(height: 24),
              Container(
                height: 70,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.network(
                    widget.card.cardLogo!,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Container();
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_page,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: widget.card.email,
            onTap: _launchEmail,
            onLongPress: () => _copyToClipboard(widget.card.email, 'Email'),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: widget.card.phoneNumber,
            onTap: _launchPhone,
            onLongPress: () =>
                _copyToClipboard(widget.card.phoneNumber, 'Phone'),
          ),
          if (widget.card.organization != null) ...[
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.web,
              label: 'Website',
              value: widget.card.organization!,
              onTap: () => _launchUrl(widget.card.organization!),
              onLongPress: () =>
                  _copyToClipboard(widget.card.organization!, 'Website'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).canvasColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).indicatorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).hintColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Location & Direction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDistanceIndicator(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direction',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.navigation,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.card.direction,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _launchMaps,
                icon: Icon(Icons.map, size: 18),
                label: Text('Open Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceIndicator() {
    double distance = widget.card.distance;
    Color distanceColor = _getDistanceColor(distance);
    String distanceCategory = _getDistanceCategory(distance);

    // Calculate progress based on distance ranges with fixed maximum
    double progress = (distance / 50000).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Distance',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              distance >= 1000
                  ? '${(distance / 1000).toStringAsFixed(1)}km'
                  : '${distance.toStringAsFixed(0)}m',
              style: TextStyle(
                fontSize: 16,
                color: distanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          distanceCategory,
          style: TextStyle(
            fontSize: 14,
            color: distanceColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Fixed length bar with varying colors
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      distanceColor.withOpacity(0.3),
                      distanceColor.withOpacity(0.6),
                      distanceColor,
                    ],
                    stops: [0.0, progress, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: distanceColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Distance marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.7 * progress,
                child: Container(
                  width: 4,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Travel Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTravelItem(
                  icon: Icons.directions_walk,
                  label: 'Walking',
                  time: '${(widget.card.distance / 80).ceil()} min',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTravelItem(
                  icon: Icons.directions_bike,
                  label: 'Cycling',
                  time: '${(widget.card.distance / 200).ceil()} min',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTravelItem(
                  icon: Icons.directions_car,
                  label: 'Driving',
                  time: '${(widget.card.distance / 500).ceil()} min',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTravelItem(
                  icon: Icons.directions_transit,
                  label: 'Transit',
                  time: '${(widget.card.distance / 300).ceil()} min',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _launchPhone,
                icon: Icon(Icons.phone, size: 20),
                label: Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _launchEmail,
                icon: Icon(Icons.email, size: 20),
                label: Text('Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _launchMaps,
            icon: Icon(Icons.navigation, size: 20),
            label: Text('Get Directions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareCard() {
    // Implement share functionality
    final String shareText = '''
Contact: ${widget.card.title}
Organization: ${widget.card.organization}
Email: ${widget.card.email}
Phone: ${widget.card.phoneNumber}
Distance: ${widget.card.distance >= 1000 ? '${(widget.card.distance / 1000).toStringAsFixed(1)}km' : '${widget.card.distance.toStringAsFixed(0)}m'} away
    ''';

    // Use share package or platform-specific sharing
    _copyToClipboard(shareText, 'Card details');
  }

  void _addToFavorites() {
    // Implement favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 8),
            Text('Added to favorites'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
