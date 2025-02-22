import 'package:flutter/material.dart';
import 'package:nex_planner/data/department_data.dart';

class Departments extends StatelessWidget {
  final Map<String, String> departmentImages = {
    ' Civil and Environmental Engineering': 'lib/assets/civil.jpg',
    'Material Science and Engineering': 'lib/assets/material.jpg',
    ' Electrical and Computer Engineering': 'lib/assets/electrical.jpg',
    ' Mechanical Engineering': 'lib/assets/mechanical.jpg',
    'Computing and Informatics': 'lib/assets/computing.jpg',
    'Biomedical Engineering': 'lib/assets/biomedical.jpg',
    'Chemical Engineering': 'lib/assets/chemical.jpg',
    'Aviation Science and Aerospace Engineering Academy': 'lib/assets/aviation.jpg',
    'Freshman and Non-Institute Courses': 'lib/assets/freshman.jpg',
  };

   Departments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculties and Schools'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0, // Aspect ratio of the grid items
          ),
          itemCount: departments.length,
          itemBuilder: (context, index) {
            String department = departments[index];
            print(departmentImages[department]);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepartmentDetailScreen(
                      departmentName: department,
                      departmentDetail: departmentDetails[department] ?? 'Details not available',
                      imagePath: departmentImages[department] ?? 'lib/assets/placeholder.jpg',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Hero(
                      tag: department,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(departmentImages[department] ?? 'lib/assets/placeholder.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        color: Colors.black54,
                        child: Text(
                          department,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (department == 'Aviation Science and Aerospace Engineering Academy')
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DepartmentDetailScreen extends StatelessWidget {
  final String departmentName;
  final String departmentDetail;
  final String imagePath;

  const DepartmentDetailScreen({
    super.key,
    required this.departmentName,
    required this.departmentDetail,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(departmentName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: departmentName,
                child: Image.asset(imagePath),
              ),
              const SizedBox(height: 16.0),
              Text(
                departmentDetail,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}