import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CafeMenu extends StatefulWidget {
  const CafeMenu({super.key});

  @override
  State<CafeMenu> createState() => _CafeMenuState();
}

class _CafeMenuState extends State<CafeMenu> {
  int _selectedDayIndex = DateTime.now().weekday - 1;
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Mapping meal types to their image paths
  final Map<String, Map<String, String>> _mealImages = {
    'Monday': {
      'breakfast': 'lib/assets/foods/rice-tomato.jpg',
      'lunch': 'lib/assets/foods/shiro-vegitable.jpg',
      'dinner': 'lib/assets/foods/kek.jpg',
    },
    'Tuesday': {
      'breakfast': 'lib/assets/foods/kinche.jpg',
      'lunch': 'lib/assets/foods/kek.jpg',
      'dinner': 'lib/assets/foods/dinch-besga.jpg',
    },
    'Wednesday': {
      'breakfast': 'lib/assets/foods/kinche.jpg',
      'lunch': 'lib/assets/foods/kek.jpg',
      'dinner': 'lib/assets/foods/shiro.jpg',
    },
    'Thursday': {
      'breakfast': 'lib/assets/foods/rice-tomato.jpg',
      'lunch': 'lib/assets/foods/shiro-vegitable.jpg',
      'dinner': 'lib/assets/foods/kek.jpg',
    },
    'Friday': {
      'breakfast': 'lib/assets/foods/kinche.jpg',
      'lunch': 'lib/assets/foods/dinch.jpg',
      'dinner': 'lib/assets/foods/shiro-vegitable.jpg',
    },
    'Saturday': {
      'breakfast': 'lib/assets/foods/rice-tomato.jpg',
      'lunch': 'lib/assets/foods/dinch-besga.jpg',
      'dinner': 'lib/assets/foods/kek.jpg',
    },
    'Sunday': {
      'breakfast': 'lib/assets/foods/firfir.jpg',
      'lunch': 'lib/assets/foods/shiro.jpg',
      'dinner': 'lib/assets/foods/kek.jpg',
    },
  };

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final selectedDay = _weekdays[_selectedDayIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(today),
            _buildDaySelector(),
            Expanded(
              child: _buildDayMenu(selectedDay),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime today) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withBlue(150),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                'University Cafe Menu',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dateFormat.format(today),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _weekdays.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          final isToday = index == (DateTime.now().weekday - 1);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 88,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isToday
                    ? Theme.of(context).primaryColor.withValues(alpha:0.1)
                    : Colors.grey[100],
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isToday
                      ? Theme.of(context).primaryColor.withValues(alpha:0.5)
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[index],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? Theme.of(context).primaryColor
                          : Colors.grey[800],
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha:0.3) : Theme.of(context).primaryColor.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Today',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayMenu(String day) {
    final dayMenu = _getMenuForDay(day);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildMealCard(
          'Breakfast',
          'Served 7:00 AM - 9:30 AM',
          Icons.free_breakfast_outlined,
          Colors.amber[700]!,
          dayMenu['breakfast']!,
          _mealImages[day]?['breakfast'] ?? 'lib/assets/meals/default_breakfast.jpg',
        ),
        const SizedBox(height: 20),
        _buildMealCard(
          'Lunch',
          'Served 12:00 PM - 2:30 PM',
          Icons.lunch_dining_outlined,
          Colors.green[700]!,
          dayMenu['lunch']!,
          _mealImages[day]?['lunch'] ?? 'lib/assets/meals/default_lunch.jpg',
        ),
        const SizedBox(height: 20),
        _buildMealCard(
          'Dinner',
          'Served 6:00 PM - 8:30 PM',
          Icons.dinner_dining_outlined,
          Colors.indigo[700]!,
          dayMenu['dinner']!,
          _mealImages[day]?['dinner'] ?? 'lib/assets/meals/default_dinner.jpg',
        ),
      ],
    );
  }

  // dart
  Widget _buildMealCard(
      String mealType,
      String hours,
      IconData icon,
      Color color,
      Map<String, List<String>> items,
      String imagePath,
      ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: color.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 60,
                            color: color.withOpacity(0.6),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Meal type label
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          mealType,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Serving hours
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hours,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category.key),
                          size: 20,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.key,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...category.value.map((dish) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 7),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dish,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Main Course':
        return Icons.restaurant;
      case 'Side Items':
        return Icons.fastfood;
      case 'Beverages':
        return Icons.local_drink;
      case 'Dessert':
        return Icons.cake;
      default:
        return Icons.category;
    }
  }

  // Sample menu data
  Map<String, Map<String, List<String>>> _getMenuForDay(String day) {
    final Map<String, Map<String, Map<String, List<String>>>> weeklyMenu = {
      'Monday': {
        'breakfast': {
          'Main Course': [
              'ሩዝ በቲማቲም ስጎ'
          ],

          'Beverages': [ 'Tea'
          ],
        },
        'lunch': {
          'Main Course': [
           'ሽሮ በአትክልት'
          ],

        },
        'dinner': {
          'Main Course': [
            'ክክ ወጥ'
          ],

        },
      },
      'Tuesday': {
        'breakfast': {
          'Main Course': [
            'ቅንጬ'
          ],
          'Beverages': [
            'Tea'
          ],
        },
        'lunch': {
          'Main Course': [
           'ክክ ወጥ'
          ],

        },
        'dinner': {
          'Main Course': [
          'ድንች በስጋ ወጥ'
          ],

        },
      },
      'Wednesday': {
        'breakfast': {
          'Main Course': [
            'ቅንጬ'
          ],
          'Beverages': ['Tea'
          ],
        },
        'lunch': {
          'Main Course': [
            'ክክ ወጥ'
          ],

        },
        'dinner': {
          'Main Course': [
            'ሽሮ ወጥ'
          ],

        },
      },
      'Thursday': {
        'breakfast': {
          'Main Course': [
            'ሩዝ በቲማቲም ሱጎ'
          ],
          'Beverages': [
          'Tea'
          ],
        },
        'lunch': {
          'Main Course': [
            'ሽሮና አትክልት'
          ],

        },
        'dinner': {
          'Main Course': [
            'ክክ ወጥ'
          ],

        },
      },
      'Friday': {
        'breakfast': {
          'Main Course': [
            'ቅንጬ'
          ],
          'Beverages': [ 'Tea'
          ],
        },
        'lunch': {
          'Main Course': [
           'ድንች ወጥ'
          ],

        },
        'dinner': {
          'Main Course': [
          'ሽሮና አትክልት'
          ],

        },
      },
      'Saturday': {
        'breakfast': {
          'Main Course': [
            'ሩዝ በቲማቲም ሱጎ',
          ],
          'Beverages': [ 'Tea',
          ],
        },
        'lunch': {
          'Main Course': [
            'ድንች በስጋ ወጥ'
          ],

        },
        'dinner': {
          'Main Course': [
           'ክክ ወጥ'
          ],

        },
      },
      'Sunday': {
        'breakfast': {
          'Main Course': [
            'እንጀራ ፍርፍር',
          ],
          'Beverages': [ 'Tea',
          ],
        },
        'lunch': {
          'Main Course': [
         'ሽሮ ወጥ'
          ],

        },
        'dinner': {
          'Main Course': [
           'ክክ ወጥ'
          ],

        },
      },
    };

    return weeklyMenu[day] ?? {
      'breakfast': {
        'Main Items': [
        'Not Available',
        ]
      },
      'lunch': {
        'Main Items': [
         'Not Available'
        ]
      },
      'dinner': {
        'Main Items': [
         'Not Available'
        ]
      },
    };
  }
}