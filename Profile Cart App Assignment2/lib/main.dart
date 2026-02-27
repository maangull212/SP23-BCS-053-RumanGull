import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileCardApp());
}

class ProfileCardApp extends StatelessWidget {
  const ProfileCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Card',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ProfileHomePage(),
    );
  }
}

class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Top Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼 Profile Image (change image here)
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: const AssetImage('image.jpg'),
                    ),

                    const SizedBox(width: 15),

                    // 👤 Name + Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ruman\nGull',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Flutter Developer',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: const [
                              Icon(Icons.email, size: 18, color: Colors.blue),
                              SizedBox(width: 6),
                              Text('rumangull@gmail.com'),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Icon(Icons.phone, size: 18, color: Colors.green),
                              SizedBox(width: 6),
                              Text('+92 3046398463'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🔗 Social Icons
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(Icons.facebook, size: 16),
                        ),
                        SizedBox(height: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFFCE4EC),
                          child: Icon(Icons.camera_alt, size: 16),
                        ),
                        SizedBox(height: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(Icons.link, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 🔹 My Services
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.1,
                      children: const [
                        ServiceCard(
                          icon: Icons.code,
                          title: 'Flutter\nDevelopment',
                          color: Colors.blue,
                        ),
                        ServiceCard(
                          icon: Icons.design_services,
                          title: 'UI/UX\nDesign',
                          color: Colors.purple,
                        ),
                        ServiceCard(
                          icon: Icons.phone_android,
                          title: 'Mobile App\nDevelopment',
                          color: Colors.green,
                        ),
                        ServiceCard(
                          icon: Icons.public,
                          title: 'SEO &\nMarketing',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Reusable Service Card Widget
class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}