import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../models/team.dart';

class TeamFormScreen extends StatefulWidget {
  final Team? team;

  const TeamFormScreen({super.key, this.team});

  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _imageFile;
  String? _logoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.team != null) {
      _nameController.text = widget.team!.name;
      _logoUrl = widget.team!.logoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _logoUrl = null;
      });
    }
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    String? uploadedImageUrl = _logoUrl;

    // TODO: Upload image to Firebase Storage

    try {
      if (widget.team == null) {
        await teamProvider.addTeam(_nameController.text.trim(), uploadedImageUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('Tim berhasil ditambahkan!'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        await teamProvider.updateTeam(
            widget.team!.id, _nameController.text.trim(), uploadedImageUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('Tim berhasil diperbarui!'),
                ],
              ),
              backgroundColor: const Color(0xFF1565C0),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFB00020),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ImageProvider? _getImageProvider() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (_logoUrl != null && _logoUrl!.isNotEmpty) return NetworkImage(_logoUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.team != null;

    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1020),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.25),
              ),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Tim' : 'Tambah Tim',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37).withOpacity(0.15),
                            const Color(0xFF1A3A6B).withOpacity(0.3),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.4),
                          width: 2,
                        ),
                        image: _getImageProvider() != null
                            ? DecorationImage(
                          image: _getImageProvider()!,
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _getImageProvider() == null
                          ? Icon(
                        Icons.add_a_photo_rounded,
                        size: 36,
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                      )
                          : null,
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Color(0xFF0A0E1A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap untuk pilih logo tim',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 36),

              // Name field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tim tidak boleh kosong';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Nama Tim',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F1829),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFB00020)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFFB00020), width: 1.5),
                  ),
                  errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                ),
              ),
              const SizedBox(height: 36),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _isLoading
                    ? const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37),
                      strokeWidth: 2.5,
                    ),
                  ),
                )
                    : DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveTeam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH TIM',
                      style: const TextStyle(
                        color: Color(0xFF0A0E1A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
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
}