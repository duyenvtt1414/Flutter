import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final Map<String, String> userDatabase = {
  "nguyenvana@gmail.com": "password123",
};

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(),
      child: const MyApp(),
    ),
  );
}

class Course {
  final String id;
  final String title;
  final String instructor;
  final int duration;
  final double price;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.price,
  });
}

class CourseProvider extends ChangeNotifier {
  final List<Course> _courses = [
    Course(id: "C01", title: "Flutter Toàn Tập Cho Người Mới", instructor: "Nguyễn Văn A", duration: 40, price: 250000),
    Course(id: "C02", title: "Lập Trình Backend Với Spring Boot", instructor: "Trần Văn B", duration: 60, price: 450000),
    Course(id: "C03", title: "Cấu Trúc Dữ Liệu Và Giải Thuật", instructor: "Lê Văn C", duration: 32, price: 180000),
    Course(id: "C04", title: "Làm Chủ State Management Trong Flutter", instructor: "Phạm Thị D", duration: 15, price: 150000),
    Course(id: "C05", title: "Thiết Kế Giao Diện Mobile UI/UX chuyên sâu", instructor: "Hoàng Văn E", duration: 24, price: 300000),
  ];

  List<Course> get courses => _courses;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "Email không được để trống";
  }
  if (!value.contains("@") || !value.contains(".")) {
    return "Email không hợp lệ";
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Password không được để trống";
  }
  if (value.length < 8) {
    return "Password phải có ít nhất 8 ký tự";
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return "Password phải có ít nhất 1 số";
  }
  return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (userDatabase[email] == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sai email hoặc mật khẩu!"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "EduHub Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )
                      : const Text("Login"),
                ),
              ),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (userDatabase.containsKey(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email này đã được đăng ký!"),
          duration: Duration(seconds: 7),
        ),
      );
    } else {
      userDatabase[email] = password;
      print(userDatabase);

      emailController.clear();
      passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công!"),
        ),
      );

      Navigator.pop(context);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )
                      : const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final username = email.split("@")[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text("EduHub Catalog"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Text(
              "Welcome, $username!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Consumer<CourseProvider>(
              builder: (context, courseProvider, child) {
                final courses = courseProvider.courses;

                return ListView.builder(
                  itemCount: courses.length-1,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(course.id),
                        ),
                        title: Text(
                          course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Instructor: ${course.instructor}\n"
                              "Duration: ${course.duration} hours\n"
                              "Price: ${course.price.toStringAsFixed(0)} VND",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}