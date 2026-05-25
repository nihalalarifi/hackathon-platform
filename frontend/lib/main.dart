// ======================================
// HACKATHON PLATFORM - SIMPLIFIED VERSION
// بدون صفحات التسجيل الإضافية
// ======================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const HackathonApp());
}

// ======================================
// MAIN APP
// ======================================

class HackathonApp extends StatelessWidget {
  const HackathonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TECH HACKATHON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D9FF),
          primary: const Color(0xFF00D9FF),
          secondary: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const LoginScreen(),
    );
  }
}

// ======================================
// THEME & COLORS
// ======================================

class AppColors {
  static const Color darkBg = Color(0xFF0F1419);
  static const Color cardBg = Color(0xFF1A1F2E);
  static const Color cyberBlue = Color(0xFF00D9FF);
  static const Color cyberPurple = Color(0xFF6C63FF);
  static const Color accentPink = Color(0xFFFF006E);
  static const Color accentOrange = Color(0xFFFFB800);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFFE0E0E0);
  static const Color gridColor = Color(0xFF00D9FF);
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D3748);
}

class AppTheme {
  static InputDecoration customInputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.darkText),
      prefixIcon: Icon(icon, color: AppColors.cyberBlue),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.cyberBlue.withOpacity(0.3), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyberPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentPink, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ======================================
// MODELS
// ======================================

class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final Participant? participant;
  final Mentor? mentor;
  final Judge? judge;
  final Organizer? organizer;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    this.participant,
    this.mentor,
    this.judge,
    this.organizer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      participant: json['participant'] != null ? Participant.fromJson(json['participant']) : null,
      mentor: json['mentor'] != null ? Mentor.fromJson(json['mentor']) : null,
      judge: json['judge'] != null ? Judge.fromJson(json['judge']) : null,
      organizer: json['organizer'] != null ? Organizer.fromJson(json['organizer']) : null,
    );
  }

  bool get hasRole => participant != null || mentor != null || judge != null || organizer != null;
}

class Participant {
  final int id;
  final String? skills;
  final String? interests;
  final int? teamId;

  Participant({required this.id, this.skills, this.interests, this.teamId});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      skills: json['skills'],
      interests: json['interests'],
      teamId: json['team_id'],
    );
  }
}

class Mentor {
  final int id;
  final String? expertise;
  final String? bio;
  final String? availability;

  Mentor({required this.id, this.expertise, this.bio, this.availability});

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      expertise: json['expertise'],
      bio: json['bio'],
      availability: json['availability'],
    );
  }
}

class Judge {
  final int id;
  final String? expertise;
  final String? organization;

  Judge({required this.id, this.expertise, this.organization});

  factory Judge.fromJson(Map<String, dynamic> json) {
    return Judge(
      id: json['id'],
      expertise: json['expertise'],
      organization: json['organization'],
    );
  }
}

class Organizer {
  final int id;
  final String? role;
  final String? department;

  Organizer({required this.id, this.role, this.department});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'],
      role: json['role'],
      department: json['department'],
    );
  }
}

class Team {
  final int id;
  final String name;
  final String? description;
  final String? track;
  final int? maxMembers;
  final List<TeamMember> members;
  final bool isWinner;
  final int? winnerPlace;

  Team({
    required this.id,
    required this.name,
    this.description,
    this.track,
    this.maxMembers,
    required this.members,
    this.isWinner = false,
    this.winnerPlace,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      track: json['track'],
      maxMembers: json['max_members'],
      members: (json['members'] as List?)?.map((m) => TeamMember.fromJson(m)).toList() ?? [],
      isWinner: json['is_winner'] ?? false,
      winnerPlace: json['winner_place'],
    );
  }
}

class TeamMember {
  final String username;
  final String fullName;

  TeamMember({required this.username, required this.fullName});

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      username: json['username'],
      fullName: json['full_name'],
    );
  }
}

class HackathonSchedule {
  final String eventName;
  final String description;
  final String startTime;
  final String endTime;

  HackathonSchedule({
    required this.eventName,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  factory HackathonSchedule.fromJson(Map<String, dynamic> json) {
    return HackathonSchedule(
      eventName: json['event_name'],
      description: json['description'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class MentorSession {
  final int id;
  final String teamName;
  final String scheduledTime;
  final String? notes;
  final String? status;

  MentorSession({
    required this.id,
    required this.teamName,
    required this.scheduledTime,
    this.notes,
    this.status,
  });

  factory MentorSession.fromJson(Map<String, dynamic> json) {
    return MentorSession(
      id: json['id'],
      teamName: json['team_name'] ?? '',
      scheduledTime: json['scheduled_time'],
      notes: json['notes'],
      status: json['status'],
    );
  }
}

// ======================================
// API SERVICE
// ======================================

class ApiService {
  static const String baseUrl = 'http://YOUR_BACKEND_HOST:5000/api';
  static String? _token;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved: $token'); // للتتبع
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<String?> _getToken() async {
    if (_token != null) {
      print('Using cached token: $_token'); // للتتبع
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    print('Token from storage: $_token'); // للتتبع
    return _token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
    }
  }

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
    }
  }

  Future<User> getProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> registerRole(String role, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    
    print('Registering as $role with headers: $headers'); // للتتبع
    
    final response = await http.post(
      Uri.parse('$baseUrl/register/$role'),
      headers: headers,
      body: jsonEncode(data),
    );

    print('Response status: ${response.statusCode}'); // للتتبع
    print('Response body: ${response.body}'); // للتتبع

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Role registration failed');
    }
  }

  Future<List<Team>> getTeams() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/teams'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load teams');
    }
  }

  Future<void> createTeam(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to create team');
    }
  }

  Future<List<HackathonSchedule>> getSchedule() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/schedule'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HackathonSchedule.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<MentorSession>> getMentorSessions() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/mentor/sessions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> sessions = data['sessions'];
      return sessions.map((json) => MentorSession.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<MentorSession>> getAllSessionsPublic() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/sessions/all'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> sessions = data['sessions'];
      return sessions.map((json) => MentorSession.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> scheduleSession(int teamId, String time) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/mentor/sessions'),
      headers: headers,
      body: jsonEncode({'team_id': teamId, 'scheduled_time': time}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to schedule session');
    }
  }

  Future<void> updateMentorSession(int sessionId, String newTime) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/mentor/sessions/$sessionId'),
      headers: headers,
      body: jsonEncode({'scheduled_time': newTime}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update session');
    }
  }

  Future<void> deleteMentorSession(int sessionId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/mentor/sessions/$sessionId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to delete session');
    }
  }

  Future<List<MentorSession>> getAllSessionsForOrganizer() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/organizer/sessions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> sessions = data['sessions'];
      return sessions.map((json) => MentorSession.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> updateSessionAsOrganizer(int sessionId, String newTime) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/organizer/sessions/$sessionId'),
      headers: headers,
      body: jsonEncode({'scheduled_time': newTime}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update session');
    }
  }

  Future<void> deleteSessionAsOrganizer(int sessionId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/organizer/sessions/$sessionId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to delete session');
    }
  }

  Future<void> selectWinner(int teamId, int place) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/judge/select-winner'),
      headers: headers,
      body: jsonEncode({'team_id': teamId, 'place': place}),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to select winner');
    }
  }

  Future<void> removeWinner(int place) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/judge/remove-winner'),
      headers: headers,
      body: jsonEncode({'place': place}),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to remove winner');
    }
  }

  Future<void> joinTeam(int teamId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/teams/$teamId/join'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to join team');
    }
  }

  Future<void> leaveTeam(int teamId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/teams/$teamId/leave'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to leave team');
    }
  }
}

// ======================================
// LOGIN SCREEN
// ======================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isRegisterMode = false;

  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (mounted) {
        // تحميل بيانات المستخدم للتحقق من الدور
        final user = await _apiService.getProfile();
        
        // إذا كان لديه دور، انتقل للصفحة الرئيسية
        if (user.hasRole) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // إذا لم يكن لديه دور، انتقل لاختيار الفئة
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
      };

      await _apiService.register(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التسجيل بنجاح! سجل الدخول الآن'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() => _isRegisterMode = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title
                    Column(
                      children: [
                        const Text(
                          'TECH',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cyberBlue,
                            letterSpacing: 2,
                          ),
                        ),
                        const Text(
                          'HACKATHON',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.cyberBlue, AppColors.cyberPurple],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Register mode fields
                    if (_isRegisterMode) ...[
                      TextFormField(
                        controller: _fullNameController,
                        style: const TextStyle(color: AppColors.darkText),
                        decoration: AppTheme.customInputDecoration(
                          labelText: 'الاسم الكامل',
                          icon: Icons.person,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم الكامل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.darkText),
                        decoration: AppTheme.customInputDecoration(
                          labelText: 'البريد الإلكتروني',
                          icon: Icons.email,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          if (!value.contains('@')) {
                            return 'البريد الإلكتروني غير صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: AppColors.darkText),
                        decoration: AppTheme.customInputDecoration(
                          labelText: 'رقم الهاتف',
                          icon: Icons.phone,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: AppColors.darkText),
                      decoration: AppTheme.customInputDecoration(
                        labelText: 'اسم المستخدم',
                        icon: Icons.account_circle,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم المستخدم';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: AppColors.darkText),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        labelStyle: const TextStyle(color: AppColors.darkText),
                        prefixIcon: const Icon(Icons.lock, color: AppColors.cyberBlue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.cyberBlue,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.cyberBlue.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cyberPurple,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.accentPink,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        if (_isRegisterMode && value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Login/Register button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cyberBlue, AppColors.cyberPurple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyberBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isRegisterMode ? _register : _login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRegisterMode ? 'تسجيل' : 'تسجيل الدخول',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Toggle between login and register
                    TextButton(
                      onPressed: () {
                        setState(() => _isRegisterMode = !_isRegisterMode);
                      },
                      child: Text(
                        _isRegisterMode 
                            ? 'لديك حساب بالفعل؟ تسجيل الدخول' 
                            : 'ليس لديك حساب؟ اشترك الآن',
                        style: const TextStyle(
                          color: AppColors.cyberBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

// ======================================
// ROLE SELECTION SCREEN
// ======================================

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          title: const Text(
            'اختر الفئة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.cyberPurple,
          foregroundColor: AppColors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // عنوان جميل قريب من الكروت
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40, height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, AppColors.cyberPurple]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cyberPurple, AppColors.cyberBlue],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyberPurple.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_pin, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'اختر دورك في الهاكاثون',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40, height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.cyberBlue, Colors.transparent]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RoleCard(
                          title: 'مشارك',
                          subtitle: 'Participant',
                          icon: Icons.groups,
                          gradientColors: const [Color(0xFF00D9FF), Color(0xFF0099CC)],
                          onTap: () => _registerAsRole(context, 'participant'),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        _RoleCard(
                          title: 'مرشد',
                          subtitle: 'Mentor',
                          icon: Icons.lightbulb_outline,
                          gradientColors: const [Color(0xFF6C63FF), Color(0xFF4A3FB5)],
                          onTap: () => _registerAsRole(context, 'mentor'),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        _RoleCard(
                          title: 'محكم',
                          subtitle: 'Judge',
                          icon: Icons.gavel,
                          gradientColors: const [Color(0xFFFF006E), Color(0xFFCC0055)],
                          onTap: () => _registerAsRole(context, 'judge'),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        _RoleCard(
                          title: 'منظم',
                          subtitle: 'Organizer',
                          icon: Icons.manage_accounts,
                          gradientColors: const [Color(0xFFFFB800), Color(0xFFCC9400)],
                          onTap: () => _registerAsRole(context, 'organizer'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerAsRole(BuildContext context, String role) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final apiService = ApiService();
    
    try {
      // تسجيل المستخدم في الدور مباشرة
      await apiService.registerRole(role, {});

      if (context.mounted) {
        // إغلاق مؤشر التحميل
        Navigator.of(context).pop();
        
        // عرض رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التسجيل بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // الانتظار قليلاً ثم الانتقال للصفحة الرئيسية
        await Future.delayed(const Duration(seconds: 2));
        
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // إغلاق مؤشر التحميل
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.accentPink,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        height: 160,
        child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gradientColors[0].withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: gradientColors[0],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// ======================================
// HOME SCREEN
// ======================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  
  User? _user;
  List<Team> _teams = [];
  List<HackathonSchedule> _schedule = [];
  List<MentorSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _apiService.getProfile();
      final teams = await _apiService.getTeams();
      final schedule = await _apiService.getSchedule();
      List<MentorSession> sessions = [];
      
      // تحميل الجلسات حسب الدور
      try {
        if (user.mentor != null) {
          sessions = await _apiService.getMentorSessions();
        } else if (user.organizer != null) {
          sessions = await _apiService.getAllSessionsForOrganizer();
        } else {
          // المشاركون والمحكمون يرون جميع الجلسات (للقراءة فقط)
          sessions = await _apiService.getAllSessionsPublic();
        }
      } catch (e) {
        // تجاهل الخطأ
      }
      
      setState(() {
        _user = user;
        _teams = teams;
        _schedule = schedule;
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _apiService.clearToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showCreateTeamDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedTrack = 'التقنية في مجال الصحة';
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إنشاء فريق جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الفريق'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTrack,
                decoration: const InputDecoration(labelText: 'المسار'),
                items: const [
                  DropdownMenuItem(value: 'التقنية في مجال الصحة', child: Text('التقنية في مجال الصحة')),
                  DropdownMenuItem(value: 'التقنية في التعليم', child: Text('التقنية في التعليم')),
                  DropdownMenuItem(value: 'التقنية المالية', child: Text('التقنية المالية')),
                  DropdownMenuItem(value: 'الذكاء الاصطناعي', child: Text('الذكاء الاصطناعي')),
                ],
                onChanged: (val) => selectedTrack = val!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiService.createTeam({
                    'name': nameController.text,
                    'description': descController.text,
                    'track': selectedTrack,
                    'max_members': 5,
                  });
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إنشاء الفريق بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleSession(Team team) {
    final timeController = TextEditingController();
    String selectedDay = '15';
    String selectedTime = '09:00';
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('جدولة جلسة مع ${team.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الجلسات الإرشادية: 15-16 مايو 2026',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyberPurple,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'اليوم',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '15', child: Text('15 مايو (الخميس)')),
                  DropdownMenuItem(value: '16', child: Text('16 مايو (الجمعة)')),
                ],
                onChanged: (val) => selectedDay = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTime,
                decoration: const InputDecoration(
                  labelText: 'الوقت',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '09:00', child: Text('09:00 صباحاً')),
                  DropdownMenuItem(value: '10:00', child: Text('10:00 صباحاً')),
                  DropdownMenuItem(value: '11:00', child: Text('11:00 صباحاً')),
                  DropdownMenuItem(value: '12:00', child: Text('12:00 ظهراً')),
                  DropdownMenuItem(value: '13:00', child: Text('01:00 مساءً')),
                  DropdownMenuItem(value: '14:00', child: Text('02:00 مساءً')),
                  DropdownMenuItem(value: '15:00', child: Text('03:00 مساءً')),
                  DropdownMenuItem(value: '16:00', child: Text('04:00 مساءً')),
                  DropdownMenuItem(value: '17:00', child: Text('05:00 مساءً')),
                ],
                onChanged: (val) => selectedTime = val!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final scheduledTime = '2026-05-$selectedDay $selectedTime';
                try {
                  await _apiService.scheduleSession(team.id, scheduledTime);
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم جدولة الجلسة مع ${team.name} في $selectedDay مايو الساعة $selectedTime'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyberPurple,
              ),
              child: const Text('جدولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWinnerSelectionDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFFFB800)),
              const SizedBox(width: 8),
              const Expanded(child: Text('اختيار مركز الفوز', style: TextStyle(fontSize: 17))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الفريق: ${team.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Text('اختر المركز الذي سيحصل عليه هذا الفريق:', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  // مركز أول
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _assignWinner(team, 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFB800)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFFFFB800).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Column(
                          children: [
                            Text('🥇', style: TextStyle(fontSize: 32)),
                            SizedBox(height: 6),
                            Text('المركز الأول', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // مركز ثاني
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _assignWinner(team, 2);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF78909C).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Column(
                          children: [
                            Text('🥈', style: TextStyle(fontSize: 32)),
                            SizedBox(height: 6),
                            Text('المركز الثاني', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ],
        ),
      ),
    );
  }

  Future<void> _assignWinner(Team team, int place) async {
    try {
      await _apiService.selectWinner(team.id, place);
      _loadData();
      final placeLabel = place == 1 ? 'الأول 🥇' : 'الثاني 🥈';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعيين ${team.name} فائزاً في المركز $placeLabel'),
          backgroundColor: place == 1 ? const Color(0xFFFFB800) : Colors.blueGrey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.accentPink),
      );
    }
  }

  Future<void> _removeWinner(int place) async {
    final placeLabel = place == 1 ? 'الأول' : 'الثاني';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الإلغاء'),
          content: Text('هل تريد إلغاء الفائز في المركز $placeLabel؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('إلغاء الفوز'),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.removeWinner(place);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الفائز'), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.accentPink),
        );
      }
    }
  }

  void _editSession(MentorSession session) {
    final bool isOrganizer = _user?.organizer != null;
    String selectedDay = '15';
    String selectedTime = '09:00';

    // استخراج اليوم والوقت من الجلسة الحالية
    try {
      final parts = session.scheduledTime.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('-');
        if (dateParts.length >= 3) {
          selectedDay = dateParts[2];
          if (selectedDay != '15' && selectedDay != '16') selectedDay = '15';
        }
        selectedTime = parts[1].substring(0, 5);
        final validTimes = ['09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00'];
        if (!validTimes.contains(selectedTime)) selectedTime = '09:00';
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit_calendar, color: AppColors.cyberPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تعديل جلسة: ${session.teamName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOrganizer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentOrange.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 14, color: AppColors.accentOrange),
                        const SizedBox(width: 6),
                        const Text('تعديل بصلاحية المنظم', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                const Text(
                  'الجلسات الإرشادية: 15-16 مايو 2026',
                  style: TextStyle(fontSize: 13, color: AppColors.cyberPurple, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'اليوم', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '15', child: Text('15 مايو (الخميس)')),
                    DropdownMenuItem(value: '16', child: Text('16 مايو (الجمعة)')),
                  ],
                  onChanged: (val) => setStateDialog(() => selectedDay = val!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedTime,
                  decoration: const InputDecoration(labelText: 'الوقت', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '09:00', child: Text('09:00 صباحاً')),
                    DropdownMenuItem(value: '10:00', child: Text('10:00 صباحاً')),
                    DropdownMenuItem(value: '11:00', child: Text('11:00 صباحاً')),
                    DropdownMenuItem(value: '12:00', child: Text('12:00 ظهراً')),
                    DropdownMenuItem(value: '13:00', child: Text('01:00 مساءً')),
                    DropdownMenuItem(value: '14:00', child: Text('02:00 مساءً')),
                    DropdownMenuItem(value: '15:00', child: Text('03:00 مساءً')),
                    DropdownMenuItem(value: '16:00', child: Text('04:00 مساءً')),
                    DropdownMenuItem(value: '17:00', child: Text('05:00 مساءً')),
                  ],
                  onChanged: (val) => setStateDialog(() => selectedTime = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final newTime = '2026-05-$selectedDay $selectedTime';
                  try {
                    if (isOrganizer) {
                      await _apiService.updateSessionAsOrganizer(session.id, newTime);
                    } else {
                      await _apiService.updateMentorSession(session.id, newTime);
                    }
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تعديل الجلسة مع ${session.teamName} بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.accentPink),
                    );
                  }
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('حفظ التعديل'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberPurple, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSession(MentorSession session) async {
    final bool isOrganizer = _user?.organizer != null;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              const Text('تأكيد الحذف'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت متأكد من حذف الجلسة مع فريق "${session.teamName}"؟'),
              const SizedBox(height: 8),
              Text(
                'الوقت: ${session.scheduledTime}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'لا يمكن التراجع عن هذا الإجراء.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('حذف'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        if (isOrganizer) {
          await _apiService.deleteSessionAsOrganizer(session.id);
        } else {
          await _apiService.deleteMentorSession(session.id);
        }
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الجلسة مع ${session.teamName}'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.accentPink),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final bool isMentor = _user?.mentor != null;
    final bool isJudge = _user?.judge != null;
    final bool isOrganizer = _user?.organizer != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          title: const Text('منصة الهاكاثون'),
          backgroundColor: AppColors.cyberPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 60, color: AppColors.cyberPurple),
                      const SizedBox(height: 16),
                      Text(
                        'مرحباً، ${_user?.fullName ?? ''}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildRoleBadges(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // About Hackathon
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.cyberBlue),
                          const SizedBox(width: 8),
                          const Text(
                            'عن الهاكاثون',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'الهاكاثون التقني هو مسابقة إبداعية تجمع المبتكرين والمطورين والمصممين لحل التحديات التقنية في مختلف المجالات.',
                        style: TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Schedule
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: AppColors.cyberPurple),
                          const SizedBox(width: 8),
                          const Text(
                            'الجدول الزمني',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cyberPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'مايو 2026',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.cyberPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_schedule.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('لا توجد فعاليات مجدولة حالياً'),
                          ),
                        )
                      else
                        ..._schedule.asMap().entries.map((entry) {
                          final index = entry.key;
                          final e = entry.value;
                          final isLast = index == _schedule.length - 1;

                          // تنسيق التاريخ بالعربي
                          String formatDate(String date) {
                            final months = {
                              '01': 'يناير', '02': 'فبراير', '03': 'مارس',
                              '04': 'أبريل', '05': 'مايو', '06': 'يونيو',
                              '07': 'يوليو', '08': 'أغسطس', '09': 'سبتمبر',
                              '10': 'أكتوبر', '11': 'نوفمبر', '12': 'ديسمبر',
                            };
                            final parts = date.split('-');
                            if (parts.length == 3) {
                              final day = parts[2].replaceAll(RegExp(r'^0'), '');
                              final month = months[parts[1]] ?? parts[1];
                              return '$day $month';
                            }
                            return date;
                          }

                          String dateLabel;
                          if (e.startTime == e.endTime) {
                            dateLabel = '${formatDate(e.startTime)} ${e.startTime.split("-")[0]}';
                          } else {
                            final startDay = e.startTime.split("-")[2].replaceAll(RegExp(r"^0"), "");
                            final endFormatted = formatDate(e.endTime);
                            final year = e.startTime.split("-")[0];
                            dateLabel = '$startDay-$endFormatted $year';
                          }

                          // ألوان الفقرات
                          final colors = [
                            AppColors.cyberBlue,
                            AppColors.cyberPurple,
                            AppColors.accentOrange,
                            AppColors.cyberBlue,
                            AppColors.cyberPurple,
                            AppColors.accentOrange,
                            AppColors.accentPink,
                          ];
                          final color = colors[index % colors.length];

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Timeline column
                                Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
                                            ),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                // Event content
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: color.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.calendar_today, size: 11, color: color),
                                              const SizedBox(width: 4),
                                              Text(
                                                dateLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          e.eventName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          e.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.darkText.withOpacity(0.65),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Teams Section
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.groups, color: AppColors.cyberBlue),
                              const SizedBox(width: 8),
                              const Text(
                                'الفرق المشاركة',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (isOrganizer || isMentor)
                            ElevatedButton.icon(
                              onPressed: _showCreateTeamDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('إنشاء فريق'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyberBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_teams.isEmpty)
                        const Text('لا توجد فرق مشاركة حالياً')
                      else
                        ..._teams.map((team) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.cyberBlue,
                                      child: Text(
                                        '${team.members.length}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            team.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (team.track != null)
                                            Row(
                                              children: [
                                                Icon(Icons.track_changes, size: 14, color: AppColors.cyberPurple),
                                                const SizedBox(width: 4),
                                                Text(
                                                  team.track!,
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          Text(
                                            'الأعضاء: ${team.members.length}/${team.maxMembers ?? 5}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.darkText.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // زر الانضمام للمشاركين
                                    if (_user?.participant != null && !isOrganizer && !isMentor)
                                      _buildJoinButton(team),
                                    // زر جدولة جلسة للمرشدين
                                    if (isMentor)
                                      IconButton(
                                        icon: const Icon(Icons.schedule, color: AppColors.cyberPurple),
                                        onPressed: () => _scheduleSession(team),
                                        tooltip: 'جدولة جلسة',
                                      ),
                                    // زر اختيار فائز للمحكمين
                                    if (isJudge)
                                      IconButton(
                                        icon: Icon(
                                          team.winnerPlace == 1 ? Icons.emoji_events :
                                          team.winnerPlace == 2 ? Icons.military_tech : Icons.star_border,
                                          color: team.winnerPlace == 1 ? const Color(0xFFFFD700) :
                                                 team.winnerPlace == 2 ? Colors.blueGrey :
                                                 AppColors.accentOrange,
                                          size: 26,
                                        ),
                                        onPressed: () => _showWinnerSelectionDialog(team),
                                        tooltip: team.winnerPlace == 1 ? 'المركز الأول - اضغط للتعديل' :
                                                 team.winnerPlace == 2 ? 'المركز الثاني - اضغط للتعديل' :
                                                 'اختيار كفائز',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // نتائج الفائزين (للمحكم فقط)
              if (isJudge)
                Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Color(0xFFFFB800), size: 24),
                            const SizedBox(width: 8),
                            const Text('نتائج الفائزين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB800).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('صلاحية المحكم', style: TextStyle(fontSize: 11, color: Color(0xFFFFB800), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text('اضغط على ⭐ بجانب أي فريق لتعيينه أو تعديل مركزه',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 16),
                        // المركز الأول
                        Builder(builder: (context) {
                          final firstTeam = _teams.where((t) => t.winnerPlace == 1).toList();
                          final hasFirst = firstTeam.isNotEmpty;
                          return _buildWinnerCard(
                            place: 1,
                            emoji: '🥇',
                            label: 'المركز الأول',
                            gradientColors: const [Color(0xFFFFD700), Color(0xFFFFB800)],
                            team: hasFirst ? firstTeam.first : null,
                            onRemove: hasFirst ? () => _removeWinner(1) : null,
                          );
                        }),
                        const SizedBox(height: 12),
                        // المركز الثاني
                        Builder(builder: (context) {
                          final secondTeam = _teams.where((t) => t.winnerPlace == 2).toList();
                          final hasSecond = secondTeam.isNotEmpty;
                          return _buildWinnerCard(
                            place: 2,
                            emoji: '🥈',
                            label: 'المركز الثاني',
                            gradientColors: const [Color(0xFFB0BEC5), Color(0xFF78909C)],
                            team: hasSecond ? secondTeam.first : null,
                            onRemove: hasSecond ? () => _removeWinner(2) : null,
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // جدول الجلسات الإرشادية - يظهر للجميع
              if (_sessions.isNotEmpty)
                Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule, color: AppColors.cyberPurple),
                            const SizedBox(width: 8),
                            Text(
                              isMentor ? 'جلساتي الإرشادية' :
                              isOrganizer ? 'جميع الجلسات الإرشادية' :
                              'جدول الجلسات الإرشادية',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.cyberPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_sessions.length} جلسة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.cyberPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // تلميح للمشاركين
                        if (!isMentor && !isOrganizer) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 13, color: AppColors.cyberBlue),
                              const SizedBox(width: 4),
                              const Text(
                                'المواعيد التي سيلتقي فيها المرشدون بالفرق',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        ..._sessions.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final session = entry.value;
                          // تمييز جلسة الفريق الخاص بالمشارك
                          final isMyTeamSession = _user?.participant?.teamId != null &&
                              _teams.any((t) => t.id == _user!.participant!.teamId &&
                                  t.name == session.teamName);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMyTeamSession
                                    ? AppColors.cyberBlue.withOpacity(0.6)
                                    : AppColors.cyberPurple.withOpacity(0.18),
                                width: isMyTeamSession ? 2 : 1,
                              ),
                              color: isMyTeamSession
                                  ? AppColors.cyberBlue.withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  // رقم الجلسة
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isMyTeamSession
                                          ? AppColors.cyberBlue
                                          : AppColors.cyberPurple.withOpacity(0.15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${idx + 1}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isMyTeamSession
                                              ? Colors.white
                                              : AppColors.cyberPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                session.teamName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: isMyTeamSession
                                                      ? AppColors.cyberBlue
                                                      : AppColors.darkText,
                                                ),
                                              ),
                                            ),
                                            if (isMyTeamSession)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.cyberBlue.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  'فريقك ⭐',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.cyberBlue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              session.scheduledTime,
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // أزرار التعديل/الحذف للمرشد والمنظم فقط
                                  if (isMentor || isOrganizer) ...[
                                    IconButton(
                                      icon: Icon(Icons.edit, color: AppColors.cyberPurple, size: 20),
                                      tooltip: 'تعديل الجلسة',
                                      onPressed: () => _editSession(session),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      tooltip: 'حذف الجلسة',
                                      onPressed: () => _deleteSession(session),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerCard({
    required int place,
    required String emoji,
    required String label,
    required List<Color> gradientColors,
    Team? team,
    VoidCallback? onRemove,
  }) {
    final bool hasWinner = team != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasWinner
              ? [gradientColors[0].withOpacity(0.15), gradientColors[1].withOpacity(0.08)]
              : [Colors.grey.withOpacity(0.05), Colors.grey.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasWinner ? gradientColors[0].withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: hasWinner ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // الميدالية
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: hasWinner
                  ? LinearGradient(colors: gradientColors)
                  : null,
              color: hasWinner ? null : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: hasWinner ? [BoxShadow(color: gradientColors[0].withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))] : [],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          // معلومات الفريق
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasWinner ? gradientColors[1] : Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasWinner ? team!.name : 'لم يُختر بعد',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: hasWinner ? AppColors.darkText : Colors.grey,
                  ),
                ),
                if (hasWinner && team!.track != null)
                  Text(
                    team.track!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          // أزرار التعديل/الإلغاء
          if (hasWinner)
            Row(
              children: [
                // زر التعديل
                Container(
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: gradientColors[1], size: 18),
                    tooltip: 'تغيير الفائز',
                    onPressed: () {
                      // فتح قائمة الفرق لاختيار بديل
                      _showReplaceWinnerDialog(place, gradientColors);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                // زر الحذف
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    tooltip: 'إلغاء الفوز',
                    onPressed: onRemove,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showReplaceWinnerDialog(int place, List<Color> gradientColors) {
    final placeLabel = place == 1 ? 'الأول 🥇' : 'الثاني 🥈';
    final availableTeams = _teams.where((t) => t.winnerPlace != place).toList();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تغيير فائز المركز $placeLabel'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableTeams.isEmpty
                ? const Text('لا توجد فرق أخرى متاحة')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableTeams.length,
                    itemBuilder: (context, index) {
                      final team = availableTeams[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: gradientColors[0].withOpacity(0.15),
                            child: Icon(Icons.groups, color: gradientColors[0], size: 20),
                          ),
                          title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: team.track != null ? Text(team.track!) : null,
                          trailing: team.winnerPlace != null
                              ? Text(team.winnerPlace == 1 ? '🥇' : '🥈', style: const TextStyle(fontSize: 18))
                              : null,
                          onTap: () async {
                            Navigator.pop(context);
                            await _assignWinner(team, place);
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(Team team) {
    final isInThisTeam = _user?.participant?.teamId == team.id;
    final isInAnyTeam = _user?.participant?.teamId != null;
    final isTeamFull = team.members.length >= (team.maxMembers ?? 5);

    if (isInThisTeam) {
      // المستخدم في هذا الفريق - زر المغادرة
      return ElevatedButton.icon(
        onPressed: () => _leaveTeam(team),
        icon: const Icon(Icons.exit_to_app, size: 16),
        label: const Text('مغادرة'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else if (isInAnyTeam) {
      // المستخدم في فريق آخر - زر معطل
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.block, size: 16),
        label: const Text('في فريق آخر'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else if (isTeamFull) {
      // الفريق ممتلئ
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.people, size: 16),
        label: const Text('مكتمل'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else {
      // يمكن الانضمام
      return ElevatedButton.icon(
        onPressed: () => _joinTeam(team),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('انضم'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }
  }

  Future<void> _joinTeam(Team team) async {
    try {
      await _apiService.joinTeam(team.id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الانضمام لفريق ${team.name} بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: AppColors.accentPink,
        ),
      );
    }
  }

  Future<void> _leaveTeam(Team team) async {
    // تأكيد المغادرة
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد المغادرة'),
          content: Text('هل أنت متأكد من مغادرة فريق ${team.name}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
              ),
              child: const Text('مغادرة'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.leaveTeam(team.id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم مغادرة فريق ${team.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    }
  }

  Widget _buildRoleBadges() {
    List<Widget> badges = [];
    
    if (_user?.participant != null) {
      badges.add(_buildBadge('مشارك', AppColors.cyberBlue));
    }
    if (_user?.mentor != null) {
      badges.add(_buildBadge('مرشد', AppColors.cyberPurple));
    }
    if (_user?.judge != null) {
      badges.add(_buildBadge('محكم', AppColors.accentPink));
    }
    if (_user?.organizer != null) {
      badges.add(_buildBadge('منظم', AppColors.accentOrange));
    }
    
    return Wrap(
      spacing: 8,
      children: badges,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}