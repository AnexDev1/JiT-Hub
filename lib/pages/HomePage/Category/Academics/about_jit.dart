import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutJit extends StatelessWidget {
  const AboutJit({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header with overlay and title
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About JIT',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with gradient overlay
                  Image.asset(
                    'lib/assets/jit.jpg',
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Institute name and motto
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Jimma Institute of Technology',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Technology for Community Development',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // History section with card
                  _buildSectionHeader(
                      context,
                      'History',
                      Icons.history_edu_outlined
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildParagraph(
                              'The Jimma Institute of Technology was initially established as the faculty of technology (FoT) back in 1997 when the government decided to expand the then Jimma Institute of Healthy Science (founded in 1983) beyond health fields and upgrade it into a full-fledged university with the opening of faculty of technology and faculty of business and economics.'
                          ),
                          const SizedBox(height: 12),
                          _buildParagraph(
                              'Upon its establishment, the faculty comprised three departments: the Civil Engineering Department, the Electrical Engineering Department, and the Mechanical Engineering Department.'
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Academic Programs section
                  _buildSectionHeader(
                      context,
                      'Academic Programs',
                      Icons.school_outlined
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildParagraph(
                              'The first batch of students from the Faculty of Technology\'s regular program graduated in 2002. Since then, the faculty has turned out competent graduates and contributed to the country\'s development.'
                          ),
                          const SizedBox(height: 12),
                          _buildParagraph(
                              'To diversify its study programs, two more engineering programs, namely Water Resource and Environmental Engineering and Biomedical Engineering departments, were launched in the faculty. With this, the number of engineering departments has increased to five.'
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Curriculum section
                  _buildSectionHeader(
                      context,
                      'Curriculum',
                      Icons.menu_book_outlined
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildParagraph(
                          'Initially, the study period of undergraduate engineering departments was five years. However, due to the reform introduced into the country\'s educational system, it was reduced to four years in 2003.'
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Departments section with cards for each
                  _buildSectionHeader(
                      context,
                      'Engineering Departments',
                      Icons.business_outlined
                  ),
                  const SizedBox(height: 12),
                  _buildDepartmentsList(),

                  const SizedBox(height: 32),

                  // Vision/Mission statement
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.primaryColor,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Our Motto',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Technology for Community Development!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.5,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildDepartmentsList() {
    final departments = [
      {'name': 'Civil Engineering', 'icon': Icons.domain},
      {'name': 'Electrical Engineering', 'icon': Icons.electrical_services},
      {'name': 'Mechanical Engineering', 'icon': Icons.precision_manufacturing},
      {'name': 'Water Resource and Environmental Engineering', 'icon': Icons.water_drop},
      {'name': 'Biomedical Engineering', 'icon': Icons.biotech},
    ];

    return Column(
      children: departments.map((dept) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(dept['icon'] as IconData),
            title: Text(
              dept['name']! as String,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      }).toList(),
    );
  }
}