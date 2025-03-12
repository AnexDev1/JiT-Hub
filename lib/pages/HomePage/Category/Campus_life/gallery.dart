import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  // Sample gallery items - replace with your actual images
  final List<GalleryItem> galleryItems = [
    GalleryItem(
      id: '1',
      imageUrl: 'lib/assets/biomedical.jpg',
      title: 'University Library',
      description: 'The main library building on campus',
    ),
    GalleryItem(
      id: '2',
      imageUrl: 'lib/assets/civil.jpg',
      title: 'Graduation Ceremony',
      description: 'Students celebrating their achievements',
    ),
    GalleryItem(
      id: '3',
      imageUrl: 'lib/assets/electrical.jpg',
      title: 'Sports Complex',
      description: 'Students enjoying various sports activities',
    ),
    GalleryItem(
      id: '4',
      imageUrl: 'lib/assets/computing.jpg',
      title: 'Campus Cafeteria',
      description: 'Where students gather for meals and conversations',
    ),
    GalleryItem(
      id: '5',
      imageUrl: 'lib/assets/biomedical.jpg',
      title: 'Science Laboratory',
      description: 'State-of-the-art research facilities',
    ),
    GalleryItem(
      id: '6',
      imageUrl:  'lib/assets/civil.jpg',
      title: 'Cultural Event',
      description: 'Annual cultural celebration on campus',
    ),
    GalleryItem(
      id: '7',
      imageUrl: 'lib/assets/civil.jpg',
      title: 'Student Dormitories',
      description: 'On-campus accommodation facilities',
    ),
    GalleryItem(
      id: '8',
      imageUrl:  'lib/assets/aviation.jpg',
      title: 'Campus Garden',
      description: 'Green space for relaxation and study',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Campus Life Gallery',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Explore life at Jimma University through our collection of memorable campus moments.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: galleryItems.length,
                  itemBuilder: (context, index) {
                    return GalleryItemWidget(
                      item: galleryItems[index],
                      onTap: () => _openGallery(context, index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryViewer(
          galleryItems: galleryItems,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class GalleryItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class GalleryItemWidget extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;

  const GalleryItemWidget({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Hero(
            tag: 'gallery_${item.id}',
            child: Image.asset(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryViewer extends StatefulWidget {
  final List<GalleryItem> galleryItems;
  final int initialIndex;

  const GalleryViewer({
    Key? key,
    required this.galleryItems,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isInfoVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleInfoVisibility() {
    setState(() {
      _isInfoVisible = !_isInfoVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleInfoVisibility,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: AssetImage(widget.galleryItems[index].imageUrl),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'gallery_${widget.galleryItems[index].id}',
                  ),
                );
              },
              itemCount: widget.galleryItems.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            // Close button
            AnimatedOpacity(
              opacity: _isInfoVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, color: Colors.white),
                          onPressed: () {
                            // Add share functionality here
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Image info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _isInfoVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.galleryItems[_currentIndex].title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.galleryItems[_currentIndex].description,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_currentIndex + 1}/${widget.galleryItems.length}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
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