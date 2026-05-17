import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  File? _backgroundImage;
  String userName = 'Welcome Back';
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (!mounted || image == null) return;

                    setState(() => _profileImage = File(image.path));

                    Navigator.pop(context);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (!mounted || image == null) return;

                    setState(() => _profileImage = File(image.path));

                    Navigator.pop(context);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.green),
                      SizedBox(height: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Background Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.camera, // ya gallery
                    );

                    if (!mounted || image == null) return;

                    setState(() => _backgroundImage = File(image.path));

                    Navigator.pop(context);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (!mounted || image == null) return;

                    setState(() => _backgroundImage = File(image.path));

                    Navigator.pop(context);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.green),
                      SizedBox(height: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 2, 242, 202),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background Image Section
            GestureDetector(
              onTap: _pickBackgroundImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: _backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(_backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _backgroundImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add background image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Profile Image and User Name Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepPurple, width: 3),
                        color: Colors.grey[300],
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(_profileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 35,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            final controller = TextEditingController(
                              text: userName,
                            );
                            return AlertDialog(
                              title: const Text('Edit Username'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Enter new username',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => userName = controller.text);
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildProfileDetail(
                          Icons.email,
                          'Email',
                          'user@example.com',
                        ),
                        const Divider(),
                        _buildProfileDetail(
                          Icons.phone,
                          'Phone',
                          '+1 (555) 000-0000',
                        ),
                        const Divider(),
                        _buildProfileDetail(
                          Icons.location_on,
                          'Address',
                          'Your City, Country',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
