// ignore_for_file: avoid_classes_with_only_static_members, use_build_context_synchronously, avoid_bool_literals_in_conditional_expressions
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show
        AuthCredential,
        FacebookAuthProvider,
        FirebaseAuth,
        FirebaseAuthException,
        GoogleAuthProvider,
        OAuthCredential,
        OAuthProvider,
        TwitterAuthProvider,
        User,
        UserCredential;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:newapp/services/apiServices.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';

import '../services/shared_service.dart';
import '../utils/form_helper.dart';
import '../utils/utils.dart';

class SocialSignInProvider extends ChangeNotifier {
  late GoogleSignIn _googleSignIn;
  late bool _isSigningIn;
  late FacebookAuth _facebookAuth;
  late TwitterLogin _twitterLogin;
  late FirebaseAuth _firebaseAuth;

  SocialSignInProvider() {
    _firebaseAuth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
    _facebookAuth = FacebookAuth.instance;
    _isSigningIn = false;
    // _twitterLogin = TwitterLogin(
    //   apiKey: Config.twitterAPIKey,
    //   apiSecretKey: Config.twitterAPISecret,
    //   // Registered Callback URLs in TwitterApp
    //   // Android is a deeplink
    //   // iOS is a URLScheme
    //   redirectURI: Config.twitterCallback,
    // );
  }
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;
  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    bool isSigned = false;
    try {
      isSigned = await _googleSignIn.isSignedIn();
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    print('1');
    if (isSigned) {
      await _googleSignIn.disconnect();
    }
    print('1,5');
    try {
      final googleUser = await _googleSignIn.signIn();
      print('2');
      if (googleUser != null) {
        _user = googleUser;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        _isSigningIn = false;
        notifyListeners();
        print('3');
        return signInWithCredential(context, credential);
      } else {
        return null;
      }
    } catch (e) {
      // TODO dialog: missing google services
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> signInWithFacebook(
    BuildContext context, {
    AuthCredential? pendingCredential,
  }) async {
    bool isSigned = false;
    try {
      isSigned = (await _facebookAuth.accessToken != null) ? true : false;
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    if (isSigned) {
      await _facebookAuth.logOut();
    }
    try {
      final LoginResult result = await _facebookAuth.login();
      print(result.status);
      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        print("access token ${result.accessToken}");
        //final accessToken = result.accessToken;
        final token = result.accessToken?.token;
        print("token $token");
        final OAuthCredential credential =
            FacebookAuthProvider.credential(token!);
        // Once signed in, return the UserCredential
        print("credential $credential");
        final userCredential = await signInWithCredential(context, credential);
        print(userCredential);
        if (pendingCredential != null) {
          await userCredential?.user?.linkWithCredential(pendingCredential);
        }
        final userData = await FacebookAuth.instance.getUserData();
        print("userdata $userData");
        return userData;
        //return FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on Exception catch (e) {
      // TODO
      print("error $e");
    }
    return null;
  }

  Future<UserCredential?> signInWithTwitter(BuildContext context) async {
    try {
      final authResult = await _twitterLogin.login();
      OAuthCredential twitterAuthCredential;
      if (authResult.authToken != null && authResult.authTokenSecret != null) {
        twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );
        print("***DEV-LOG***: Token not null");
        final userCredential =
            await signInWithCredential(context, twitterAuthCredential);
        print(userCredential);
        return userCredential;
      } else {
        // todo no twitter
      }
    } on Exception catch (e) {
      // TODO
      print("***DEV-LOG***: exception: $e");
    }
    return null;
  }

  Future<bool> logout() async {
    _googleSignIn.disconnect();
    _facebookAuth.logOut();
    FirebaseAuth.instance.signOut();
    return true;
  }

  Future<UserCredential?> signInWithCredential(
    BuildContext context,
    OAuthCredential credential,
  ) async {
    try {
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print("LOG: FirebaseAuthException code: ${e.code}");
      if (e.code == 'account-exists-with-different-credential') {
        differentCredentialsMsg(
          context,
          e,
        );
      } else if (e.code == 'invalid-email') {
        invalidEmailMsg(context);
      }
    }
    return null;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Stream<User?>? get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> signInWithApple(
    BuildContext context, {
    AuthCredential? pendingCredential,
  }) async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final UserCredential? authResult;
      try {
        authResult = await signInWithCredential(context, oauthCredential);
        final displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
        final userEmail = '${appleCredential.email}';

        if (authResult != null) {
          if (pendingCredential != null) {
            await authResult.user?.linkWithCredential(pendingCredential);
          }
          final firebaseUser = authResult.user;
          print(displayName);
          await firebaseUser?.updateDisplayName(displayName);
          await firebaseUser?.updateEmail(userEmail);

          return firebaseUser;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          differentCredentialsMsg(
            context,
            e,
          );
        } else if (e.code == 'invalid-email') {
          invalidEmailMsg(context);
        }
      }
      //await _firebaseAuth.signInWithCredential(oauthCredential);

      //return signInWithCredential(context, oauthCredential);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  void facebookLoginProcess(
    BuildContext context,
    Map<String, dynamic> user,
  ) {
    final apiService = APIService();
/*
    apiService.socialSignupRequest(model).then(
      (value) {
        if (value != null) {
          //SharedService.setLoginDetails(value);
          model.id = value.data?.id;

          if (model.id != null) {
            apiService.updateCustomer(model);
          }
          FormHelper.showMessage(
            context,
            "AppLocalizations.of(context)!.congrats",
            "AppLocalizations.of(context)!.loginConfirmation",
            "AppLocalizations.of(context)!.okText",
            () {
              // //initDarkMode();
              // setState(() {
              //   isApiCallProcess = true;
              // });
              // Navigator.of(context).pushReplacement(
              //   //pushandremoveuntil
              //   MaterialPageRoute(
              //     builder: (context) => const HomePage(
              //         //rateMyApp: widget.rateMyApp,
              //         ),
              //   ), //ModalRoute.withName("/Home"),
              // );
            },
          );
          // //initDarkMode();
          // setState(() {
          //   isApiCallProcess = true;
          // });
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => const HomePage(
          //         //rateMyApp: widget.rateMyApp,
          //         ),
          //   ),
          // );
        } else {
          FormHelper.showMessage(
            context,
            "AppLocalizations.of(context)!.sorryText",
            "AppLocalizations.of(context)!.loginError",
            "AppLocalizations.of(context)!.okText",
            () {
              // setState(() {
              //   isApiCallProcess = true;
              // });
              Navigator.of(context).pop();
            },
          );
        }
      },
    );*/
  }

  void invalidEmailMsg(BuildContext context) {
    Utils.showMessage(
      context,
      "ppLocalizations.of(context)!.invalidEmail",
      "ppLocalizations.of(context)!.shareValidEmail",
      "AppLocalizations.of(context)!.okText",
      () {
        Navigator.pop(context);
      },
    );
  }

  void differentCredentialsMsg(BuildContext context, FirebaseAuthException e) {
    Utils.showMessage(
      context,
      "AppLocalizations.of(context)!.oops",
      "AppLocalizations.of(context)!.sameAccount",
      "AppLocalizations.of(context)!.okText",
      () async {
        final String? email = e.email;
        final AuthCredential? pendingCredential = e.credential;

        // Fetch a list of what sign-in methods exist for the conflicting user
        final List<String> userSignInMethods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email ?? '');

        // If the user has several sign-in methods,
        // the first method in the list will be the "recommended" method to use.
        // Since other providers are now external, you must now sign the user in with another
        // auth provider, such as Facebook.
        if (userSignInMethods.first == 'facebook.com') {
          await signInWithFacebook(
            context,
            pendingCredential: pendingCredential,
          ).then((value) {
            if (value != null) {
              facebookLoginProcess(context, value);
            }
          });
        }
        if (userSignInMethods.first == 'google.com') {
          final UserCredential? userCredential =
              await signInWithGoogle(context);

          await userCredential?.user?.linkWithCredential(pendingCredential!);

          return userCredential;
        }
        if (userSignInMethods.first == 'twitter.com') {
          final UserCredential? userCredential =
              await signInWithTwitter(context);

          await userCredential?.user?.linkWithCredential(pendingCredential!);

          return userCredential;
        }
        if (userSignInMethods.first == 'apple.com') {
          await signInWithApple(context, pendingCredential: pendingCredential)
              .then((value) {
            if (value != null) {
              appleLoginProcess(context, value);
            }
          });

          // await userCredential?.user?.linkWithCredential(pendingCredential!);

          // return userCredential;
        }
        Navigator.pop(context);
      },
      buttonText2: "AppLocalizations.of(context)!.cancel",
      onPressed2: () {
        Navigator.pop(context);
      },
    );
  }

  void appleLoginProcess(BuildContext context, User user) {
/*
    final apiService = APIService();

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
            "AppLocalizations.of(context)!.congrats",
            "AppLocalizations.of(context)!.loginConfirmation",
            "AppLocalizations.of(context)!.okText",
            () {
              //initDarkMode();
              // setState(() {
              //   isApiCallProcess = true;
              // });
              // Navigator.of(context).pushReplacement(
              //   //pushandremoveuntil
              //   MaterialPageRoute(
              //     builder: (context) => const HomePage(
              //         //rateMyApp: widget.rateMyApp,
              //         ),
              //   ), //ModalRoute.withName("/Home"),
              // );
            },
          );
          //initDarkMode();
          // setState(() {
          //   isApiCallProcess = true;
          // });
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => const HomePage(
          //         //rateMyApp: widget.rateMyApp,
          //         ),
          //   ),
          // );
        } else {
          FormHelper.showMessage(
            context,
            "AppLocalizations.of(context)!.sorryText",
            "AppLocalizations.of(context)!.loginError",
            "AppLocalizations.of(context)!.okText",
            () {
              // setState(() {
              //   isApiCallProcess = true;
              // });
              Navigator.of(context).pop();
            },
          );
        }
      },
    );*/
  }
}

class AppleSignInAvailable {
  // ignore: avoid_positional_boolean_parameters
  AppleSignInAvailable(this.isAvailable);
  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    return AppleSignInAvailable(await TheAppleSignIn.isAvailable());
  }
}

class FacebookPicture {
  FacebookPictureData? data;
  FacebookPicture(this.data);
  FacebookPicture.fromJson(Map<String, dynamic> json) {
    data = FacebookPictureData.fromJson(json);
  }
}

class FacebookPictureData {
  String? url;
  FacebookPictureData(this.url);

  FacebookPictureData.fromJson(Map<String, dynamic> json) {
    url = json['url'] as String;
  }
}
