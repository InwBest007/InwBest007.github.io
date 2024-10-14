import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  final String userName; // รับชื่อผู้ใช้เป็นตัวแปร

  AccountScreen({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // เปลี่ยนสี AppBar
        elevation: 0, // ลบเงาของ AppBar
        centerTitle: true, // ทำให้ Title อยู่ตรงกลาง
      ),
      body: Stack(
        children: [
          // พื้นหลังด้านหลังเป็น Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กลาง
              children: [
                // เพิ่มรูปโปรไฟล์จำลอง
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage('https://www.catdumb.com/wp-content/uploads/2024/05/chefian4.png'),
                ),
                const SizedBox(height: 20),
                // ข้อความแสดงชื่อผู้ใช้
                Text(
                  'Goodluck!!!, $userName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // ข้อความเพิ่มเติม
                Text(
                  'ขอให้สนุกกับการอาหารนะคะ!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),

                // ปุ่ม Logout
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.deepPurple, backgroundColor: Colors.white, // สีตัวอักษร
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout), // ไอคอน Logout
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
