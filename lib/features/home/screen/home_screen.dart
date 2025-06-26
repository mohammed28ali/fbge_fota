import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';

import 'package:fota_uploader/core/utils/app_colors.dart';

class FPGAFOTAUploaderScreen extends StatefulWidget {
  @override
  _FPGAFOTAUploaderScreenState createState() => _FPGAFOTAUploaderScreenState();
}

class _FPGAFOTAUploaderScreenState extends State<FPGAFOTAUploaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  dynamic _selectedFile;
  String _selectedFileName = '';
  bool _isUploading = false;
  bool _isCompleted = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bit', 'bin', 'hex', 'mcs', 'rbf'],
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _selectedFile = result.files.single;
          _selectedFileName = result.files.single.name;
          _isCompleted = false;
        });
      } else {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
          _isCompleted = false;
        });
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparing upload...';
    });

    try {
      final fileName =
          'fpga_firmware/${DateTime.now().millisecondsSinceEpoch}_$_selectedFileName';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      Uint8List data;
      if (kIsWeb) {
        data = (_selectedFile as PlatformFile).bytes!;
      } else {
        data = await (_selectedFile as File).readAsBytes();
      }

      final uploadTask = storageRef.putData(data);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
          _uploadStatus = 'Uploading... ${(progress * 100).toInt()}%';
        });
        _progressController.animateTo(progress);
      });

      await uploadTask;

      setState(() {
        _isUploading = false;
        _isCompleted = true;
        _uploadStatus = 'Upload completed successfully!';
      });

      _scaleController.reset();
      _scaleController.forward();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor,
              AppColors.primaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondaryColor.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.memory,
                          color: AppColors.secondaryColor,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FPGA FOTA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Firmware Over The Air',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // Upload Area
                  Expanded(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        child: DottedBorder(
                          options: RectDottedBorderOptions(
                            dashPattern: [10, 5],
                            strokeWidth: 2,

                            padding: EdgeInsets.all(16),
                            color: _isCompleted
                                ? Color(0xFF00FF88)
                                : _isUploading
                                ? Color(0xFFFF6B35)
                                : AppColors.secondaryColor,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _isCompleted
                                  ? Color(0xFF00FF88).withValues(alpha: 0.05)
                                  : _isUploading
                                  ? Color(0xFFFF6B35).withValues(alpha: 0.05)
                                  : AppColors.secondaryColor.withValues(
                                      alpha: 0.05,
                                    ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Upload Icon/Animation
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isCompleted
                                        ? Color(
                                            0xFF00FF88,
                                          ).withValues(alpha: 0.1)
                                        : _isUploading
                                        ? Color(
                                            0xFFFF6B35,
                                          ).withValues(alpha: 0.1)
                                        : AppColors.secondaryColor.withValues(
                                            alpha: 0.1,
                                          ),
                                    border: Border.all(
                                      color: _isCompleted
                                          ? Color(0xFF00FF88)
                                          : _isUploading
                                          ? Color(0xFFFF6B35)
                                          : AppColors.secondaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _isCompleted
                                        ? Icons.check_circle_outline
                                        : _isUploading
                                        ? Icons.cloud_upload
                                        : Icons.cloud_upload_outlined,
                                    size: 48,
                                    color: _isCompleted
                                        ? Color(0xFF00FF88)
                                        : _isUploading
                                        ? Color(0xFFFF6B35)
                                        : AppColors.secondaryColor,
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Status Text
                                Text(
                                  _isCompleted
                                      ? 'Upload Completed!'
                                      : _isUploading
                                      ? 'Uploading Firmware...'
                                      : _selectedFileName != null
                                      ? 'Ready to Upload'
                                      : 'Drop your firmware file here',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _uploadStatus.isNotEmpty
                                      ? _uploadStatus
                                      : 'Supported formats: .bit, .bin, .hex, .mcs, .rbf',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 32),

                                // Selected File Info
                                if (_selectedFileName != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.file_present,
                                          color: AppColors.secondaryColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _selectedFileName!,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Progress Bar
                                if (_isUploading)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 8,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: _uploadProgress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.secondaryColor,
                                                    AppColors.secondaryColor,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${(_uploadProgress * 100).toInt()}%',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.secondaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppColors.secondaryColor,
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Select File',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_selectedFile != null && !_isUploading)
                              ? _uploadFile
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isUploading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else
                                Icon(Icons.upload, size: 20),
                              SizedBox(width: 8),
                              Text(
                                _isUploading ? 'Uploading...' : 'Upload',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
