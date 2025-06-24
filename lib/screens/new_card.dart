import 'dart:async';
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/services/cad_service.dart';
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
  LayoutPosition _logoPosition = LayoutPosition.left;
  LayoutPosition _textPosition = LayoutPosition.right;

  final List<CardElement> _orderedElements = [
    CardElement.organizationName,
    CardElement.address,
    CardElement.title,
    CardElement.email,
    CardElement.phone,
    CardElement.website,
  ];

  // Track keyboard visibility
  bool _isKeyboardVisible = false;

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
    _websiteController.dispose();
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
      fontSize: _isKeyboardVisible ? 12 : 16,
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
              Icon(iconData,
                  color: textColor, size: _isKeyboardVisible ? 14 : 18),
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
          SizedBox(height: _isKeyboardVisible ? 5 : 10),
        ],
      ),
    );
  }

  /// Build the customizable card widget
  Widget _buildCustomizableCard(BuildContext context) {
    Color cardColor = _selectedColor;
    Color textColor = _textColor;
    String fontFamily = _getFontFamily(_selectedFontStyle);

    double logoRadius = _isKeyboardVisible ? 25 : 40;
    double logoSize = _isKeyboardVisible ? 45 : 70;

    Widget logoWidget = CircleAvatar(
      radius: logoRadius,
      backgroundColor: textColor.withOpacity(0.15),
      child: ClipOval(
        child: Image.asset(
          _organizationLogoPath,
          fit: BoxFit.cover,
          width: logoSize,
          height: logoSize,
        ),
      ),
    );

    List<Widget> textElements = _orderedElements
        .map((e) => _buildCardElement(e, textColor, fontFamily))
        .toList();

    Widget elementsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textElements,
    );

    Widget cardContent;
    double spacing = _isKeyboardVisible ? 8 : 16;

    if (_logoPosition == LayoutPosition.left &&
        _textPosition == LayoutPosition.right) {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          SizedBox(width: spacing),
          Expanded(child: elementsColumn),
        ],
      );
    } else if (_logoPosition == LayoutPosition.right &&
        _textPosition == LayoutPosition.left) {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: elementsColumn),
          SizedBox(width: spacing),
          logoWidget,
        ],
      );
    } else if (_logoPosition == LayoutPosition.top &&
        _textPosition == LayoutPosition.bottom) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoWidget,
          SizedBox(height: spacing),
          elementsColumn,
        ],
      );
    } else if (_logoPosition == LayoutPosition.bottom &&
        _textPosition == LayoutPosition.top) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          elementsColumn,
          SizedBox(height: spacing),
          logoWidget,
        ],
      );
    } else {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          SizedBox(width: spacing),
          Expanded(child: elementsColumn),
        ],
      );
    }

    return SizedBox(
      width:
          _isKeyboardVisible ? MediaQuery.of(context).size.width * 0.8 : null,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_isKeyboardVisible ? 12 : 20)),
        color: cardColor,
        elevation: _isKeyboardVisible ? 3 : 6,
        child: Padding(
          padding: EdgeInsets.all(_isKeyboardVisible ? 12.0 : 20.0),
          child: cardContent,
        ),
      ),
    );
  }

  /// Handle position change with conflict resolution
  void _handlePositionChange(LayoutPosition newPosition, bool isLogo) {
    setState(() {
      if (isLogo) {
        if (_textPosition == newPosition) {
          _textPosition = _getOppositePosition(newPosition);
        }
        _logoPosition = newPosition;
      } else {
        if (_logoPosition == newPosition) {
          _logoPosition = _getOppositePosition(newPosition);
        }
        _textPosition = newPosition;
      }
    });
  }

  /// Get opposite position for conflict resolution
  LayoutPosition _getOppositePosition(LayoutPosition position) {
    switch (position) {
      case LayoutPosition.left:
        return LayoutPosition.right;
      case LayoutPosition.right:
        return LayoutPosition.left;
      case LayoutPosition.top:
        return LayoutPosition.bottom;
      case LayoutPosition.bottom:
        return LayoutPosition.top;
    }
  }

  /// Helper function to format color for backend
  String _formatColorForBackend(Color color) {
    final opaqueColor = Color.fromARGB(255, color.red, color.green, color.blue);
    final r = opaqueColor.red.toRadixString(16).padLeft(2, '0');
    final g = opaqueColor.green.toRadixString(16).padLeft(2, '0');
    final b = opaqueColor.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  /// Refactored submission handler
  Future<void> _submitCard(BuildContext context) async {
    if (_validateForm()) {
      await _createCard(context);
    } else {
      _showValidationError(context);
    }
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _createCard(BuildContext context) async {
    try {
      Alerts.showLoader(
        context: context,
        message: "Creating Card...",
        icon: LoadingAnimationWidget.stretchedDots(
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      );

      final CardProvider provider =
          Provider.of<CardProvider>(context, listen: false);
      final backgroundColor = _formatColorForBackend(_selectedColor);
      final fontColor = _formatColorForBackend(_textColor);

      // Log parameters for debugging
      debugPrint("\n \n ========================\n \n "
          "Creating card with params: "
          "title: ${_titleController.text}, "
          "cardDescription: ${_jobTitleController.text}, "
          "organization: ${_organizationNameController.text}, "
          "address: ${_locationController.text}, "
          "cardLogo: $_organizationLogoPath, "
          "phoneNumber: ${_phoneNumberController.text}, "
          "email: ${_emailAddressController.text}, "
          "backgroundColor: $backgroundColor, "
          "fontColor: $fontColor"
          " \n \n ==================================\n \n");

      final response = await provider
          .createCard(
            title: _titleController.text,
            cardDescription: _jobTitleController.text,
            organization: _organizationNameController.text,
            address: _locationController.text,
            cardLogo: _organizationLogoPath,
            phoneNumber: _phoneNumberController.text,
            email: _emailAddressController.text,
            backgroundColor: backgroundColor,
            fontColor: fontColor,
          )
          .timeout(const Duration(seconds: 60));

      Navigator.pop(context); // Close loader

      if (response['status'] == true) {
        Alerts.showSuccess(
          context: context,
          message: "Card created successfully",
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/dashboard', (route) => false);
        }
      } else {
        Alerts.showError(
          context: context,
          message: response['message'] ?? "Failed to create card",
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loader if open
      Alerts.showError(
        context: context,
        message: "An unexpected error occurred",
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      debugPrint("Error: $e");
    }
  }

  void _showValidationError(BuildContext context) {
    Alerts.showError(
      context: context,
      message: "Please fill all required fields correctly",
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).highlightColor,
          iconTheme: IconThemeData(color: Theme.of(context).indicatorColor),
          title: HeaderBoldWidget(
              text: "New Card",
              color: Theme.of(context).indicatorColor,
              size: '22'),
          centerTitle: true),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isKeyboardVisible) ...[
              Text(
                "Card Preview",
                style: TextStyle(
                    color: Theme.of(context).indicatorColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            _buildCustomizableCard(context),
            SizedBox(height: _isKeyboardVisible ? 8 : 12),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                        onChanged: (value) => setState(() {}),
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
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "Phone Number"),
                      _buildInputField(
                        context,
                        "eg: 255 716 521 848",
                        _phoneNumberController,
                        const Icon(Icons.phone),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (!RegExp(r'^(255)\d{9}$').hasMatch(value)) {
                            return 'Please enter a valid phone number in format: 255XXXXXXXXX';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
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
                          if (!RegExp(r'^(www\.)?.+\..+').hasMatch(value)) {
                            return 'Please enter a valid website URL';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(context, "LinkedIn Profile"),
                      _buildInputField(
                        context,
                        "eg: linkedin.com/in/yourprofile",
                        _linkedinController,
                        Icon(FontAwesomeIcons.linkedin,
                            color: Theme.of(context).indicatorColor),
                        (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('linkedin.com')) {
                              return 'Please enter a valid LinkedIn URL';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
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
                      _buildTextField(context, "Logo Position"),
                      Wrap(
                        spacing: 10,
                        children: [
                          _positionSelector(LayoutPosition.left),
                          _positionSelector(LayoutPosition.right),
                          _positionSelector(LayoutPosition.top),
                          _positionSelector(LayoutPosition.bottom),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(context, "Text Position"),
                      Wrap(
                        spacing: 10,
                        children: [
                          _positionSelector(LayoutPosition.left, isLogo: false),
                          _positionSelector(LayoutPosition.right,
                              isLogo: false),
                          _positionSelector(LayoutPosition.top, isLogo: false),
                          _positionSelector(LayoutPosition.bottom,
                              isLogo: false),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                            onPressed: () => _submitCard(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                            ),
                            child: HeaderBoldWidget(
                                text: "Save",
                                color: Theme.of(context).highlightColor,
                                size: '20')),
                      )
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
      onTap: () => _handlePositionChange(pos, isLogo),
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
