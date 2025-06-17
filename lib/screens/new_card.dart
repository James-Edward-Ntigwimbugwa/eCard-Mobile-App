import 'dart:async';
import 'dart:developer' as developer;
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/services/card_request_implementation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../utils/resources/images/images.dart';

class CreateNewCard extends StatefulWidget {
  const CreateNewCard({super.key});

  @override
  State<StatefulWidget> createState() => CreateNewCardState();
}

class CreateNewCardState extends State<CreateNewCard> {
  final String _organizationLogoPath = Images.splashImage;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Social media controllers and data
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  List<Map<String, dynamic>> _socialMediaLinks = [];

  // Selected style properties with default values
  Color _selectedColor = const Color(0xFF9C27B0); // purple
  Color _textColor = Colors.white;
  String _selectedFontStyle = 'Sans-Serif';

  /// Layout and positioning configuration for card elements
  /// Users can reorder elements and set position (left or right) of logo and text elements
  /// Using enum and map structure for flexibility and clarity
  LayoutPosition _logoPosition = LayoutPosition.left;
  LayoutPosition _textPosition = LayoutPosition.right;

  List<CardElement> _orderedElements = [
    CardElement.organizationName,
    CardElement.address,
    CardElement.title,
    CardElement.email,
    CardElement.phone,
    CardElement.website,
  ];

  @override
  void initState() {
    super.initState();
    _socialMediaLinks = [
      {
        'platform': 'LinkedIn',
        'controller': _linkedinController,
        'icon': FontAwesomeIcons.linkedin
      },
      {
        'platform': 'Twitter',
        'controller': _twitterController,
        'icon': FontAwesomeIcons.twitter
      },
      {
        'platform': 'Instagram',
        'controller': _instagramController,
        'icon': FontAwesomeIcons.instagram
      },
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _jobTitleController.dispose();
    _organizationNameController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    _emailAddressController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  /// Helper method to get font family from selected style
  String _getFontFamily(String fontStyle) {
    switch (fontStyle) {
      case 'Serif':
        return 'serif';
      case 'Mono':
        return 'monospace';
      case 'Sans-Serif':
      default:
        return 'sans-serif';
    }
  }

  /// Build label text widget for card elements
  Widget _buildLabel(String labelText, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 12,
          color: textColor.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build a single card element widget with label on top, icon and value text
  Widget _buildCardElement(
      CardElement element, Color textColor, String fontFamily) {
    IconData iconData;
    String label;
    String value;

    switch (element) {
      case CardElement.organizationName:
        iconData = Icons.business;
        label = 'Organization Name';
        value = _organizationNameController.text.isEmpty
            ? "Organization name"
            : _organizationNameController.text;
        break;
      case CardElement.address:
        iconData = Icons.location_on;
        label = 'Address';
        value = _locationController.text.isEmpty
            ? "Organization address"
            : _locationController.text;
        break;
      case CardElement.title:
        iconData = CupertinoIcons.person;
        label = 'Job Title';
        value = _jobTitleController.text.isEmpty
            ? "Job title"
            : _jobTitleController.text;
        break;
      case CardElement.email:
        iconData = Icons.email;
        label = 'Email Address';
        value = _emailAddressController.text.isEmpty
            ? "Email address"
            : _emailAddressController.text;
        break;
      case CardElement.phone:
        iconData = Icons.phone;
        label = 'Phone Number';
        value = _phoneNumberController.text.isEmpty
            ? "Phone number"
            : _phoneNumberController.text;
        break;
      case CardElement.website:
        iconData = Icons.language;
        label = 'Website';
        value = _websiteController.text.isEmpty
            ? "Website"
            : _websiteController.text;
        break;
    }

    TextStyle valueStyle = TextStyle(
      fontSize: 16,
      color: textColor,
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      key: ValueKey(element),
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, textColor),
          Row(
            children: [
              Icon(iconData, color: textColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: valueStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Build the customizable card widget
  Widget _buildCustomizableCard(BuildContext context) {
    Color cardColor = _selectedColor;
    Color textColor = _textColor;
    String fontFamily = _getFontFamily(_selectedFontStyle);

    Widget logoWidget = CircleAvatar(
      radius: 40,
      backgroundColor: textColor.withOpacity(0.15),
      child: ClipOval(
        child: Image.asset(
          _organizationLogoPath,
          fit: BoxFit.cover,
          width: 70,
          height: 70,
        ),
      ),
    );

    // Build reordered elements as draggable list (for preview only)
    List<Widget> textElements = _orderedElements
        .map((e) => _buildCardElement(e, textColor, fontFamily))
        .toList();

    Widget elementsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textElements,
    );

    // Compose card content with flexible positions of logo and text
    Widget cardContent;
    if (_logoPosition == LayoutPosition.left &&
        _textPosition == LayoutPosition.right) {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          const SizedBox(width: 16),
          Expanded(child: elementsColumn),
        ],
      );
    } else if (_logoPosition == LayoutPosition.right &&
        _textPosition == LayoutPosition.left) {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: elementsColumn),
          const SizedBox(width: 16),
          logoWidget,
        ],
      );
    } else if (_logoPosition == LayoutPosition.top &&
        _textPosition == LayoutPosition.bottom) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoWidget,
          const SizedBox(height: 16),
          elementsColumn,
        ],
      );
    } else if (_logoPosition == LayoutPosition.bottom &&
        _textPosition == LayoutPosition.top) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          elementsColumn,
          const SizedBox(height: 16),
          logoWidget,
        ],
      );
    } else {
      // Default fallback as row with left logo and right text
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          const SizedBox(width: 16),
          Expanded(child: elementsColumn),
        ],
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cardColor,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            cardContent,
          ],
        ),
      ),
    );
  }

  // Handler for submission (unchanged)
  Future<void> _handleCardSubmission(BuildContext context) async {
    try {
      if (_formKey.currentState == null) {
        developer.log("Form key is null");
        return;
      }

      if (_formKey.currentState!.validate()) {
        Alerts.showLoader(
            context: context,
            message: "Creating Card...",
            icon: LoadingAnimationWidget.stretchedDots(
                color: Theme.of(context).primaryColor, size: 20));

        final CardProvider provider =
            Provider.of<CardProvider>(context, listen: false);
        final response = await provider
            .createCard(
              title: _titleController.text,
              cardDescription: _jobTitleController.text,
              organization: _organizationNameController.text,
              address: _locationController.text,
              cardLogo: _organizationLogoPath,
              phoneNumber: _phoneNumberController.text,
              email: _emailAddressController.text,
              backgroundColor: '#${_selectedColor.value.toRadixString(16)}',
              fontColor: '#${_textColor.value.toRadixString(16)}',
            )
            .timeout(const Duration(seconds: 60));

        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (response['status'] == true) {
          Alerts.showSuccess(
              context: context,
              message: "Card created successfully",
              icon: const Icon(Icons.check_circle, color: Colors.white));

          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/dashboard', (route) => false);
          }
        } else {
          Alerts.showError(
              context: context,
              message: response['message'] ?? "Failed to create card",
              icon: const Icon(Icons.error_outline, color: Colors.white));
        }
      } else {
        Alerts.showError(
            context: context,
            message: "Please fill all required fields correctly",
            icon: const Icon(Icons.error_outline, color: Colors.white));
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Alerts.showError(
          context: context,
          message: "An unexpected error occurred",
          icon: const Icon(Icons.error_outline, color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).highlightColor,
        iconTheme: IconThemeData(color: Theme.of(context).indicatorColor),
        title: Text(
          "Create New Card",
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _handleCardSubmission(context),
            child: Text(
              "Save",
              style: TextStyle(
                  color: Theme.of(context).indicatorColor, fontSize: 18),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Card Preview",
              style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCustomizableCard(context),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Basic information input fields
                      _buildTextField(context, "Title"),
                      _buildInputField(
                        context,
                        "eg: Certain org global card",
                        _titleController,
                        Icon(CupertinoIcons.doc_text,
                            color: Theme.of(context).indicatorColor),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "Organization name"),
                      _buildInputField(
                        context,
                        "eg: Certain Org Traders",
                        _organizationNameController,
                        Icon(CupertinoIcons.building_2_fill,
                            color: Theme.of(context).indicatorColor),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter organization name';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "Job Title"),
                      _buildInputField(
                        context,
                        "eg: Accountant",
                        _jobTitleController,
                        Icon(CupertinoIcons.person,
                            color: Theme.of(context).indicatorColor),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "Business location"),
                      _buildInputField(
                        context,
                        "eg: Mabibo Dar-es-Salaam",
                        _locationController,
                        Icon(CupertinoIcons.location,
                            color: Theme.of(context).indicatorColor),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business location';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      // Contact info fields
                      _buildTextField(context, "Email Address"),
                      _buildInputField(
                        context,
                        "example@organization.co.tz",
                        _emailAddressController,
                        const Icon(Icons.email),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email address';
                          }
                          if (!RegExp(r'^[\\w-.]+@([\\w-]+\\.)+[\\w-]{2,4}\$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "Phone Number"),
                      _buildInputField(
                        context,
                        "eg: +255 716 521 848",
                        _phoneNumberController,
                        const Icon(Icons.phone),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (!RegExp(r'^(255)\\d{9}\$').hasMatch(value)) {
                            return 'Please enter a valid phone number in format: 255XXXXXXXXX';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "Website link"),
                      _buildInputField(
                        context,
                        "eg: www.certainwebsite.com",
                        _websiteController,
                        const Icon(Icons.language),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter website link';
                          }
                          if (!RegExp(r'^(www\\.)?.+\\..+').hasMatch(value)) {
                            return 'Please enter a valid website URL';
                          }
                          return null;
                        },
                      ),

                      // Card appearance selectors
                      const SizedBox(height: 20),
                      _buildTextField(context, "Card Color"),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildColorTemplateBox(Colors.purple),
                            _buildColorTemplateBox(Colors.orange),
                            _buildColorTemplateBox(Colors.green),
                            _buildColorTemplateBox(Colors.indigo.shade900),
                            _buildColorTemplateBox(Colors.pink),
                            _colorPickerButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(context, "Text Color"),
                      Row(
                        children: [
                          _colorSelectorBox(Colors.white),
                          _colorSelectorBox(Colors.black),
                          _textColorPickerButton(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(context, "Font Style"),
                      Row(
                        children: [
                          _fontStyleSelector("Sans-Serif"),
                          const SizedBox(width: 10),
                          _fontStyleSelector("Serif"),
                          const SizedBox(width: 10),
                          _fontStyleSelector("Mono"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Position controls for logo and text with labels
                      _buildTextField(context, "Logo Position"),
                      Row(
                        children: [
                          _positionSelector(LayoutPosition.left),
                          const SizedBox(width: 10),
                          _positionSelector(LayoutPosition.right),
                          const SizedBox(width: 10),
                          _positionSelector(LayoutPosition.top),
                          const SizedBox(width: 10),
                          _positionSelector(LayoutPosition.bottom),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(context, "Text Position"),
                      Row(
                        children: [
                          _positionSelector(LayoutPosition.left, isLogo: false),
                          const SizedBox(width: 10),
                          _positionSelector(LayoutPosition.right,
                              isLogo: false),
                          const SizedBox(width: 10),
                          _positionSelector(LayoutPosition.top, isLogo: false),
                          const SizedBox(width: 10),
                          _positionSelector(LayoutPosition.bottom,
                              isLogo: false),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Reorder card elements by drag & drop (instructions and preview)
                      _buildTextField(context,
                          "Order Card Elements (drag to reorder in actual app UI)"),
                      Text(
                        "Drag and drop functionality to reorder not implemented in preview. Order shown below:",
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: _orderedElements.map((e) {
                          return Chip(label: Text(e.label));
                        }).toList(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI building helper methods
  Widget _buildTextField(BuildContext context, String labelText) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).indicatorColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context,
      String hintText,
      TextEditingController controller,
      Icon prefixIcon,
      String? Function(String?)? validator,
      {Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        prefixIcon: prefixIcon,
        labelText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
      ),
    );
  }

  Widget _buildColorTemplateBox(Color color) {
    bool isSelected = _selectedColor.value == color.value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedColor = color);
      },
      child: Container(
        width: 60,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }

  Widget _colorPickerButton() {
    return IconButton(
      icon: Icon(Icons.add, color: Theme.of(context).indicatorColor),
      onPressed: () {
        _showColorPicker(context, true);
      },
    );
  }

  Widget _colorSelectorBox(Color color) {
    bool isSelected = _textColor.value == color.value;
    return GestureDetector(
      onTap: () {
        setState(() => _textColor = color);
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : Border.all(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _textColorPickerButton() {
    return IconButton(
      icon: Icon(Icons.add, color: Theme.of(context).indicatorColor),
      onPressed: () {
        _showColorPicker(context, false);
      },
    );
  }

  Widget _fontStyleSelector(String style) {
    bool isSelected = _selectedFontStyle == style;
    String fontFamily = _getFontFamily(style);
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFontStyle = style);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          style,
          style: TextStyle(
            fontFamily: fontFamily,
            color: isSelected ? Colors.white : Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _positionSelector(LayoutPosition pos, {bool isLogo = true}) {
    bool isSelected = isLogo ? (_logoPosition == pos) : (_textPosition == pos);
    String label = pos.label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isLogo) {
            _logoPosition = pos;
          } else {
            _textPosition = pos;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, bool isCardColor) {
    Color pickerColor = isCardColor ? _selectedColor : _textColor;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCardColor ? "Pick card color" : "Pick text color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              setState(() {
                if (isCardColor) {
                  _selectedColor = color;
                } else {
                  _textColor = color;
                }
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Done"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

enum LayoutPosition {
  left('Left'),
  right('Right'),
  top('Top'),
  bottom('Bottom');

  final String label;
  const LayoutPosition(this.label);
}

enum CardElement {
  organizationName('Organization Name'),
  address('Address'),
  title('Job Title'),
  email('Email Address'),
  phone('Phone Number'),
  website('Website');

  final String label;
  const CardElement(this.label);
}
