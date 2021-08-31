import 'package:auth_repository/auth_exception.dart';
import 'package:auth_repository/firebase_auth_client.dart';
import 'package:auth_repository/firebase_auth_client_impl.dart';
import 'package:auth_repository/client_login_services/facebook/facebook_login_service.dart';
import 'package:auth_repository/client_login_services/google/google_login_service.dart';
import 'package:auth_repository/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class FacebookLoginServiceMock extends Mock implements FacebookLoginService {}

class GoogleLoginServiceMock extends Mock implements GoogleLoginService {}

class UserCredentialMock extends Mock implements UserCredential {}

void main() {
  late FirebaseAuthClient sut;
  late FirebaseAuthMock auth;
  late FacebookLoginServiceMock facebookLoginService;
  late GoogleLoginServiceMock googleLoginService;

  setUp(() {
    auth = FirebaseAuthMock();
    facebookLoginService = FacebookLoginServiceMock();
    googleLoginService = GoogleLoginServiceMock();

    sut = FirebaseAuthClientImpl(
        auth: auth,
        facebookLoginService: facebookLoginService,
        googleLoginService: googleLoginService);
  });

  setUpAll(() {
    registerFallbackValue(
        AuthCredential(providerId: 'providerId', signInMethod: 'signInMethod'));
  });

  group('login with email and password', () {
    test('should pass with correct email and password if no error occurs',
        () async {
      when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => UserCredentialMock());
      await sut.loginWithEmailAndPassword(
        email: 'fake@mail.com',
        password: '123456',
      );

      verify(() => auth.signInWithEmailAndPassword(
          email: 'fake@mail.com', password: '123456')).called(1);

      verifyNoMoreInteractions(auth);
    });

    test(
        'should trhow AuthEmailException with correct message if e-mail '
        'is empty', () {
      expect(
          () => sut.loginWithEmailAndPassword(
                email: '',
                password: '123456',
              ),
          throwsA(isA<AuthEmailException>()
              .having((e) => e.error, 'message', Strings.emptyEmail)));

      verifyZeroInteractions(auth);
    });

    test(
        'should trhow AuthPasswordException with correct message if e-mail '
        'is empty', () {
      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: '',
              ),
          throwsA(isA<AuthPasswordException>()
              .having((e) => e.error, 'message', Strings.emptyPassword)));

      verifyZeroInteractions(auth);
    });

    test(
        'should throw AuthEmailException with correct message if firebase '
        'throws invalid email', () {
      when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(
              FirebaseAuthException(code: FirebaseExceptionCodes.invalidEmail));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'invalidmail',
                password: 'password',
              ),
          throwsA(isA<AuthEmailException>()
              .having((e) => e.error, 'message', Strings.invalidEmail)));
    });

    test(
        'should throw AuthEmailException with correct message if firebase '
        'throws user not found', () {
      when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(
              FirebaseAuthException(code: FirebaseExceptionCodes.userNotFound));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: 'password',
              ),
          throwsA(isA<AuthEmailException>()
              .having((e) => e.error, 'message', Strings.userNotFound)));
    });

    test(
        'should throw AuthEmailException with correct message if firebase '
        'throws email already in use', () {
      when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(
              code: FirebaseExceptionCodes.emailAlreadyInUse));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: 'password',
              ),
          throwsA(isA<AuthEmailException>()
              .having((e) => e.error, 'message', Strings.emailAlreadyInUse)));
    });

    test(
        'should throw AuthPasswordException with correct message if firebase '
        'throws wrong password', () {
      when(() =>
          auth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'))).thenThrow(
          FirebaseAuthException(code: FirebaseExceptionCodes.wrongPassword));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: 'password',
              ),
          throwsA(isA<AuthPasswordException>()
              .having((e) => e.error, 'message', Strings.invalidPassword)));
    });

    test(
        'should throw AuthPasswordException with correct message if firebase '
        'throws weak password', () {
      when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(
              FirebaseAuthException(code: FirebaseExceptionCodes.weakPassword));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: 'password',
              ),
          throwsA(isA<AuthPasswordException>()
              .having((e) => e.error, 'message', Strings.passwordWeak)));
    });
  });

  group('register with email and password', () {
    test('should pass with correct email and password if no error occurs',
        () async {
      when(() => auth.createUserWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => UserCredentialMock());
      await sut.registerWithEmailAndPassword(
        email: 'fake@mail.com',
        password: '123456',
      );

      verify(() => auth.createUserWithEmailAndPassword(
          email: 'fake@mail.com', password: '123456')).called(1);

      verifyNoMoreInteractions(auth);
    });

    test(
        'should trhow AuthEmailException with correct message if e-mail '
        'is empty', () {
      expect(
          () => sut.registerWithEmailAndPassword(
                email: '',
                password: '123456',
              ),
          throwsA(isA<AuthEmailException>()
              .having((e) => e.error, 'message', Strings.emptyEmail)));

      verifyZeroInteractions(auth);
    });

    test(
        'should trhow AuthPasswordException with correct message if e-mail '
        'is empty', () {
      expect(
          () => sut.registerWithEmailAndPassword(
                email: 'fake@mail.com',
                password: '',
              ),
          throwsA(isA<AuthPasswordException>()
              .having((e) => e.error, 'message', Strings.emptyPassword)));

      verifyZeroInteractions(auth);
    });
  });

  group('login with facebook', () {
    test('should pass if no error occurs', () async {
      final FacebookLoginResult loginResult = FacebookLoginResult('token');
      when(() => facebookLoginService.login())
          .thenAnswer((_) async => loginResult);
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => UserCredentialMock());

      await sut.loginWithFacebook();

      verify(() => facebookLoginService.login()).called(1);
      verifyNoMoreInteractions(facebookLoginService);
      verify(() => auth.signInWithCredential(any())).called(1);
      verifyNoMoreInteractions(auth);
    });

    test(
        'should throw AuthException with correct message if throws '
        'account exists with different credential', () {
      when(() => facebookLoginService.login()).thenThrow(FirebaseAuthException(
          code: FirebaseExceptionCodes.accountExistsWithDifferentCredential));

      expect(
          () => sut.loginWithFacebook(),
          throwsA(isA<AuthException>().having((e) => e.error, 'message',
              Strings.accountExistsWithDiferentCredentials)));
    });

    test('should rethrow untracked exception if throws', () {
      when(() => facebookLoginService.login()).thenThrow(Exception());

      expect(() => sut.loginWithFacebook(), throwsA(isA<Exception>()));
    });
  });

  group('login with google', () {
    test('should pass if no error occurs', () async {
      final GoogleLoginResult loginResult =
          GoogleLoginResult(token: 'token', tokenId: 'tokenId');
      when(() => googleLoginService.login())
          .thenAnswer((_) async => loginResult);
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => UserCredentialMock());

      await sut.loginWithGoogle();

      verify(() => googleLoginService.login()).called(1);
      verifyNoMoreInteractions(googleLoginService);
      verify(() => auth.signInWithCredential(any())).called(1);
      verifyNoMoreInteractions(auth);
    });

    test('should retrhow untracked exception if throws', () {
      when(() => googleLoginService.login()).thenThrow(Exception());

      expect(() => sut.loginWithGoogle(), throwsA(isA<Exception>()));
    });
  });

  group('recover password tests', () {
    test(
        'should trhow AuthEmailException with correct message if e-mail '
        'is empty', () {
      expect(
          () => sut.recoverPassword(''),
          throwsA(isA<AuthEmailException>()
              .having((e) => e.error, 'message', Strings.emptyEmail)));

      verifyZeroInteractions(auth);
    });

    test('should pass with correct email if no error occurs', () async {
      when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async => null);

      await auth.sendPasswordResetEmail(email: 'fake@mail.com');

      verify(() => auth.sendPasswordResetEmail(email: 'fake@mail.com'))
          .called(1);
      verifyNoMoreInteractions(auth);
    });

    test('should retrhow untracked exception if throws', () {
      when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenThrow(Exception());

      expect(() => sut.recoverPassword('fake@mail.com'),
          throwsA(isA<Exception>()));
    });
  });

  group('connection error tests', () {
    test(
        'should throw AuthNetworkException with correct message if firebase '
        'throws too many requests', () {
      when(() =>
          auth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'))).thenThrow(
          FirebaseAuthException(code: FirebaseExceptionCodes.tooManyRequests));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: 'password',
              ),
          throwsA(isA<AuthNetworkException>()
              .having((e) => e.error, 'message', Strings.tooManyRequest)));
    });

    test(
        'should throw AuthNetworkException with correct message if firebase '
        'throws network request failed', () {
      when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(
              code: FirebaseExceptionCodes.networkRequestFailed));

      expect(
          () => sut.loginWithEmailAndPassword(
                email: 'fake@mail.com',
                password: 'password',
              ),
          throwsA(isA<AuthNetworkException>()
              .having((e) => e.error, 'message', Strings.checkConnection)));
    });
  });
}