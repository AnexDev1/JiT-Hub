import 'package:flutter/material.dart';
import 'package:nex_planner/pages/Category/CategoryDetailScreen.dart';

class CategoryTab extends StatelessWidget {
  final List<Item> items;

  const CategoryTab({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryDetailScreen(categoryName: item.title),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                if (item is CategoryItem) Icon(item.icon), // Leading icon
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.title),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'open') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryDetailScreen(categoryName: item.title),
                        ),
                      );
                    } else if (value == 'pin') {
                      // Handle pin to top logic
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'open',
                        child: Text('Open'),
                      ),
                      const PopupMenuItem(
                        value: 'pin',
                        child: Text('Pin to top'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert), // Trailing icon
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Item {
  final String title;

  Item(this.title);
}

class CategoryItem extends Item {
  final IconData icon;
  final String description;

  CategoryItem({
    required this.icon,
    required String title,
    required this.description,
  }) : super(title);
}
