import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:malbit_frontend/core/services/storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialLoginService {
  static final SocialLoginService _instance = SocialLoginService._internal();
  factory SocialLoginService() => _instance;
  SocialLoginService._internal();

  final _storage = AppStorage.storage;

  // ✅ API 통일
  static const String baseUrl = 'http://10.0.2.2:8080/api/users';

  // ✅ 구글 로그인 설정
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// ==============================
  /// ✅ 카카오 로그인
  /// ==============================
  Future<Map<String, dynamic>> loginWithKakao() async {
    try {
      print('🔵 [Kakao Login] 시작');

      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          print('⚠️ 카카오톡 실패 → 웹 로그인');
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final kakaoAccessToken = token.accessToken;

      print('✅ 토큰 획득: ${kakaoAccessToken.length > 20 ? kakaoAccessToken.substring(0, 20) : kakaoAccessToken}');

      // ✅ 단일 API 사용
      final response = await http.post(
        Uri.parse('$baseUrl/social'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'kakao',
          'accessToken': kakaoAccessToken,
        }),
      );

      return await _handleResponse(response, 'Kakao');

    } catch (e) {
      print('🚨 카카오 로그인 실패: $e');
      return {
        'success': false,
        'message': '카카오 로그인 실패',
      };
    }
  }

  /// ==============================
  /// ✅ 구글 로그인
  /// ==============================
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print('🔵 [Google Login] 시작');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': '구글 로그인이 취소되었습니다.',
        };
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final googleIdToken = googleAuth.idToken;

      if (googleIdToken == null) {
        return {
          'success': false,
          'message': '구글 토큰을 가져올 수 없습니다.',
        };
      }

      print('✅ 토큰 획득: ${googleIdToken.length > 20 ? googleIdToken.substring(0, 20) : googleIdToken}');

      // ✅ 단일 API 사용
      final response = await http.post(
        Uri.parse('$baseUrl/social'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'idToken': googleIdToken,
        }),
      );

      return await _handleResponse(response, 'Google');

    } catch (e) {
      print('🚨 구글 로그인 실패: $e');
      return {
        'success': false,
        'message': '구글 로그인 실패',
      };
    }
  }

  /// ==============================
  /// ✅ 공통 응답 처리
  /// ==============================
  Future<Map<String, dynamic>> _handleResponse(
      http.Response response, String provider) async {
    try {
      print('🔵 [$provider] 응답 처리');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        print('✅ [$provider] 성공: $responseBody');

        final data = jsonDecode(responseBody);

        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final isNewUser = data['isNewUser'] ?? false;

        if (accessToken != null && refreshToken != null) {
          await _storage.write(key: 'tokenType', value: 'Bearer');
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'refreshToken', value: refreshToken);

          return {
            'success': true,
            'message': isNewUser
                ? '회원가입 완료 🎉'
                : '로그인 성공!',
            'isNewUser': isNewUser,
          };
        } else {
          return {
            'success': false,
            'message': '토큰이 없습니다.',
          };
        }
      }

      // ❌ 에러 처리
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'success': false,
        'message': errorBody['message'] ?? '로그인 실패',
      };

    } catch (e) {
      print('🚨 [$provider] 응답 처리 오류: $e');
      return {
        'success': false,
        'message': '서버 응답 오류',
      };
    }
  }

  /// ==============================
  /// ✅ 로그아웃
  /// ==============================
  Future<void> logout() async {
    await _storage.delete(key: 'tokenType');
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');

    try {
      await UserApi.instance.logout();
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    print('✅ 로그아웃 완료');
  }
}