import 'dart:async';

import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/providers/card_provider.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../services/card_requests.dart';
import '../utils/resources/images/images.dart';

class CreateNewCard extends StatefulWidget {
  const CreateNewCard({super.key});

  @override
  State<StatefulWidget> createState() => CreateNewCardState();
}

class CreateNewCardState extends State<CreateNewCard> {
  final String _organizationLogoPath = Images.splashImage;
  String _organizationName = "Organization name";
  String _organizationAddress = "Organization address";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Color templates
  final List<Color> _colorTemplates = [
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
    const Color(0xFF00BFA5), // Green
    const Color(0xFF1A237E), // Dark Blue
    const Color(0xFFE91E63), // Pink
  ];

  // Selected color & font style
  Color _selectedColor = const Color(0xFF9C27B0); // Default is purple
  String _selectedFontStyle = 'Sans-Serif'; // Default font style
  Color _textColor = Colors.white; // Default text color

  // Social media controllers
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  List<Map<String, dynamic>> _socialMediaLinks = [];

  @override
  void initState() {
    super.initState();
    // Initialize social media links
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
  Widget build(BuildContext context) {
    final CardProvider provider =
        Provider.of<CardProvider>(context, listen: false);
    Future<void> handleCardSubmission() async {
      if (_formKey.currentState!.validate()) {
        Alerts.showLoader(
            context: context,
            message: "Creating Card...",
            icon: LoadingAnimationWidget.stretchedDots(
                color: Theme.of(context).primaryColor, size: 20));
        await provider
            .createCard(
                title: _titleController.text,
                cardDescription: _jobTitleController.text,
                organization: _organizationNameController.text,
                address: _locationController.text,
                cardLogo: _organizationLogoPath,
                phoneNumber: _phoneNumberController.text,
                email: _emailAddressController.text,
                backgroundColor: '#${_selectedColor.value.toRadixString(16)}',
                fontColor: '#${_textColor.value.toRadixString(16)}')
            .timeout(const Duration(seconds: 60), onTimeout: () {
          Alerts.showError(
              context: context,
              message:
                  "Request timed out. Please check your internet connection.",
              icon: Icon(Icons.error_outline,
                  color: Theme.of(context).indicatorColor));
          throw TimeoutException("Request timed out");
        }).then((response) {
          if (response['status'] == true) {
            Alerts.showSuccess(
                context: context,
                message: "Card created successfully",
                icon: Icon(Icons.check_circle,
                    color: Theme.of(context).indicatorColor));
            Navigator.pop(context);
          } else {
            Alerts.showError(
                context: context,
                message: response['message'],
                icon: Icon(Icons.error_outline,
                    color: Theme.of(context).indicatorColor));
            Navigator.pop(context);
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).indicatorColor),
        title: Text(
          Headlines.createCardHeader,
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).highlightColor,
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            onPressed: handleCardSubmission,
            child: Text(
              Texts.save,
              style: TextStyle(
                  color: Theme.of(context).indicatorColor, fontSize: 18),
            ),
          )
        ],
      ),
      body: Container(
        color: Theme.of(context).highlightColor,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Headlines.cardPreview,
              style: TextStyle(
                color: Theme.of(context).indicatorColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCustomizableCard(
                context,
                _organizationLogoPath,
                _organizationNameController.text.isEmpty
                    ? _organizationName
                    : _organizationNameController.text,
                _locationController.text.isEmpty
                    ? _organizationAddress
                    : _locationController.text,
                _selectedColor),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Headlines.cardInformation,
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(context, "Title"),
                        const SizedBox(height: 5),
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
                        const SizedBox(height: 10),
                        _buildTextField(context, "Organization name"),
                        const SizedBox(height: 5),
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
                          onChanged: (value) {
                            setState(() {
                              _organizationName = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(context, "Job Title"),
                        const SizedBox(height: 5),
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
                        const SizedBox(height: 10),
                        const Divider(height: 1),

                        // Card Appearance Section
                        const SizedBox(height: 20),
                        Text(
                          "Card Appearance",
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Card Templates",
                          style: TextStyle(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.7),
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Color Templates
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colorTemplates.length +
                                1, // +1 for custom color picker
                            itemBuilder: (context, index) {
                              if (index < _colorTemplates.length) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = _colorTemplates[index];
                                    });
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: _colorTemplates[index],
                                      borderRadius: BorderRadius.circular(10),
                                      border: _selectedColor ==
                                              _colorTemplates[index]
                                          ? Border.all(
                                              color: Colors.white, width: 2)
                                          : null,
                                    ),
                                  ),
                                );
                              } else {
                                // Custom color button
                                return IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.6)),
                                    shape: WidgetStateProperty.all(
                                      const CircleBorder(),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showColorPicker(context);
                                  },
                                  icon: Icon(Icons.add,
                                      color: Theme.of(context).indicatorColor),
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Text Color Selection
                        Text(
                          "Text Color",
                          style: TextStyle(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.7),
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _textColor = Colors.white;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: _textColor == Colors.white
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)
                                      : Border.all(
                                          color: Colors.grey, width: 1),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _textColor = Colors.black;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  border: _textColor == Colors.black
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)
                                      : Border.all(
                                          color: Colors.grey, width: 1),
                                ),
                              ),
                            ),
                            IconButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.6)),
                              ),
                              onPressed: () {
                                _showTextColorPicker(context);
                              },
                              icon: Icon(Icons.add,
                                  color: Theme.of(context).indicatorColor),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        // Font Style Selection
                        Text(
                          "Font Style",
                          style: TextStyle(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.7),
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildFontStyleOption("Sans-Serif", "Sans-Serif"),
                            const SizedBox(width: 10),
                            _buildFontStyleOption("Serif", "Serif"),
                            const SizedBox(width: 10),
                            _buildFontStyleOption("Mono", "Mono"),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),

                        // Company Logo Section
                        const SizedBox(height: 20),
                        Text(
                          Headlines.companyLogo,
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: CircleAvatar(
                                radius: 32,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Image.asset(
                                      Images.splashImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {},
                              label: Text(
                                Texts.changeLogo,
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor),
                              ),
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).indicatorColor,
                              ),
                              style: ButtonStyle(
                                elevation: WidgetStateProperty.all(7.0),
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).primaryColor),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),

                        // Contact Information Section
                        const SizedBox(height: 20),
                        Text(
                          Headlines.contactInfo,
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(context, "Email Address"),
                        const SizedBox(height: 10),
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
                        ),

                        const SizedBox(height: 20),
                        _buildTextField(context, "Phone Number"),
                        const SizedBox(height: 10),
                        _buildInputField(
                          context,
                          "eg: +255 716 521 848",
                          _phoneNumberController,
                          const Icon(Icons.phone),
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            // Validate Tanzanian phone format: +255 7XX XXX XXX
                            if (!RegExp(r'^\+255\s7\d{2}\s\d{3}\s\d{3}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid phone number in format: +255 7XX XXX XXX';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        _buildTextField(context, "Website link"),
                        const SizedBox(height: 10),
                        _buildInputField(
                          context,
                          "eg: www.certainwebsite.com",
                          _websiteController,
                          const Icon(Icons.language),
                          (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter website link';
                            }
                            // Simple URL validation
                            if (!RegExp(r'^(www\.)?.+\..+').hasMatch(value)) {
                              return 'Please enter a valid website URL';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTextField(context, "Business location"),
                                  const SizedBox(height: 5),
                                  _buildInputField(
                                    context,
                                    "eg: Mabibo Dar-es-Salaam",
                                    _locationController,
                                    Icon(CupertinoIcons.location,
                                        color:
                                            Theme.of(context).indicatorColor),
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter business location';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _organizationAddress = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.location_on,
                                color: Theme.of(context).indicatorColor,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),

                        // Social Media Section
                        const SizedBox(height: 20),
                        Text(
                          "Social Media",
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Social Media Links
                        ..._buildSocialMediaFields(),

                        const SizedBox(height: 10),
                        Center(
                          child: TextButton.icon(
                            onPressed: _addMoreSocialMedia,
                            icon: const Icon(Icons.add),
                            label: const Text("Add More Social Media"),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Build social media input fields
  List<Widget> _buildSocialMediaFields() {
    List<Widget> fields = [];

    for (int i = 0; i < _socialMediaLinks.length; i++) {
      final link = _socialMediaLinks[i];
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: link['controller'],
            decoration: InputDecoration(
              labelText: "${link['platform']} profile URL",
              prefixIcon: Icon(link['icon']),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Basic URL validation
                if (!RegExp(r'^(http|https)://.*').hasMatch(value) &&
                    !RegExp(r'^www\..*').hasMatch(value)) {
                  return 'Please enter a valid URL';
                }
              }
              return null;
            },
          ),
        ),
      );
    }

    return fields;
  }

  // Add more social media fields
  void _addMoreSocialMedia() {
    setState(() {
      final controller = TextEditingController();
      _socialMediaLinks.add({
        'platform': 'Other',
        'controller': controller,
        'icon': Icons.link,
      });
    });
  }

  // Build font style option button
  Widget _buildFontStyleOption(String title, String fontStyle) {
    bool isSelected = _selectedFontStyle == fontStyle;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFontStyle = fontStyle;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: _getFontFamily(fontStyle),
            color: isSelected ? Colors.white : Theme.of(context).indicatorColor,
          ),
        ),
      ),
    );
  }

  // Get font family based on selected style
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

  // Show color picker dialog
  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show text color picker dialog
  void _showTextColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick text color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _textColor,
              onColorChanged: (Color color) {
                setState(() {
                  _textColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Widget _buildTextField(BuildContext context, String labelText) {
  return Text(
    labelText,
    style: GoogleFonts.nunito(
      fontSize: 14,
      color: Theme.of(context).indicatorColor.withOpacity(0.7),
      backgroundColor: Colors.transparent,
    ),
  );
}

Widget _buildInputField(
  BuildContext context,
  String hintText,
  TextEditingController controller,
  Icon prefixIcon,
  String? Function(String?)? validator, {
  Function(String)? onChanged,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    onChanged: onChanged,
    style: GoogleFonts.nunito(
      textStyle: TextStyle(color: Theme.of(context).primaryColor),
      fontWeight: FontWeight.w500,
      backgroundColor: Colors.transparent,
    ),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      prefixIcon: prefixIcon,
      labelText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    ),
  );
}

Widget _buildCustomizableCard(
  BuildContext context,
  String organizationLogoPath,
  String organizationName,
  String organizationAddress,
  Color colorTemplate,
) {
  // Get the font style state
  String fontFamily = 'sans-serif';
  if (context is StatefulElement && context.state is CreateNewCardState) {
    final state = context.state as CreateNewCardState;
    fontFamily = state._getFontFamily(state._selectedFontStyle);
  }

  // Get the text color
  Color textColor = Colors.white;
  if (context is StatefulElement && context.state is CreateNewCardState) {
    final state = context.state as CreateNewCardState;
    textColor = state._textColor;
  }

  return Card(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    color: colorTemplate,
    elevation: 8.0,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                child: ClipOval(
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      organizationLogoPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(CupertinoIcons.heart, size: 20),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share, size: 20),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Icon(Icons.business, color: textColor),
              const SizedBox(width: 5),
              Text(
                organizationName,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Divider(height: 1, color: textColor.withOpacity(0.5)),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Icon(Icons.location_on, color: textColor),
              const SizedBox(width: 5),
              Text(
                organizationAddress,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: fontFamily,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    ),
  );
}
