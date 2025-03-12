import 'package:flutter/material.dart';
import 'package:nex_planner/data/department_data.dart';
import 'package:google_fonts/google_fonts.dart';

class Departments extends StatelessWidget {
  final Map<String, String> departmentImages = {
    'Civil and Environmental Engineering': 'lib/assets/civil.jpg',
    'Material Science and Engineering': 'lib/assets/material.jpg',
    'Electrical and Computer Engineering': 'lib/assets/electrical.jpg',
    'Mechanical Engineering': 'lib/assets/mechanical.jpg',
    'Computing and Informatics': 'lib/assets/computing.jpg',
    'Biomedical Engineering': 'lib/assets/biomedical.jpg',
    'Chemical Engineering': 'lib/assets/chemical.jpg',
    'Aviation Science and Aerospace Engineering Academy': 'lib/assets/aviation.jpg',
    'Freshman and Non-Institute Courses': 'lib/assets/freshman.jpg',
  };

  // Icons for departments
  final Map<String, IconData> departmentIcons = {
    'Civil and Environmental Engineering': Icons.domain,
    'Material Science and Engineering': Icons.science,
    'Electrical and Computer Engineering': Icons.electrical_services,
    'Mechanical Engineering': Icons.precision_manufacturing,
    'Computing and Informatics': Icons.computer,
    'Biomedical Engineering': Icons.biotech,
    'Chemical Engineering': Icons.science,
    'Aviation Science and Aerospace Engineering Academy': Icons.flight,
    'Freshman and Non-Institute Courses': Icons.school,
  };

  Departments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Faculties & Schools',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha:0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: Colors.white.withValues(alpha:0.85),
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${departments.length} Academic Departments',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha:0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Departments grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  String department = departments[index];
                  bool isNew = department == 'Aviation Science and Aerospace Engineering Academy';
                  return _buildDepartmentCard(context, department, isNew);
                },
                childCount: departments.length,
              ),
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, String department, bool isNew) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DepartmentDetailScreen(
                departmentName: department,
                departmentDetail: departmentDetails[department] ?? 'Details not available',
                imagePath: departmentImages[department] ?? 'lib/assets/placeholder.jpg',
                icon: departmentIcons[department] ?? Icons.school,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Hero(
              tag: department,
              child: Image.asset(
                departmentImages[department] ?? 'lib/assets/placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha:0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department icon
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        departmentIcons[department] ?? Icons.school,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Department name
                  Text(
                    department.trim(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha:0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // "NEW" badge
            if (isNew)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'NEW',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DepartmentDetailScreen extends StatelessWidget {
  final String departmentName;
  final String departmentDetail;
  final String imagePath;
  final IconData icon;

  const DepartmentDetailScreen({
    super.key,
    required this.departmentName,
    required this.departmentDetail,
    required this.imagePath,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with hero image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                departmentName.trim(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha:0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image
                  Hero(
                    tag: departmentName,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha:0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Department info
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Department header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha:0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              departmentName.trim(),
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Academic Department',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Department content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About this Department',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Department detail paragraphs
                      ...departmentDetail.split('\n\n').map((paragraph) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paragraph,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )),

                      // Contact section
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'For More Information',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on_outlined, 'Department Office: JIT Campus'),
                            _buildInfoRow(Icons.email_outlined, 'Contact: department@jit.edu.et'),
                            _buildInfoRow(Icons.phone_outlined, 'Phone: +251 (0) 123-4567'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}