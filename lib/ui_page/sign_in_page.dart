import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/local_auth_controller.dart';
import 'package:flutwest/controller/secure_storage_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/cust_widget/west_logo.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/ui_page/sign_in_loading_page.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../model/vars.dart';

enum TextFieldFocus { none, customID, password }

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _customIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPasswordCancel = false;
  bool _showIDCancel = false;

  String _errorMsg = "";

  TextFieldFocus _textFieldFocus = TextFieldFocus.none;

  late bool _changeUser;
  late bool _isinBiometicLogin;
  bool _memberHasBiometric = false;

  @override
  void initState() {
    _changeUser = Member.lastLoginMemberId == null;
    // no records of member in database means no biometric login
    _isinBiometicLogin = Member.lastLoginMemberId != null && true;

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _fingerPrintLogin();
    });

    super.initState();
  }

  Future<void> _fingerPrintLogin() async {
    bool authenticated = false;
    if (Member.lastLoginMemberId != null) {
      _memberHasBiometric = await SecureStorageController.instance
          .containsKey(Member.lastLoginMemberId!);
      if (_memberHasBiometric) {
        try {
          authenticated = await LocalAuthController.instance.localAuthentication
              .authenticate(
                  authMessages: const [
                AndroidAuthMessages(
                    signInTitle: "Sign in to Westpac",
                    biometricHint: "",
                    cancelButton: "USE PASSWORD")
              ],
                  localizedReason: "Confirm your biometrics to continue",
                  options: const AuthenticationOptions(
                      useErrorDialogs: true,
                      stickyAuth: true,
                      biometricOnly: true));
        } on PlatformException catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error, ${error.code}")));
        }
      }
    }

    if (authenticated) {
      // password should not be nullable
      String? password = await SecureStorageController.instance
          .read(Member.lastLoginMemberId!);
      handleSignIn(Member.lastLoginMemberId!, password);
    }

    setState(() {
      _isinBiometicLogin = false;
      _memberHasBiometric;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const BackgroundImage(),
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: StandardPadding(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            SystemNavigator.pop();
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                              highlightColor: Colors.green,
                              splashColor: Colors.green),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  splashFactory: InkSplash.splashFactory),
                              onPressed: () {
                                int delay;
                                if (FirestoreController
                                        .instance.delay.inMilliseconds !=
                                    500) {
                                  delay = 500;
                                  FirestoreController.instance.delay =
                                      const Duration(milliseconds: 500);
                                } else {
                                  delay = 0;
                                  FirestoreController.instance.delay =
                                      Duration.zero;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Firestore additonal delay set to $delay milliseconds")));
                              },
                              child: const Text(
                                "Add Delay",
                                style: TextStyle(color: Colors.transparent),
                              )),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      const StandardPadding(child: WestLogo(width: 50.0)),
                      _getInputArea(),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _getErrorMsg() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
            vertical: Vars.heightGapBetweenWidgets / 2),
        padding: const EdgeInsets.symmetric(
            vertical: Vars.topBotPaddingSize,
            horizontal: Vars.standardPaddingSize),
        decoration: const BoxDecoration(
            color: Color.fromARGB(20, 244, 67, 54),
            border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.red),
                top: BorderSide(width: 1.0, color: Colors.red))),
        child: Text(_errorMsg,
            style: const TextStyle(color: Colors.white, fontSize: 14.0)));
  }

  Widget _getInputArea() {
    return Container(
      margin: const EdgeInsets.only(top: 25.0, bottom: 65),
      padding: const EdgeInsets.symmetric(
          vertical: Vars.topBotPaddingSize,
          horizontal: Vars.standardPaddingSize),
      decoration: BoxDecoration(
          color: const Color.fromARGB(167, 27, 1, 31),
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(width: 1.0, color: Colors.grey)),
      child: Column(
        children: [
          _errorMsg.isNotEmpty ? _getErrorMsg() : const SizedBox(),
          _getTextFields(),
          !_isinBiometicLogin
              ? _getForgotPassword()
              : const SizedBox(
                  height: 180,
                ),
          _getSignInButton(),
          !_isinBiometicLogin ? _getRegisterButton() : const SizedBox(),
        ],
      ),
    );
  }

  Widget _getTextFields() {
    return Column(
      children: [
        _changeUser || Member.lastLoginMemberId == null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Vars.topBotPaddingSize),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  controller: _customIDController,
                  onTap: () {
                    if (_textFieldFocus != TextFieldFocus.customID) {
                      setState(() {
                        _textFieldFocus = TextFieldFocus.customID;
                      });
                    }
                  },
                  onChanged: (value) {
                    if (_textFieldFocus == TextFieldFocus.customID) {
                      if (value.isNotEmpty) {
                        if (!_showIDCancel) {
                          setState(() {
                            _showIDCancel = true;
                          });
                        }
                      } else {
                        if (_showIDCancel) {
                          setState(() {
                            _showIDCancel = false;
                          });
                        }
                      }
                    }
                  },
                  decoration: InputDecoration(
                      counterText: "",
                      labelText: "Customer ID",
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0)),
                      suffixIcon: _textFieldFocus == TextFieldFocus.customID &&
                              _showIDCancel
                          ? IconButton(
                              icon:
                                  const Icon(Icons.cancel, color: Colors.white),
                              onPressed: () {
                                _customIDController.clear();
                                setState(() {
                                  _showIDCancel = false;
                                });
                              },
                            )
                          : const SizedBox()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Sign in as * * * * ${Member.lastLoginMemberId!.substring(4)}",
                      style: Vars.headingStyle2.copyWith(color: Colors.white)),
                  GestureDetector(
                    child: const Text(
                      "Change",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: Vars.paragraphTextSize),
                    ),
                    onTap: () async {
                      Object? result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Sign in as someone else?"),
                              content: const Text(
                                  "This will clear your settings saved on this device"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Continue"))
                              ],
                            );
                          });

                      if (result != null && (result as bool)) {
                        setState(() {
                          _changeUser = true;
                        });

                        // check null just in case, this shouldn't be null
                        if (Member.lastLoginMemberId != null) {
                          Future.wait([
                            SQLiteController.instance.tableMember
                                .updateNotifyLocalAuth(
                                    Member.lastLoginMemberId!, false),
                            SecureStorageController.instance
                                .delete(Member.lastLoginMemberId!)
                          ]);
                        }
                      }
                    },
                  )
                ],
              ),
        !_isinBiometicLogin
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Vars.topBotPaddingSize),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _passwordController,
                  obscureText: true,
                  onTap: () {
                    if (_textFieldFocus != TextFieldFocus.password) {
                      setState(() {
                        _textFieldFocus = TextFieldFocus.password;
                      });
                    }

                    if (_changeUser) {
                      if (_customIDController.text.length < 8) {
                        if (_errorMsg.isEmpty) {
                          setState(() {
                            _errorMsg =
                                "Customer ID is too short. Enter 8 digits.";
                          });
                        }
                      } else {
                        if (_errorMsg.isNotEmpty) {
                          _errorMsg = "";
                        }
                      }
                    }
                  },
                  onChanged: (value) {
                    if (_textFieldFocus == TextFieldFocus.password) {
                      if (value.isNotEmpty) {
                        if (!_showPasswordCancel) {
                          setState(() {
                            _showPasswordCancel = true;
                          });
                        }
                      } else {
                        if (_showPasswordCancel) {
                          setState(() {
                            _showPasswordCancel = false;
                          });
                        }
                      }
                    }
                  },
                  maxLength: 6,
                  decoration: InputDecoration(
                      labelText: "Password",
                      counterText: "",
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0)),
                      suffixIcon: _textFieldFocus == TextFieldFocus.password &&
                              _showPasswordCancel
                          ? IconButton(
                              icon:
                                  const Icon(Icons.cancel, color: Colors.white),
                              onPressed: () {
                                _passwordController.clear();
                                setState(() {
                                  _showPasswordCancel = false;
                                });
                              },
                            )
                          : const SizedBox()),
                ),
              )
            : const SizedBox()
      ],
    );
  }

  Widget _getForgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets * 1.5),
      child: GestureDetector(
        onTap: () {},
        child: Row(children: const [
          Text(
            "Forgot customer ID or password",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          SizedBox(width: 3.0),
          Icon(
            Icons.arrow_right_outlined,
            color: Colors.white,
          )
        ]),
      ),
    );
  }

  Widget _getSignInButton() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(3)),
      margin: const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets / 4),
      child: Material(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(3.0),
        child: InkWell(
          highlightColor: const Color.fromARGB(80, 243, 123, 123),
          onTap: () async {
            String errMsg = "";

            if (_changeUser) {
              if (_customIDController.text.length < 8) {
                errMsg = "Enter 8 digits";
              }
            }
            if (errMsg.isEmpty) {
              if (_passwordController.text.isEmpty) {
                errMsg = "No password entered";
              } else if (_passwordController.text.length < 6) {
                errMsg =
                    "Your password does no meet requirements. Please try again.";
                _passwordController.clear();
              }
            }
            if (errMsg.isNotEmpty) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(errMsg),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Ok"))
                      ],
                    );
                  });
            } else {
              String userName = _changeUser
                  ? _customIDController.text
                  : Member.lastLoginMemberId ?? _customIDController.text;

              await handleSignIn(userName, _passwordController.text);

              _customIDController.clear();
              _passwordController.clear();
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(
                vertical: Vars.topBotPaddingSize,
                horizontal: Vars.standardPaddingSize),
            child: Center(
                child: Text("Sign in",
                    style: TextStyle(color: Colors.white, fontSize: 18.0))),
          ),
        ),
      ),
    );
  }

  Future<void> handleSignIn(String userName, String? password) async {
    Object? result = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: ((context, animation, secondaryAnimation) =>
                SignInLoadingPage(
                  userName: userName,
                  password: password,
                )),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero));

    if (result != null) {
      if (result is FirebaseAuthException) {
        String errMsg = "Unknown Error";

        if (result.code == 'user-not-found') {
          errMsg = 'No user found for that email.';
        } else if (result.code == 'wrong-password') {
          errMsg = 'Wrong password provided for that user.';
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errMsg)));

        return;
      } else if (result is String) {
        String message = result;
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      }
    }
  }

  Widget _getRegisterButton() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(width: 1.0, color: Colors.red)),
      margin: const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets / 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.0),
        child: InkWell(
          onTap: () async {
            if (_memberHasBiometric) {
              _fingerPrintLogin();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Vars.topBotPaddingSize,
                horizontal: Vars.standardPaddingSize),
            child: Center(
              child: Text(
                _memberHasBiometric
                    ? "Try Biometrics again"
                    : "Register for online banking",
                style: const TextStyle(color: Colors.black, fontSize: 18.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
