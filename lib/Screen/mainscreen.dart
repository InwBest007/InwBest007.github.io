import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp_recipe/Screen/account_screen.dart';
import 'package:myapp_recipe/Screen/search_screen.dart';
import 'dart:convert';
import 'recipe_detail_screen.dart';
import 'favorites.dart';

Future<List<Map<String, dynamic>>> fetchRecipes(String category,
    {http.Client? client}) async {
  client ??= http.Client(); //เอาไว้ test 

  String apiKey = '720e17f8ae3c4c4aa1fad0f359eaf6cc'; 
  String url;
  //เอาไว้ดึง api แบบสุ่ม (แสดงเมนู 5 เมนู)
  if (category == 'recently_viewed') {
    url = 'https://api.spoonacular.com/recipes/random?number=5&apiKey=$apiKey';
  } else if (category == 'recommended') {
    url = 'https://api.spoonacular.com/recipes/random?number=5&apiKey=$apiKey';
  } else if (category == 'new_recipes') {
    url = 'https://api.spoonacular.com/recipes/random?number=5&apiKey=$apiKey';
  } else {
    throw Exception('Unknown category');
  }

  final response = await client.get(Uri.parse(url));  //เรียก api ด้วย http get

  //ตรวจสอบการตอบกลับ
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>; //แปลงข้อมูล json แล้วเก็บไว้ใน decode
    final recipes = data['recipes'] as List; 
    //สร้างลิสต์ของสูตรอาหารที่มี id title image
    return recipes.map((recipe) {
      return {
        'id': recipe['id'], // เก็บ id ของสูตรอาหารด้วย
        'title': recipe['title'].toString(),
        'image': recipe['image'].toString(),
      };
    }).toList();
  } else {
    // แสดง statusCode และ body ในกรณีที่เกิดข้อผิดพลาด
    print('Error Status Code: ${response.statusCode}');
    print('Error Response Body: ${response.body}');
    throw Exception('Failed to load recipes'); //ถ้าเรียก api ไม่ได้
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Set<int> favoriteMenuIds = {}; // เก็บ id ของเมนูโปรด
  List<Map<String, dynamic>> favoriteMenus = []; // รายการเมนูโปรด
  List<Map<String, dynamic>> recentlyViewedRecipes = [];
  List<Map<String, dynamic>> recommendedRecipes = [];
  List<Map<String, dynamic>> newRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }
  Future<void> _loadRecipes() async {
    try {
      //เรียกฟังก์ชัน fetchRecipes จะได้ดึง api อาหารในหมวดต่างๆที่ตั้งค่าไว้
      List<Map<String, dynamic>> recentlyViewed = await fetchRecipes('recently_viewed'); //เมนูล่าสุด
      List<Map<String, dynamic>> recommended = await fetchRecipes('recommended'); //เมนูแนะนำ
      List<Map<String, dynamic>> newRecipesList = await fetchRecipes('new_recipes'); //เมนูใหม่

      setState(() {
        //อัปเดตสถานะของข้อมูลสูตรอาหาร ui
        recentlyViewedRecipes = recentlyViewed; //เก็บสูตรอาหารที่เพิ่งดู
        recommendedRecipes = recommended; //เมนูแนะนำ
        newRecipes = newRecipesList; //เมนูใหม่
        isLoading = false; //ปิดการโหลด
      });
    } catch (error) {
      print('Error loading recipes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Welcome',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Narodom Supmoon',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://www.catdumb.com/wp-content/uploads/2024/05/chefian4.png'),
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (query) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchScreen(query: query),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        _buildSection('Recently viewed', recentlyViewedRecipes),
                        const SizedBox(height: 20),
                        _buildSection('Recommended', recommendedRecipes),
                        const SizedBox(height: 20),
                        _buildSection('New Recipes', newRecipes),
                      ],
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoriteScreen(
                  favoriteMenus: favoriteMenus,
                ),
              ),
            );
          } else if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountScreen(userName: 'Narodom Supmoon'),
      ),
    );
  }
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            TextButton(
                onPressed: () {},
                child: const Text('View More',
                    style: TextStyle(color: Colors.orange))),
          ],
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              bool isFavorite = favoriteMenuIds.contains(items[index]['id']);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                          recipeId: items[index]['id']),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              items[index]['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            items[index]['title']!,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          //จัดการเพิ่มหรือลบสูตรอาหาร
                          setState(() {
                            if (isFavorite) {
                              //ลบเมนูออกจากรายการโปรด
                              favoriteMenuIds.remove(items[index]['id']);
                              favoriteMenus.removeWhere((menu) => menu['id'] == items[index]['id']);
                            } else {
                              favoriteMenuIds.add(items[index]['id']);
                              favoriteMenus.add(items[index]);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
