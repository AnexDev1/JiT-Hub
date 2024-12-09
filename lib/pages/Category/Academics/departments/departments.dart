import 'package:flutter/material.dart';
import 'package:nex_planner/data/department_data.dart';

class Departments extends StatelessWidget {
  final Map<String, String> departmentImages = {
    'Faculty of Civil and Environmental Engineering': 'lib/assets/civil.jpg',
    'Faculty of Materials Science and Engineering': 'lib/assets/material.jpg',
    'Faculty of Electrical and Computer Engineering':
        'lib/assets/electrical.jpg',
    'Faculty of Mechanical Engineering': 'lib/assets/mechanical.jpg',
    'Faculty of Computing and Informatics': 'lib/assets/informatics.jpg',
    'School of Biomedical Engineering': 'lib/assets/biomedical.jpg',
    'School of Chemical Engineering': 'lib/assets/chemical.jpg',
    'Aviation Science and Aerospace Engineering Academy':
        'lib/assets/aviation.jpg',
    'Freshman and Non-Institute Courses': 'lib/assets/freshman.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculties and Schools'),
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
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepartmentDetailScreen(
                      departmentName: department,
                      departmentDetail: departmentDetails[department] ??
                          'Details not available',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(departmentImages[department] ??
                        'lib/assets/placeholder.jpg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.black54,
                        child: Text(
                          department,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (department ==
                        'Aviation Science and Aerospace Engineering Academy')
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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

  const DepartmentDetailScreen({
    Key? key,
    required this.departmentName,
    required this.departmentDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(departmentName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            departmentDetail,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Departments(),
  ));
}
