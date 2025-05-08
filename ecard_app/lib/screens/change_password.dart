import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _currentPassword;
  String? _newPassword;
  final String _passwordStrength = 'Very Weak ';
  bool formIsSubmitted = false;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmationPasswordController =
      TextEditingController();
  String? _confirmationPassword;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).highlightColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Back",
          style:
              TextStyle(fontSize: 20, color: Theme.of(context).indicatorColor),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).indicatorColor,
        ),
        toolbarTextStyle: TextStyle(
          color: Theme.of(context).indicatorColor,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).indicatorColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).highlightColor,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
          child: Column(children: [
            HeaderBoldWidget(
                text: "Change Your Account Password",
                color: Theme.of(context).primaryColor,
                size: '22.0'),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Your new Password must be different from previous used passwords",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(
              height: 40,
            ),
            DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(5.0, 5.0),
                      ),
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(-5.0, -5.0),
                      )
                    ]),
                child: Form(
                  autovalidateMode: formIsSubmitted
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          NormalHeaderWidget(
                              text: "Current Password",
                              color: Theme.of(context).indicatorColor,
                              size: '14.0'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onSaved: (value) => _currentPassword = value,
                            autofocus: false,
                            onChanged: (value) =>
                                auth.updateFormField('password', value),
                            controller: _currentPasswordController,
                            validator: (value) =>
                                value!.isEmpty ? "Please Enter password" : null,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.nunito(
                              backgroundColor: Colors.transparent,
                              textStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter Current Password",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          NormalHeaderWidget(
                              text: "New Password",
                              color: Theme.of(context).indicatorColor,
                              size: '14.0'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onSaved: (value) => _newPassword = value,
                            autofocus: false,
                            onChanged: (value) =>
                                auth.updateFormField('password', value),
                            controller: _newPasswordController,
                            validator: (value) =>
                                value!.isEmpty ? "Please Enter password" : null,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.nunito(
                              backgroundColor: Colors.transparent,
                              textStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter New Password",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password Strength',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _passwordStrength,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Password must contain:',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordRequirementRow([
                            PasswordRequirement(
                                text: "Minimum 8 characters", met: false),
                            PasswordRequirement(
                                text: "Include numbers", met: false),
                          ]),
                          const SizedBox(height: 8),
                          _buildPasswordRequirementRow([
                            PasswordRequirement(
                                text: "Special characters", met: false),
                            PasswordRequirement(
                                text: "Uppercase letters", met: false),
                          ]),
                          const SizedBox(height: 20),
                          NormalHeaderWidget(
                              text: "Confirm New Password",
                              color: Theme.of(context).indicatorColor,
                              size: '14.0'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onSaved: (value) => _confirmationPassword = value,
                            autofocus: false,
                            onChanged: (value) =>
                                auth.updateFormField('password', value),
                            controller: _confirmationPasswordController,
                            validator: (value) => value!.isEmpty
                                ? "Please Enter confirmation password"
                                : null,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.nunito(
                              backgroundColor: Colors.transparent,
                              textStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter confirmation Password",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Theme.of(context).focusColor),
                                    elevation: WidgetStateProperty.all(
                                        2), // Subtle elevation
                                    shadowColor: WidgetStateProperty.all(
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(1), // Very subtle shadow
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Optional: Add border radius
                                      ),
                                    ),
                                  ),
                                  child: NormalHeaderWidget(
                                    text: 'Clear All',
                                    color: Theme.of(context).indicatorColor,
                                    size: '20.0',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Theme.of(context).primaryColor),
                                    elevation: WidgetStateProperty.all(
                                        2), // Subtle elevation
                                    shadowColor: WidgetStateProperty.all(
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(1), // Very subtle shadow
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Optional: Add border radius
                                      ),
                                    ),
                                  ),
                                  child: NormalHeaderWidget(
                                    text: 'Change Password',
                                    color: Theme.of(context).indicatorColor,
                                    size: '20.0',
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
          ]),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirementRow(List<PasswordRequirement> requirements) {
    return Row(
      children: [
        for (var requirement in requirements)
          Expanded(
            child: Row(
              children: [
                Icon(
                  requirement.met
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: requirement.met ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    requirement.text,
                    style: TextStyle(
                      color: requirement.met ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class PasswordRequirement {
  final String text;
  final bool met;

  PasswordRequirement({required this.text, required this.met});
}
