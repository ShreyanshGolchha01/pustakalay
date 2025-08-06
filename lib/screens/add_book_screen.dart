import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
// import 'dart:typed_data';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../models/app_models.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _searchMobileController = TextEditingController();
  final _searchBookController = TextEditingController();
  
  bool _isNewUser = true;
  User? _selectedUser;
  String? _createdDonorId; // Store created donor ID
  final List<Map<String, dynamic>> _selectedBooks = []; // {book: Book, count: int}
  File? _certificateImage;
  String? _uploadedCertificatePath; // Store uploaded certificate path
  bool _isLoading = false;
  bool _isLoadingBooks = false;
  bool _isCreatingDonor = false;
  bool _isUploadingCertificate = false;
  // bool _showBookSearch = false;

  // Mock books database - remove when backend ready
  final List<Book> _availableBooks = [];

  // Book form controllers for adding new book
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();

  final List<String> _commonGenres = [
    'धर्म', 'राजनीति', 'इतिहास', 'साहित्य', 'विज्ञान', 
    'कानूनी', 'उपन्यास', 'कहानी', 'काव्य', 'नाटक', 'जीवनी', 'दर्शन'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialBooks();
  }

  Future<void> _loadInitialBooks() async {
    try {
      print('=== LOADING INITIAL BOOKS IN ADD_BOOK_SCREEN ===');
      final apiService = ApiService();
      final books = await apiService.searchBooks();
      
      print('Books received: ${books?.length ?? 0}');
      if (books != null) {
        for (var book in books) {
          print('Book: ${book.title} by ${book.author}, Count: ${book.count}');
        }
        setState(() {
          _availableBooks.clear();
          _availableBooks.addAll(books);
        });
        print('Available books updated: ${_availableBooks.length}');
      } else {
        print('No books received from API');
      }
    } catch (e) {
      print('Error loading initial books: $e');
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
              _buildAppBar(),
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
                        _buildUserSelectionSection(),
                        
                        // Only show user details section for new users
                        if (_isNewUser) ...[
                          SizedBox(height: 24),
                          _buildUserDetailsSection(),
                        ],
                        
                        // Show books section only if donor is ready
                        if ((_isNewUser && _createdDonorId != null) || (!_isNewUser && _selectedUser != null)) ...[
                          SizedBox(height: 24),
                          _buildBooksSection(),
                        ],
                        
                        // Show certificate section only if books are selected
                        if (_selectedBooks.isNotEmpty) ...[
                          SizedBox(height: 24),
                          _buildCertificateSection(),
                        ],
                        
                        // Show submit button only if everything is ready
                        if (_selectedBooks.isNotEmpty) ...[
                          SizedBox(height: 24),
                          _buildSubmitButton(),
                        ],
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'पुस्तक दान जोड़ें',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   'Add Book Donation',
                //   style: TextStyle(
                //     color: Colors.white70,
                //     fontSize: 14,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSelectionSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'दानकर्ता चुनें',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: Text(
                    'नया उपयोगकर्ता',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: true,
                  groupValue: _isNewUser,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _isNewUser = value!;
                      _selectedUser = null;
                      _createdDonorId = null; // Reset created donor
                      _selectedBooks.clear(); // Reset selected books
                      _certificateImage = null; // Reset certificate
                      _uploadedCertificatePath = null; // Reset uploaded certificate
                      // Clear form controllers
                      _nameController.clear();
                      _mobileController.clear();
                      _searchMobileController.clear();
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: Text(
                    'मौजूदा उपयोगकर्ता',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: false,
                  groupValue: _isNewUser,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _isNewUser = value!;
                      _selectedUser = null;
                      _createdDonorId = null; // Reset created donor
                      _selectedBooks.clear(); // Reset selected books
                      _certificateImage = null; // Reset certificate
                      _uploadedCertificatePath = null; // Reset uploaded certificate
                      // Clear form controllers
                      _nameController.clear();
                      _mobileController.clear();
                      _searchMobileController.clear();
                    });
                  },
                ),
              ),
            ],
          ),
          if (!_isNewUser) ...[
            SizedBox(height: 16),
            TextField(
              controller: _searchMobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'मोबाइल नंबर खोजें',
                prefixIcon: Icon(Icons.search),
                suffixIcon: ElevatedButton(
                  onPressed: _searchUser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('खोजें'),
                ),
              ),
            ),
            if (_selectedUser != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightBlue),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedUser!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            _selectedUser!.mobileNumber,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUserDetailsSection() {
    // Hide completely for existing user selection
    if (!_isNewUser) return SizedBox.shrink();
    
    // If donor is already created, show confirmation
    if (_createdDonorId != null) {
      return Container(
        padding: EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'दानकर्ता विवरण',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'दानकर्ता सफलतापूर्वक जोड़ा गया',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '${_nameController.text} • ${_mobileController.text}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'ID: $_createdDonorId',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
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
    
    // Show form for new user only
    return Container(
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'दानकर्ता विवरण',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'पूरा नाम *',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild to enable/disable button
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया नाम दर्ज करें';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'मोबाइल नंबर *',
              prefixIcon: Icon(Icons.phone),
              counterText: '', // Hide character counter
              helperText: '10 अंकों का मोबाइल नंबर दर्ज करें',
            ),
            onChanged: (value) {
              // Only allow numbers and limit to 10 digits
              if (value.length <= 10 && RegExp(r'^[0-9]*$').hasMatch(value)) {
                setState(() {}); // Trigger rebuild to enable/disable button
              } else if (value.length > 10 || !RegExp(r'^[0-9]*$').hasMatch(value)) {
                // Remove invalid characters or excess characters
                final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                final truncatedValue = cleanValue.length > 10 ? cleanValue.substring(0, 10) : cleanValue;
                _mobileController.text = truncatedValue;
                _mobileController.selection = TextSelection.fromPosition(
                  TextPosition(offset: truncatedValue.length),
                );
                setState(() {});
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया मोबाइल नंबर दर्ज करें';
              }
              if (value.length != 10) {
                return 'कृपया 10 अंक का मोबाइल नंबर दर्ज करें';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'कृपया केवल संख्या दर्ज करें';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canCreateDonor() && !_isCreatingDonor ? _createDonor : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCreatingDonor
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('दानकर्ता जोड़ा जा रहा है...'),
                      ],
                    )
                  : Text(
                      'दानकर्ता जोड़ें',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCreateDonor() {
    return _nameController.text.trim().isNotEmpty && 
           _mobileController.text.trim().length == 10 &&
           RegExp(r'^[0-9]+$').hasMatch(_mobileController.text.trim());
  }

  Future<void> _createDonor() async {
    setState(() {
      _isCreatingDonor = true;
    });

    try {
      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print('=== CREATING NEW DONOR ===');
      print('Name: ${_nameController.text}');
      print('Mobile: ${_mobileController.text}');
      print('Librarian ID: ${authProvider.librarianId}');
      
      final result = await apiService.addDonor(
        _nameController.text.trim(),
        _mobileController.text.trim(),
        authProvider.librarianId ?? '',
      );
      
      print('Create donor result: $result');
      
      if (result != null && result['success'] == true) {
        // Get donor ID from response
        final donorId = (result['data']['u_id'] ?? 
                        result['data']['donor_id'] ?? 
                        result['u_id'] ?? 
                        result['donor_id']).toString();
        
        setState(() {
          _createdDonorId = donorId;
          _isCreatingDonor = false;
        });
        
        print('Donor created successfully with ID: $donorId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('दानकर्ता सफलतापूर्वक जोड़ा गया'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isCreatingDonor = false;
        });
        
        final errorMessage = result?['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('दानकर्ता जोड़ने में त्रुटि: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingDonor = false;
      });
      
      print('Error creating donor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('त्रुटि: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBooksSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'पुस्तकें चुनें',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showBookSearchDialog,
                icon: Icon(Icons.search, size: 16),
                label: Text('खोजें'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_selectedBooks.isEmpty)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.book_outlined, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text(
                    'अभी तक कोई पुस्तक नहीं चुनी गई',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'पुस्तक खोजने के लिए "खोजें" बटन दबाएं',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _selectedBooks.asMap().entries.map((entry) {
                final index = entry.key;
                final bookData = entry.value;
                final book = bookData['book'] as Book;
                final count = bookData['count'] as int;
                return _buildSelectedBookItem(book, count, index);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedBookItem(Book book, int count, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.book, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  '${book.author} • ${book.genre}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count प्रतियां',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedBooks.removeAt(index);
              });
            },
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'दान प्रमाणपत्र',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 16),
          
          // Show success if certificate is already uploaded
          if (_uploadedCertificatePath != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'प्रमाणपत्र सफलतापूर्वक अपलोड किया गया',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          _uploadedCertificatePath!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (_certificateImage == null)
            InkWell(
              onTap: _pickCertificateImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      'प्रमाणपत्र की फोटो लें',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'कैमरा खोलने के लिए टैप करें',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightBlue),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.file(
                          _certificateImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 16,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _certificateImage = null;
                                });
                              },
                              icon: Icon(Icons.close, color: Colors.white, size: 16),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canUploadCertificate() && !_isUploadingCertificate ? _uploadCertificate : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isUploadingCertificate
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('अपलोड हो रहा है...'),
                            ],
                          )
                        : Text(
                            'प्रमाणपत्र अपलोड करें',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  bool _canUploadCertificate() {
    final donorId = _isNewUser ? _createdDonorId : _selectedUser?.id;
    return _certificateImage != null && donorId != null;
  }

  Future<void> _uploadCertificate() async {
    setState(() {
      _isUploadingCertificate = true;
    });

    try {
      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final donorId = _isNewUser ? _createdDonorId : _selectedUser?.id;
      
      print('=== UPLOADING CERTIFICATE ===');
      print('Certificate file path: ${_certificateImage!.path}');
      print('Donor ID: $donorId');
      print('Librarian ID: ${authProvider.librarianId}');
      
      final uploadResult = await apiService.uploadCertificate(
        certificateFile: _certificateImage!,
        donorId: donorId!,
        librarianId: authProvider.librarianId ?? '',
      );
      
      print('Upload result: $uploadResult');
      
      if (uploadResult != null && uploadResult['success'] == true) {
        final certificateFilename = uploadResult['data']['file_path'] ?? 
                              uploadResult['data']['filename'] ?? 
                              uploadResult['filename'] ?? 
                              uploadResult['file_path'];
        
        setState(() {
          _uploadedCertificatePath = certificateFilename;
          _isUploadingCertificate = false;
        });
        
        print('Certificate uploaded successfully: $certificateFilename');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('प्रमाणपत्र सफलतापूर्वक अपलोड किया गया'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isUploadingCertificate = false;
        });
        
        final errorMessage = uploadResult?['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('प्रमाणपत्र अपलोड करने में त्रुटि: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingCertificate = false;
      });
      
      print('Error uploading certificate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('त्रुटि: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSubmitButton() {
    final donorId = _isNewUser ? _createdDonorId : _selectedUser?.id;
    final canSubmit = donorId != null && _selectedBooks.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit && !_isLoading ? _submitDonation : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('दान सबमिट हो रहा है...'),
                ],
              )
            : Text(
                'दान सबमिट करें',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }

  Future<void> _searchUser() async {
    if (_searchMobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('कृपया मोबाइल नंबर दर्ज करें'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final user = await apiService.searchDonor(_searchMobileController.text.trim());
      
      setState(() {
        _selectedUser = user;
        _isLoading = false;
      });
      
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('दानकर्ता मिल गया: ${user.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('इस मोबाइल नंबर के साथ कोई दानकर्ता नहीं मिला'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _selectedUser = null;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('खोज में त्रुटि: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _searchBooks(String query) async {
    print('=== SEARCHING BOOKS ===');
    print('Query: "$query"');
    print('Current available books: ${_availableBooks.length}');
    
    // If query is empty, clear the books list
    if (query.trim().isEmpty) {
      setState(() {
        _availableBooks.clear();
        _isLoadingBooks = false;
      });
      return;
    }
    
    setState(() {
      _isLoadingBooks = true;
    });

    try {
      final apiService = ApiService();
      final books = await apiService.searchBooks(query: query.trim());
      
      print('Search API returned: ${books?.length ?? 0} books');
      
      setState(() {
        _availableBooks.clear();
        if (books != null) {
          _availableBooks.addAll(books);
          print('Updated available books: ${_availableBooks.length}');
          for (var book in _availableBooks) {
            print('- ${book.title} by ${book.author}');
          }
        } else {
          print('No books returned from API');
        }
        _isLoadingBooks = false;
      });
    } catch (e) {
      print('Error in _searchBooks: $e');
      setState(() {
        _isLoadingBooks = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('पुस्तक खोज में त्रुटि: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookSearchDialog() {
    // Don't load books initially - only when user searches
    print('=== OPENING BOOK SEARCH DIALOG ===');
    print('Available books before dialog: ${_availableBooks.length}');
    
    // Clear search controller and available books for fresh start
    _searchBookController.clear();
    setState(() {
      _availableBooks.clear();
    });
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            height: 600,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'पुस्तक खोजें',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _searchBookController,
                  decoration: InputDecoration(
                    labelText: 'पुस्तक का नाम या लेखक खोजें',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        print('Search button pressed: ${_searchBookController.text}');
                        _searchBooks(_searchBookController.text).then((_) {
                          setDialogState(() {}); // Update dialog state
                        });
                      },
                      icon: Icon(Icons.search),
                    ),
                  ),
                  onChanged: (value) {
                    print('Search text changed: $value');
                    _searchBooks(value).then((_) {
                      setDialogState(() {}); // Update dialog state
                    });
                  },
                ),
                SizedBox(height: 16),
                Expanded(
                  child: _isLoadingBooks
                      ? Center(child: CircularProgressIndicator())
                      : _availableBooks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    _searchBookController.text.trim().isEmpty 
                                        ? 'पुस्तक खोजने के लिए ऊपर टाइप करें'
                                        : 'कोई पुस्तक नहीं मिली',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  if (_searchBookController.text.trim().isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showAddNewBookDialog();
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('नई पुस्तक जोड़ें'),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _availableBooks.length,
                              itemBuilder: (context, index) {
                                final book = _availableBooks[index];
                                return _buildSearchResultItem(book);
                              },
                            ),
                ),
                if (_availableBooks.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddNewBookDialog();
                        },
                        icon: Icon(Icons.add),
                        label: Text('नई पुस्तक जोड़ें'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(Book book) {
    print('Building search result item for: ${book.title}');
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.book, color: Colors.white, size: 20),
          ),
          title: Text(
            book.title,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${book.author} • ${book.genre}'),
              Text('उपलब्ध: ${book.count} प्रतियां', 
                style: TextStyle(fontSize: 12, color: Colors.blue[600]),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () => _selectBookWithCount(book),
            child: Text('चुनें'),
          ),
        ),
      ),
    );
  }

  void _selectBookWithCount(Book book) {
    Navigator.pop(context); // Close search dialog
    _showBookCountDialog(book);
  }

  void _showBookCountDialog(Book book) {
    final countController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('प्रतियों की संख्या'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('पुस्तक: ${book.title}'),
            Text('लेखक: ${book.author}'),
            SizedBox(height: 16),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'कितनी प्रतियां दान की जा रही हैं?',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () {
              if (countController.text.isNotEmpty) {
                final count = int.tryParse(countController.text);
                if (count != null && count > 0) {
                  // Validate book ID before adding
                  if (book.id.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('पुस्तक ID गुम है। कृपया पुस्तक फिर से चुनें।'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  setState(() {
                    _selectedBooks.add({
                      'book': book,
                      'count': count,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('पुस्तक सफलतापूर्वक जोड़ी गई'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('कृपया वैध संख्या दर्ज करें'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('जोड़ें'),
          ),
        ],
      ),
    );
  }

  void _showAddNewBookDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'नई पुस्तक जोड़ें',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'पुस्तक का शीर्षक *',
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया शीर्षक दर्ज करें';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    labelText: 'लेखक *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया लेखक का नाम दर्ज करें';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genreController.text.isEmpty ? null : _genreController.text,
                  decoration: InputDecoration(
                    labelText: 'विषय श्रेणी *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _commonGenres.map((genre) {
                    return DropdownMenuItem(
                      value: genre,
                      child: Text(genre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _genreController.text = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया विषय श्रेणी चुनें';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearBookForm();
                        },
                        child: Text('रद्द करें'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addNewBook,
                        child: Text('जोड़ें'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addNewBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        print('=== ADDING NEW BOOK ===');
        print('Title: ${_titleController.text}');
        print('Author: ${_authorController.text}');
        print('Genre: ${_genreController.text}');
        print('Librarian ID: ${authProvider.librarianId}');
        
        final result = await apiService.addBook(
          title: _titleController.text,
          author: _authorController.text,
          genre: _genreController.text,
          count: 0, // Default count for new book
          librarianId: authProvider.librarianId ?? '',
        );

        print('Add book API result: $result');

        if (result != null && result['success'] == true) {
          // Create Book object from API response with null safety
          final bookData = result['data'];
          print('Book data from API: $bookData');
          print('Full API result: $result');
          
          // Extract book ID from multiple possible locations
          String bookId = '';
          if (bookData != null) {
            bookId = (bookData['b_id'] ?? 
                     bookData['id'] ?? 
                     bookData['book_id'] ?? '').toString();
          }
          
          // If still empty, check root level
          if (bookId.isEmpty) {
            bookId = (result['b_id'] ?? 
                     result['id'] ?? 
                     result['book_id'] ?? '').toString();
          }
          
          print('Extracted book ID: $bookId');
          
          final book = Book(
            id: bookId,
            title: bookData?['b_title'] ?? bookData?['title'] ?? _titleController.text,
            author: bookData?['b_author'] ?? bookData?['author'] ?? _authorController.text,
            genre: bookData?['b_genre'] ?? bookData?['genre'] ?? _genreController.text,
            count: int.tryParse((bookData?['b_available_count'] ?? 
                                bookData?['b_count'] ?? 
                                bookData?['count'] ?? 1).toString()) ?? 1,
          );

          print('Created book object: ${book.title} by ${book.author}, ID: ${book.id}');

          // Validate book ID
          if (book.id.isEmpty) {
            print('ERROR: Book ID is empty after extraction');
            print('BookData keys: ${bookData?.keys}');
            print('Result keys: ${result.keys}');
            throw Exception('पुस्तक ID प्राप्त नहीं हुई API से। कृपया पुनः प्रयास करें।');
          }

          // Add to available books list
          setState(() {
            _availableBooks.add(book);
            _isLoading = false;
          });

          Navigator.pop(context);
          _clearBookForm();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('नई पुस्तक सफलतापूर्वक जोड़ी गई'),
              backgroundColor: Colors.green,
            ),
          );

          // Now show count dialog for this new book
          _showBookCountDialog(book);
        } else {
          setState(() {
            _isLoading = false;
          });
          
          final errorMessage = result?['message'] ?? 'Unknown error';
          print('API returned success=false: $errorMessage');
          print('Full result: $result');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('पुस्तक जोड़ने में त्रुटि: $errorMessage'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        print('Error in _addNewBook: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('त्रुटि: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearBookForm() {
    _titleController.clear();
    _authorController.clear();
    _genreController.clear();
  }

  // Image Compression Function
  Future<File> _compressImage(File imageFile) async {
    print('=== COMPRESSING IMAGE ===');
    print('Original file path: ${imageFile.path}');
    
    try {
      // Read original image file
      final bytes = await imageFile.readAsBytes();
      final originalSize = bytes.length;
      print('Original size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        print('Failed to decode image');
        return imageFile; // Return original if decoding fails
      }
      
      print('Original dimensions: ${image.width}x${image.height}');
      
      // Resize image if too large (max width/height: 1200px)
      int maxDimension = 1200;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          int newWidth = maxDimension;
          int newHeight = (image.height * maxDimension / image.width).round();
          image = img.copyResize(image, width: newWidth, height: newHeight);
        } else {
          int newHeight = maxDimension;
          int newWidth = (image.width * maxDimension / image.height).round();
          image = img.copyResize(image, width: newWidth, height: newHeight);
        }
        print('Resized dimensions: ${image.width}x${image.height}');
      }
      
      // Compress image with quality 85 (good balance between quality and size)
      final compressedBytes = img.encodeJpg(image, quality: 85);
      final compressedSize = compressedBytes.length;
      print('Compressed size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('Compression ratio: ${((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1)}%');
      
      // Create compressed file in the same directory as original
      final originalPath = imageFile.path;
      final directory = imageFile.parent;
      final filename = originalPath.split('/').last.split('\\').last;
      final nameWithoutExtension = filename.contains('.') 
          ? filename.substring(0, filename.lastIndexOf('.'))
          : filename;
      
      // Create new compressed file path
      final compressedPath = '${directory.path}/compressed_$nameWithoutExtension.jpg';
      final compressedFile = File(compressedPath);
      
      // Write compressed bytes to file
      await compressedFile.writeAsBytes(compressedBytes);
      
      print('Compressed file saved at: $compressedPath');
      
      // Delete original file to save space
      try {
        await imageFile.delete();
        print('Original file deleted');
      } catch (e) {
        print('Warning: Could not delete original file: $e');
      }
      
      return compressedFile;
      
    } catch (e) {
      print('Error in image compression: $e');
      return imageFile; // Return original file if compression fails
    }
  }

  Future<void> _pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90, // Initial quality setting
    );
    
    if (image != null) {
      try {
        print('=== PROCESSING PICKED IMAGE ===');
        final originalFile = File(image.path);
        
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('फोटो compress हो रहा है...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Compress the image
        final compressedFile = await _compressImage(originalFile);
        
        setState(() {
          _certificateImage = compressedFile;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('फोटो सफलतापूर्वक compress हो गया'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
      } catch (e) {
        print('Error compressing image: $e');
        // If compression fails, use original file
        setState(() {
          _certificateImage = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('फोटो compression में त्रुटि, original फोटो का उपयोग किया जा रहा है'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _submitDonation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get donor ID (either created or selected)
      final donorId = _isNewUser ? _createdDonorId : _selectedUser?.id;
      
      if (donorId == null) {
        throw Exception('दानकर्ता ID उपलब्ध नहीं है');
      }

      print('=== SUBMITTING DONATION ===');
      print('Donor ID: $donorId');
      print('Librarian ID: ${authProvider.librarianId}');
      print('Certificate Path: $_uploadedCertificatePath');

      // Prepare books data
      final booksData = _selectedBooks.map((bookData) {
        final book = bookData['book'] as Book;
        final count = bookData['count'] as int;
        
        // Validate book ID
        if (book.id.isEmpty) {
          throw Exception('पुस्तक ID गुम है: ${book.title}');
        }
        
        return {
          'book_id': book.id,
          'count': count,
        };
      }).toList();

      print('Books data: $booksData');

      // Validate all book IDs
      for (var bookData in booksData) {
        if (bookData['book_id'] == null || bookData['book_id'].toString().isEmpty) {
          throw Exception('एक या अधिक पुस्तकों की ID गुम है');
        }
      }

      // Submit donation
      final donationResult = await apiService.addDonation(
        donorId: donorId,
        librarianId: authProvider.librarianId ?? '',
        books: booksData,
        certificatePath: _uploadedCertificatePath,
      );

      print('Donation result: $donationResult');

      if (donationResult != null && donationResult['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('दान सफलतापूर्वक सबमिट किया गया'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } else {
        final errorMessage = donationResult?['message'] ?? 'Unknown error';
        throw Exception('दान सबमिट करने में त्रुटि: $errorMessage');
      }
    } catch (e) {
      print('Error in _submitDonation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('त्रुटि: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _searchMobileController.dispose();
    _searchBookController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    super.dispose();
  }
}
