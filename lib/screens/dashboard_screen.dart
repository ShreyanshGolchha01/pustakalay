import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import 'books_list_screen.dart';
import 'add_book_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoadingStats = false;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get librarian ID from auth provider
      final librarianId = authProvider.librarianId;
      
      print('=== LOADING DASHBOARD DATA ===');
      print('Librarian ID: $librarianId');
      
      final data = await libraryProvider.getDashboardStats(librarianId: librarianId);
      
      print('Dashboard API Response: $data');
      
      setState(() {
        _dashboardData = data;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoadingStats = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('डैशबोर्ड डेटा लोड करने में त्रुटि: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),
              
              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Message
                        _buildWelcomeCard(),
                        
                        SizedBox(height: 24),
                        
                        // Statistics Cards
                        _buildStatsSection(),
                        
                        SizedBox(height: 24),
                        
                        // Recent Books Section
                        _buildRecentBooksSection(),
                        
                        SizedBox(height: 24),
                        
                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.library_books,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'स्मृति पुस्तकालय',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   'Library Management',
                //   style: TextStyle(
                //     color: Colors.white70,
                //     fontSize: 14,
                //   ),
                // ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('लॉगआउट'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: AppTheme.getCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.getWelcomeMessage(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: const Color.fromARGB(255, 0, 0, 0)),
                  SizedBox(width: 4),
                  Text(
                    'अपडेटेड: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        // Use API data if available, fallback to local data
        final apiStats = _dashboardData;
        final localStats = libraryProvider.getLibraryStats();
        
        print('=== STATS SECTION ===');
        print('API Stats: $apiStats');
        print('Local Stats: ${localStats.totalBooks}, ${localStats.totalDonations}, ${localStats.totalDonors}');
        
        // Extract values with proper fallbacks and null safety
        int totalBooks = 0;
        int totalCopies = 0; 
        int totalDonations = 0;
        int totalDonors = 0;
        
        if (apiStats != null) {
          // Parse API data with enhanced type handling
          print('=== API STATS PARSING ===');
          print('Raw API Stats: $apiStats');
          
          // Helper function to safely parse integers
          int safeParseInt(dynamic value) {
            if (value == null) return 0;
            if (value is int) return value;
            if (value is String) return int.tryParse(value) ?? 0;
            return int.tryParse(value.toString()) ?? 0;
          }
          
          totalBooks = safeParseInt(apiStats['total_books']);
          totalCopies = safeParseInt(apiStats['total_copies']);
          totalDonations = safeParseInt(apiStats['total_donations']);
          totalDonors = safeParseInt(apiStats['total_donors']);
          
          print('Final parsed values - Books: $totalBooks, Copies: $totalCopies, Donations: $totalDonations, Donors: $totalDonors');
        } else {
          // Fallback to local data
          totalBooks = localStats.totalBooks;
          totalCopies = localStats.totalBooks; // For local, use same as books
          totalDonations = localStats.totalDonations;
          totalDonors = localStats.totalDonors;
          
          print('Local Data - Books: $totalBooks, Copies: $totalCopies, Donations: $totalDonations, Donors: $totalDonors');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'लाइब्रेरी आंकड़े',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                if (_isLoadingStats)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppTheme.primaryBlue),
                    onPressed: _loadDashboardData,
                    tooltip: 'Refresh Data',
                  ),
              ],
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.1,
              children: [
                _buildStatCard(
                  'कुल प्रतियां',
                  totalCopies.toString(),
                  Icons.book,
                  AppTheme.primaryBlue,
                ),
                _buildStatCard(
                  'कुल दान',
                  totalDonations.toString(),
                  Icons.volunteer_activism,
                  AppTheme.primaryBlue,
                ),
                _buildStatCard(
                  'दानकर्ता',
                  totalDonors.toString(),
                  Icons.people,
                  AppTheme.primaryBlue,
                ),
                _buildStatCard(
                  'कुल पुस्तकें',
                  totalBooks.toString(),
                  Icons.category,
                  AppTheme.primaryBlue,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 1),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBooksSection() {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        final recentBooks = libraryProvider.getRecentBooks();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'हाल की पुस्तकें',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BooksListScreen()),
                    );
                  },
                  child: Text('सभी देखें'),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentBooks.length,
                itemBuilder: (context, index) {
                  final book = recentBooks[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.book,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                book.author,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.inventory_2, size: 14, color: const Color.fromARGB(255, 0, 0, 0)),
                                  SizedBox(width: 4),
                                  Text(
                                    '${book.count}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'त्वरित कार्य',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddBookScreen()),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('पुस्तक जोड़ें'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BooksListScreen()),
                  );
                },
                icon: Icon(Icons.list),
                label: Text('सभी पुस्तकें'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.secondaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppTheme.secondaryBlue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('लॉगआउट'),
        content: Text('क्या आप वाकई लॉगआउट करना चाहते हैं?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('लॉगआउट'),
          ),
        ],
      ),
    );
  }
}
