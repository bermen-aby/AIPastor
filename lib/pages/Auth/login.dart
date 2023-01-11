import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:newapp/services/apiServices.dart';
import 'package:provider/provider.dart';

import '../../provider/social_sign_in_provider.dart';
import '../../utils/progress_hud.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  //final RateMyApp? rateMyApp;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;
  bool isApiCallProcess = false;
  bool appleLogin = false;
  int socialChoice = 0;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String? username;
  String? password;
  String? email;
  String? familyName;
  String? givenName;

  late APIService apiService;

  @override
  void initState() {
    apiService = APIService();
    //initLocale();
    super.initState();
  }

  // ignore: avoid_void_async
  /*void initDarkMode() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await SharedService.isDarkMode()
        ? themeProvider.toggleTheme(true)
        : themeProvider.toggleTheme(false);
  }

  Future<bool> initLocale() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languageCode = await SharedService.getLanguage();
    if (languageCode != null) {
      localeProvider.setLocale(Locale(languageCode));
      return true;
    }
    return false;
  }*/

  @override
  Widget build(BuildContext context) {
    //final firebaseUser = context.watch<User>();
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: <Widget>[
              Container(
                // width: double.infinity,
                // height: double.infinity,
                child: Neumorphic(
                  //width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 90, horizontal: 20),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(20),
                  //   color: Colors.white,
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Theme.of(context).hintColor.withOpacity(0.2),
                  //       offset: const Offset(0, 10),
                  //       blurRadius: 20,
                  //     )
                  //   ],
                  // ),
                  child: Form(
                    key: globalKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Image.asset('assets/logos/logo.png'),
                        const SizedBox(height: 20),
                        Text(
                          "Sign in",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSaved: (input) => username = input,
                          /*validator: (input) => !input!.contains('@')
                                ? "Entrez un email valide"
                                : null,*/
                          decoration: InputDecoration(
                            hintText: "login",
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                          obscureText: hidePassword,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSaved: (input) => password = input,
                          onFieldSubmitted: (term) {
                            //connect();
                          },
                          validator: (input) =>
                              input!.length < 3 ? "Password required" : null,
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                            enabledBorder: const UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            //connect();
                          },
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 80,
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.secondary,
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              const StadiumBorder(),
                            ),
                          ),
                          child: Text(
                            "Sign in",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "or",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    isApiCallProcess = true;
                                  });
                                  socialChoice = 1;
                                  try {
                                    final provider =
                                        Provider.of<SocialSignInProvider>(
                                      context,
                                      listen: false,
                                    );
                                    print('log: init signin');
                                    provider
                                        .signInWithGoogle(context)
                                        .then((value) {
                                      setState(() {
                                        isApiCallProcess = false;
                                      });
                                      if (value != null) {
                                        //socialLoginProcess();
                                      }
                                    });
                                  } catch (e) {
                                    if (e is FirebaseAuthException) {
                                      showMessage();
                                    }
                                  }
                                },
                                child: SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: Image.asset(
                                    "assets/logos/logo-google.png",
                                    cacheWidth: 98,
                                    cacheHeight: 98,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    isApiCallProcess = true;
                                  });
                                  socialChoice = 2;
                                  try {
                                    final provider =
                                        Provider.of<SocialSignInProvider>(
                                      context,
                                      listen: false,
                                    );
                                    provider
                                        .signInWithFacebook(context)
                                        .then((value) {
                                      setState(() {
                                        isApiCallProcess = false;
                                      });
                                      print("value $value");
                                      if (value != null) {
                                        //facebookLoginProcess(value);
                                      }
                                    });
                                  } catch (e) {
                                    if (e is FirebaseAuthException) {
                                      setState(() {
                                        isApiCallProcess = false;
                                      });
                                      showMessage();
                                    }
                                  }
                                  setState(() {
                                    isApiCallProcess = false;
                                  });
                                },
                                child: SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: Image.asset(
                                    "assets/logos/logo-facebook.png",
                                    cacheWidth: 98,
                                    cacheHeight: 98,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isApiCallProcess = true;
                                  });
                                  socialChoice = 3;
                                  final provider =
                                      Provider.of<SocialSignInProvider>(
                                    context,
                                    listen: false,
                                  );
                                  try {
                                    provider
                                        .signInWithTwitter(context)
                                        .then((value) {
                                      print(
                                        "***DEV-LOG***: signInWithTwitter value $value",
                                      );
                                      setState(() {
                                        isApiCallProcess = false;
                                      });
                                      if (value != null) {
                                        //socialLoginProcess();
                                      }
                                    });
                                  } catch (e) {
                                    if (e is FirebaseAuthException) {
                                      print(
                                        "DEV-LOG: FirebaseAuthException code: ${e.code}",
                                      );
                                      //showMessage();
                                    }
                                  }
                                },
                                child: SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: Image.asset(
                                    "assets/logos/logo-twitter.png",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        //if (Platform.isIOS)
                        if (appleSignInAvailable.isAvailable)
                          ElevatedButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 25,
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white70,
                              ),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                const StadiumBorder(),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isApiCallProcess = true;
                              });
                              try {
                                final provider =
                                    Provider.of<SocialSignInProvider>(
                                  context,
                                  listen: false,
                                );
                                provider.signInWithApple(context).then((value) {
                                  setState(() {
                                    isApiCallProcess = false;
                                  });
                                  if (value != null) {
                                    //appleLoginProcess(value);
                                  }
                                });
                              } catch (e) {
                                if (e is FirebaseAuthException) {
                                  showMessage();
                                }
                              }
                              setState(() {
                                isApiCallProcess = false;
                              });
                            },
                            child: SizedBox(
                              height: 20,
                              //width: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: Image.asset(
                                      "assets/logos/logo-apple.png",
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      "Sign in with Apple",
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => SignUp(),
                                //   ),
                                // );
                              },
                              child: Text("Sign up"),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         const ResetPasswordBasePage(),
                                  //   ),
                                  // );
                                },
                                child: Text(
                                  "Forgot password?",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                //initDarkMode();
                                // Navigator.of(context).pushReplacement(
                                //   MaterialPageRoute(
                                //     builder: (context) => HomePage(
                                //       rateMyApp: widget.rateMyApp,
                                //     ),
                                //   ),
                                // );
                              },
                              child: Text(
                                "Continue without signing in",
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            // TextButton(
                            //   onPressed: () {
                            //     showDialog(
                            //       context: context,
                            //       builder: (context) {
                            //         return const LanguagePopUpWidget();
                            //       },
                            //     );
                            //   },
                            //   child: Text(
                            //     AppLocalizations.of(context)!.currentLanguage,
                            //     style: const TextStyle(
                            //       color: Colors.black54,
                            //       decoration: TextDecoration.underline,
                            //     ),
                            //   ),
                            // ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  /* void appleLoginProcess(User user) {
    setState(() {
      isApiCallProcess = true;
    });
    final CustomerDetailsModel model = CustomerDetailsModel();
    model.billing = Billing();
    model.shipping = Shipping();
    model.email = user.email;
    model.username = user.email;
    model.lastName = user.displayName;
    //model.firstName = givenName;
    model.avatarURL = user.photoURL;
    model.billing!.phone = user.phoneNumber;
    model.billing!.email = email;
    appleLogin = false;
    socialLoginRequest(model);
  }

  void facebookLoginProcess(Map<String, dynamic> user) {
    setState(() {
      isApiCallProcess = true;
    });
    final CustomerDetailsModel model = CustomerDetailsModel();
    model.billing = Billing();
    model.shipping = Shipping();
    model.email = user['email'] as String;
    model.username = model.email;
    model.lastName = user['name'] as String;
    // final picture =
    //     FacebookPicture.fromJson(user['picture'] as Map<String, dynamic>);
    // //model.firstName = givenName;
    // model.avatarURL = picture.data?.url;
    // model.billing!.phone = user.phoneNumber;
    model.billing!.email = model.email;
    appleLogin = false;
    socialLoginRequest(model);
  }

  void socialLoginProcess() {
    final user = FirebaseAuth.instance.currentUser;
    if (appleLogin) {
      final CustomerDetailsModel model = CustomerDetailsModel();
      model.billing = Billing();
      model.shipping = Shipping();
      model.email = email;
      model.username = givenName;
      model.lastName = familyName;
      model.firstName = givenName;
      //model.avatarURL = user.photoURL;
      //model.billing!.phone = user.phoneNumber;
      model.billing!.email = email;
      appleLogin = false;
      socialLoginRequest(model);
    } else if (user != null) {
      //print("***DEV-LOG***: socialLoginProcess User $user");
      setState(() {
        isApiCallProcess = true;
      });
      final CustomerDetailsModel model = CustomerDetailsModel();
      model.billing = Billing();
      model.shipping = Shipping();
      model.email = user.email;
      model.avatarURL = user.photoURL;
      model.billing!.phone = user.phoneNumber;
      model.billing!.email = user.email;

      //model.password = user.uid;
      socialLoginRequest(model);
    } else {
      print("***DEV-LOG***: socialLoginProcess User is null");
    }
    // if (socialChoice == 3) {
    //   showMessage();
    // }
    socialChoice = 0;
  }

  bool socialLoginRequest(CustomerDetailsModel model) {
    apiService.socialSignupRequest(model).then(
      (value) {
        if (value != null) {
          SharedService.setLoginDetails(value);
          model.id = value.data?.id;

          if (model.id != null) {
            apiService.updateCustomer(model);
          }
          FormHelper.showMessage(
            context,
            AppLocalizations.of(context)!.congrats,
            AppLocalizations.of(context)!.loginConfirmation,
            AppLocalizations.of(context)!.okText,
            () {
              //initDarkMode();
              setState(() {
                isApiCallProcess = true;
              });
              Navigator.of(context).pushReplacement(
                //pushandremoveuntil
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    rateMyApp: widget.rateMyApp,
                  ),
                ), //ModalRoute.withName("/Home"),
              );
            },
          );
          //initDarkMode();
          setState(() {
            isApiCallProcess = true;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomePage(
                rateMyApp: widget.rateMyApp,
              ),
            ),
          );
        } else {
          FormHelper.showMessage(
            context,
            AppLocalizations.of(context)!.sorryText,
            AppLocalizations.of(context)!.loginError,
            AppLocalizations.of(context)!.okText,
            () {
              setState(() {
                isApiCallProcess = true;
              });
              Navigator.of(context).pop();
            },
          );
        }
      },
    );
    return true;
  }*/

  void showMessage() {
    showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          title: Text(
            "Error",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              //color: PremStyle.primary.shade900,
            ),
          ),
          content: Text("Same account"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                Navigator.of(builderContext).pop();
              },
            )
          ],
        );
      },
    );
  }

  /* void connect() {
    if (validateAndSave()) {
      setState(() {
        isApiCallProcess = true;
      });
      apiService.loginCustomer(username!, password!).then((ret) {
        setState(() {
          isApiCallProcess = false;
        });

        if (ret != null) {
          SharedService.setLoginDetails(ret);
          FormHelper.showMessage(
            context,
            AppLocalizations.of(context)!.congrats,
            AppLocalizations.of(context)!.loginConfirmation,
            AppLocalizations.of(context)!.okText,
            () {
              //initDarkMode();
              Navigator.of(context).pushReplacement(
                //pushandremoveuntil
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    rateMyApp: widget.rateMyApp,
                  ),
                ), //ModalRoute.withName("/Home"),
              );
            },
          );
          //initDarkMode();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomePage(
                rateMyApp: widget.rateMyApp,
              ),
            ),
          );
        } else {
          FormHelper.showMessage(
              context,
              AppLocalizations.of(context)!.sorryText,
              AppLocalizations.of(context)!.loginError,
              AppLocalizations.of(context)!.okText, () {
            Navigator.of(context).pop();
          });
        }
      });
    }
  }*/
}

class ResetPasswordPage {}
