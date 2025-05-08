import 'package:ecard_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//ignore_for_file: must_be_immutable
class HeaderBoldWidget extends StatelessWidget {
  String text;
  Color color;
  String size;

  HeaderBoldWidget(
      {super.key, required this.text, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.aBeeZee(
          textStyle: TextStyle(
              color: color,
              fontSize: double.parse(size),
              fontWeight: FontWeight.w900)),
    );
  }
}

class NormalHeaderWidget extends StatelessWidget {
  String text;
  Color color;
  String size;
  Color? backgroundColor;

  NormalHeaderWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.size,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.aBeeZee(
          textStyle: TextStyle(
              color: color,
              fontSize: double.parse(size),
              background: Paint()
                ..color = backgroundColor ?? Colors.transparent
                ..style = PaintingStyle.fill,
              fontWeight: FontWeight.w500)),
    );
  }
}

class HeaderCenterWidget extends StatelessWidget {
  String text;
  Color color;
  String size;

  HeaderCenterWidget(
      {super.key, required this.text, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.aBeeZee(
          textStyle: TextStyle(
              color: color,
              fontSize: double.parse(size),
              fontWeight: FontWeight.w500)),
    );
  }
}

class InputField extends StatefulWidget {
  final String field;
  final String hintText;
  final Icon icon;
  final TextEditingController? controller;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const InputField({
    super.key,
    required this.field,
    required this.hintText,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final formData = authProvider.formData[authProvider.currentScreen];

    // If a controller was provided, use it
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      // Otherwise create a new controller initialized with form data
      _controller = TextEditingController(text: formData?[widget.field] ?? '');
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return TextFormField(
      controller: _controller,
      obscureText: widget.obscureText,
      onChanged: (value) {
        // Update form data when text changes
        authProvider.updateFormField(widget.field, value);
      },
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${widget.hintText}';
            }
            return null;
          },
      style: GoogleFonts.nunito(
        textStyle: TextStyle(color: Theme.of(context).primaryColor),
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.transparent,
      ),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        prefixIcon: widget.icon,
        labelText: widget.hintText,
        labelStyle: TextStyle(color: Theme.of(context).indicatorColor),
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
    );
  }
}
