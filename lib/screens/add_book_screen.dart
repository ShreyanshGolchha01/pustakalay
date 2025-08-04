import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/library_provider.dart';
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
  
  bool _isNewUser = true;
  User? _selectedUser;
  final List<Book> _addedBooks = [];
  File? _certificateImage;
  bool _isLoading = false;

  // Book form controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _countController = TextEditingController();
  final _isbnController = TextEditingController();

  final List<String> _commonGenres = [
    'धर्म', 'राजनीति', 'इतिहास', 'साहित्य', 'विज्ञान', 
    'कानूनी', 'उपन्यास', 'कहानी', 'काव्य', 'नाटक', 'जीवनी', 'दर्शन'
  ];

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
                        if (_selectedUser != null || _isNewUser) ...[
                          SizedBox(height: 24),
                          _buildUserDetailsSection(),
                          SizedBox(height: 24),
                          _buildBooksSection(),
                          SizedBox(height: 24),
                          _buildCertificateSection(),
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
                Text(
                  'Add Book Donation',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
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
    if (!_isNewUser && _selectedUser != null) return SizedBox.shrink();
    
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
            decoration: InputDecoration(
              labelText: 'मोबाइल नंबर *',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया मोबाइल नंबर दर्ज करें';
              }
              if (value.length != 10) {
                return 'कृपया 10 अंक का मोबाइल नंबर दर्ज करें';
              }
              return null;
            },
          ),
        ],
      ),
    );
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
                'पुस्तकें जोड़ें',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddBookDialog,
                icon: Icon(Icons.add, size: 16),
                label: Text('जोड़ें'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_addedBooks.isEmpty)
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
                    'अभी तक कोई पुस्तक नहीं जोड़ी गई',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _addedBooks.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;
                return _buildBookItem(book, index);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBookItem(Book book, int index) {
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
                  '${book.author} • ${book.genre} • ${book.count} प्रतियां',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _addedBooks.removeAt(index);
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
          if (_certificateImage == null)
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
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = (_isNewUser || _selectedUser != null) && 
                     _addedBooks.isNotEmpty;
    
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
                  Text('सबमिट हो रहा है...'),
                ],
              )
            : Text(
                'दान सबमिट करें',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }

  void _searchUser() {
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final user = libraryProvider.findUserByMobile(_searchMobileController.text);
    
    setState(() {
      _selectedUser = user;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('इस मोबाइल नंबर के साथ कोई उपयोगकर्ता नहीं मिला'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAddBookDialog() {
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'प्रतियों की संख्या *',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया संख्या दर्ज करें';
                    }
                    final count = int.tryParse(value);
                    if (count == null || count <= 0) {
                      return 'कृपया वैध संख्या दर्ज करें';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(
                    labelText: 'ISBN नंबर *',
                    prefixIcon: Icon(Icons.qr_code),
                    hintText: '978-81-XXXX-XXX-X',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया ISBN नंबर दर्ज करें';
                    }
                    // Basic ISBN format validation
                    final isbnPattern = RegExp(r'^[0-9\-]+$');
                    if (!isbnPattern.hasMatch(value)) {
                      return 'कृपया वैध ISBN नंबर दर्ज करें';
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
                        onPressed: _addBook,
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

  void _addBook() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        count: int.parse(_countController.text),
        isbn: _isbnController.text,
      );

      setState(() {
        _addedBooks.add(book);
      });

      Navigator.pop(context);
      _clearBookForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('पुस्तक सफलतापूर्वक जोड़ी गई'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearBookForm() {
    _titleController.clear();
    _authorController.clear();
    _genreController.clear();
    _countController.clear();
    _isbnController.clear();
  }

  Future<void> _pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _certificateImage = File(image.path);
      });
    }
  }

  Future<void> _submitDonation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
      
      User user;
      if (_isNewUser) {
        user = User(
          name: _nameController.text,
          mobileNumber: _mobileController.text,
        );
        await libraryProvider.addUser(user);
      } else {
        user = _selectedUser!;
      }

      final donation = Donation(
        userId: user.id,
        books: _addedBooks,
        certificateImagePath: _certificateImage?.path,
      );

      await libraryProvider.addDonation(donation);
      await libraryProvider.addBooks(_addedBooks);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('दान सफलतापूर्वक सबमिट किया गया'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
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
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _countController.dispose();
    _isbnController.dispose();
    super.dispose();
  }
}
