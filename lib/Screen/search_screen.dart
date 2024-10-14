import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_detail_screen.dart'; // นำเข้าไฟล์แสดงรายละเอียดสูตรเมนู
import 'favorites.dart'; // นำเข้าหน้ารายการโปรด

class SearchScreen extends StatefulWidget {
  final String? query; // เอาไว้เก็บคำค้นหาที่ผู้ใช้ใส่มา

  const SearchScreen({Key? key, this.query}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _recipes = []; //รายการสูตรที่เจอ
  List<Map<String, dynamic>> _favoriteMenus = []; // รายการโปรด
  final String _apiKey = '720e17f8ae3c4c4aa1fad0f359eaf6cc'; //API Key ใน spoonacular 
  bool _isLoading = false; //เอาไว้ตรวจสถานะการโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    // เอาไว้เช็คว่ามีคำค้นหาใน query หรือไม่ และเรียกใช้งานฟังก์ชันการค้นหาสูตร
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searchRecipes(widget.query!);
    }
  }
  //ฟังก์ชันการหาสูตรตามคำค้นหาที่ใส่มา
  void _searchRecipes(String ingredient) async {
    //ตั้งค่าการโหลดและล้างลิสต์
    setState(() {
      _isLoading = true;
      _recipes = []; // เคลียร์ลิสต์ก่อนเริ่มค้นหาใหม่
    });
  //url เอาไว้เรียก api
    final String url =
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredient&number=10&apiKey=$_apiKey';

    try {
      //GET เอาไว้ดึงสูตรอาหาร
      final response = await http.get(Uri.parse(url));

      //ตรวจสอบการตอบกลับของ api
      if (response.statusCode == 200) {
        //ถ้ามีข้อมูลจะแปลงข้อมูล json เก็บไว้ใน decode
        setState(() {
          _recipes = json.decode(response.body);
        });
      } else {
        //ถ้าไม่สำเร็จ แสดงข้อผิดพลาด
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันสำหรับเพิ่มสูตรอาหารลงในรายการโปรด
  void _addToFavorites(Map<String, dynamic> recipe) {
    setState(() {
      _favoriteMenus.add(recipe); //เพิ่มเมนูโปรดได้
    });
    //ขึ้นข้อความบันทึกเมนูโปรดเรียบร้อย
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe['title']} added to favorites!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              // เปิดหน้า favorites และส่งรายการโปรดไปแสดง
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoriteScreen(favoriteMenus: _favoriteMenus),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by ingredient (e.g. pork,meat,carrot)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (value) {
                _searchRecipes(value);
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index]; //ไว้ดึง api สูตรอาหาร
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(recipe['title']), //ชื่อเมนู
                            leading: recipe['image'] != null
                                ? ClipOval(
                                    child: Image.network(recipe['image'],
                                        width: 50, fit: BoxFit.cover),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _addToFavorites(
                                    recipe); // บันทึกเมนูลงรายการโปรด
                              },
                            ),
                            onTap: () {
                              // เปิดหน้ารายละเอียดเมื่อกดเลือกสูตรอาหาร
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                      recipeId: recipe['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
