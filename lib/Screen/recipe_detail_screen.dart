import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId; //เก็บ id สูตรอาหาร

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe; //ตัวแปรเก็บสูตรอาหาร
  bool _isLoading = true; //ตัวแปรสำหรับตรวจสอบสถานะการโหลด

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails(); //เรียกฟังก์ชันดึงapi สูตรอาหาร
  }

  Future<void> _fetchRecipeDetails() async {
    final String url =
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=720e17f8ae3c4c4aa1fad0f359eaf6cc';

    try {
      final response = await http.get(Uri.parse(url)); // ส่งคำขอ GET เพื่อดึงข้อมูลสูตรอาหาร
      if (response.statusCode == 200) {
        setState(() {
          recipe = json.decode(response.body); // แปลงข้อมูล JSON เป็น Map และเก็บในตัวแปร recipe
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load recipe details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Error loading recipe details')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe!['title']),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recipe!['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(recipe!['image']),
                      )
                    : Container(),
                const SizedBox(height: 16),
                Text(
                  recipe!['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ready in: ${recipe!['readyInMinutes']} min',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Rating: ${recipe!['spoonacularScore'].toStringAsFixed(2)} / 100',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instructions:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                recipe!['instructions'] != null
                    ? Text(
                        recipe!['instructions'],
                        style: const TextStyle(fontSize: 16),
                      )
                    : const Text('No instructions available'),
                const SizedBox(height: 16),
                const Text(
                  'Ingredients:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe!['extendedIngredients']?.length ?? 0,  // ใช้ extendedIngredients เพื่อแสดงจำนวนส่วนผสม
                  itemBuilder: (context, index) {
                    final ingredient = recipe!['extendedIngredients'][index]; // ดึงข้อมูลส่วนผสมแต่ละรายการ
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(ingredient['name']),// แสดงชื่อส่วนผสม
                        subtitle: Text(
                            'Quantity: ${ingredient['amount']} ${ingredient['unit']}'), // แสดงปริมาณและหน่วยของส่วนผสม
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
