import 'package:flutter/material.dart';
import 'package:nex_planner/pages/Category/category_detail.dart';

class CategoryTab extends StatefulWidget {
  final List<Item> items;

  const CategoryTab({super.key, required this.items});

  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
  }

  void _pinToTop(int index) {
    setState(() {
      final item = items.removeAt(index);
      items.insert(0, item);
    });
  }

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
                      _pinToTop(index);
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