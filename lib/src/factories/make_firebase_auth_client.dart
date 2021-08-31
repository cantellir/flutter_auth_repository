import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_client/src/factories/make_facebook_login.dart';
import 'package:firebase_auth_client/src/factories/make_google_login.dart';
import 'package:firebase_auth_client/src/firebase_auth_client.dart';
import 'package:firebase_auth_client/src/firebase_auth_client_impl.dart';

FirebaseAuthClient makeFirebaseAuthClient() => FirebaseAuthClientImpl(
      auth: FirebaseAuth.instance,
      facebookLoginService: makeFacebookLogin(),
      googleLoginService: makeGoogleLogin(),
    );
