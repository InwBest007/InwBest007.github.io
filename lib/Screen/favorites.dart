import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart'; // หน้ารายละเอียดสูตรอาหาร

class FavoriteScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteMenus;

  FavoriteScreen({required this.favoriteMenus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Menus'),
      ),
      body: favoriteMenus.isEmpty
          ? const Center(
              child: Text('No favorite menus added yet.'), //ถ้าไม่มีเมนูในรายการโปรดจะขึ้นข้อความ
            )
          : ListView.builder(
              itemCount: favoriteMenus.length, //จำนวนเมนูโปรด
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(favoriteMenus[index]['image']), //รูปเมนู
                  title: Text(favoriteMenus[index]['title']), //ชื่อเมนู
                  onTap: () {
                    // เมื่อกดที่เมนู จะไปยังหน้ารายละเอียดสูตร
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipeId: favoriteMenus[index]['id'], // ส่ง id หรือข้อมูลที่จำเป็นไป
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
