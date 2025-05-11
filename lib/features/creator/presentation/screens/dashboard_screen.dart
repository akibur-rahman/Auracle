import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/services/track_service.dart';
import '../../domain/models/track.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatorDashboardScreen extends ConsumerStatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  ConsumerState<CreatorDashboardScreen> createState() =>
      _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState
    extends ConsumerState<CreatorDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _genreController = TextEditingController();
  File? _selectedAudioFile;
  File? _selectedCoverArtFile;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      // For Android, explicitly request permissions before picking files
      if (Platform.isAndroid) {
        // Request permissions explicitly with a dialog
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.audio,
          Permission.photos,
        ].request();

        // Check if any permission was denied
        if (statuses[Permission.storage] != PermissionStatus.granted &&
            statuses[Permission.audio] != PermissionStatus.granted) {
          setState(() {
            _uploadError =
                'Storage permissions are required to pick audio files. Please enable them in app settings.';
          });
          return;
        }
      }

      // Using FileType.custom with allowed extensions for better compatibility
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'flac', 'mov'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedAudioFile = File(file.path!);
            _uploadError = null;
          });
        } else {
          setState(() {
            _uploadError = 'Failed to get file path';
          });
        }
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to pick audio file: $e';
      });
    }
  }

  Future<void> _pickCoverArt() async {
    try {
      // For Android, explicitly request permissions before picking files
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.photos,
          Permission.camera,
        ].request();

        if (statuses[Permission.photos] != PermissionStatus.granted &&
            statuses[Permission.storage] != PermissionStatus.granted) {
          setState(() {
            _uploadError =
                'Photo permissions are required to pick cover art. Please enable them in app settings.';
          });
          return;
        }
      }

      final picker = ImagePicker();
      final result = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (result != null) {
        setState(() {
          _selectedCoverArtFile = File(result.path);
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to pick cover art: $e';
      });
    }
  }

  Future<void> _uploadTrack() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAudioFile == null) {
      setState(() {
        _uploadError = 'Please select an audio file';
      });
      return;
    }
    if (_selectedCoverArtFile == null) {
      setState(() {
        _uploadError = 'Please select a cover art image';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final trackService = ref.read(trackServiceProvider);
      await trackService.uploadTrack(
        audioFile: _selectedAudioFile!,
        coverArtFile: _selectedCoverArtFile!,
        title: _titleController.text,
        artist: _artistController.text,
        genre: _genreController.text,
        album: _albumController.text.isEmpty ? null : _albumController.text,
        userId: userId,
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() {
        _selectedAudioFile = null;
        _selectedCoverArtFile = null;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Track uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to upload track: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userTracks = userId != null
        ? ref.watch(trackServiceProvider).getUserTracks(userId)
        : Stream.value(<Track>[]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Creator Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_uploadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SelectableText.rich(
                          TextSpan(
                            text: 'Error: ',
                            style: const TextStyle(color: Colors.red),
                            children: [
                              TextSpan(
                                text: _uploadError,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    _buildUploadSection(context),
                    const SizedBox(height: 24),
                    _buildMusicDetailsForm(context),
                    const SizedBox(height: 24),
                    _buildUploadButton(context),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Recent Uploads',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Track>>(
                      stream: userTracks,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return SelectableText.rich(
                            TextSpan(
                              text: 'Error: ',
                              style: const TextStyle(color: Colors.red),
                              children: [
                                TextSpan(
                                  text: snapshot.error.toString(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final tracks = snapshot.data!;
                        if (tracks.isEmpty) {
                          return Text(
                            'No tracks uploaded yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey[400]),
                          );
                        }

                        return Column(
                          children: tracks.map((track) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    track.coverArtUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.music_note,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                title: Text(
                                  track.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.artist,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[400],
                                          ),
                                    ),
                                    Text(
                                      '${_formatDate(track.createdAt)} • ${track.playCount} plays',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    // Show options menu
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildUploadSection(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload New Track',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _selectedAudioFile != null
                ? _buildFilePreview(context)
                : _buildFileSelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector(BuildContext context) {
    return GestureDetector(
      onTap: _pickAudioFile,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Select music file',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'MP3, WAV, FLAC, MOV',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.audio_file, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAudioFile?.path.split('/').last ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  '${(_selectedAudioFile?.lengthSync() ?? 0) ~/ 1024} KB',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              setState(() {
                _selectedAudioFile = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMusicDetailsForm(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter track title',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _artistController,
                label: 'Artist',
                hint: 'Enter artist name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _albumController,
                label: 'Album',
                hint: 'Enter album name (optional)',
                icon: Icons.album,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _genreController,
                label: 'Genre',
                hint: 'Enter genre',
                icon: Icons.category,
              ),
              const SizedBox(height: 16),
              _buildCoverArtSelector(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildCoverArtSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Art',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCoverArt,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: _selectedCoverArtFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedCoverArtFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.primary,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select cover image',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPEG, PNG (Recommended: 1000x1000)',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadTrack,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isUploading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            )
          : Text(
              'Upload Track',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
    );
  }
}
