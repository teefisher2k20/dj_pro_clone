import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TrackLoader extends StatelessWidget {
  final Function(String trackName, String source) onTrackLoaded;
  final Color color;

  const TrackLoader({
    required this.onTrackLoaded,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLoadOptions(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          children: [
            Icon(Icons.music_note, size: 16, color: color),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tap to load track...',
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  void _showLoadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Load Track',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildOption(
              context,
              icon: Icons.folder_open,
              label: 'Local Storage',
              onTap: () => _pickLocalFile(context),
            ),
            const Divider(color: Colors.grey),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Streaming Services',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildOption(
              context,
              icon: Icons.music_note, // Placeholder for Spotify icon
              label: 'Spotify',
              onTap: () => _mockServiceLoad(context, 'Spotify'),
            ),
            _buildOption(
              context,
              icon: Icons.apple,
              label: 'Apple Music',
              onTap: () => _mockServiceLoad(context, 'Apple Music'),
            ),
            _buildOption(
              context,
              icon: Icons.cloud,
              label: 'SoundCloud',
              onTap: () => _mockServiceLoad(context, 'SoundCloud'),
            ),
            _buildOption(
              context,
              icon: Icons.waves,
              label: 'Tidal',
              onTap: () => _mockServiceLoad(context, 'Tidal'),
            ),
            _buildOption(
              context,
              icon: Icons.album,
              label: 'Beatport',
              onTap: () => _mockServiceLoad(context, 'Beatport'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _pickLocalFile(BuildContext context) async {
    Navigator.pop(context); // Close sheet
    
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        // On web, path might be null, use name
        final fileName = result.files.single.name;
        onTrackLoaded(fileName, 'Local');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _mockServiceLoad(BuildContext context, String serviceName) {
    Navigator.pop(context); // Close sheet
    
    // Simulate loading delay
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to $serviceName...')),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        onTrackLoaded('Top Hit from $serviceName', serviceName);
      }
    });
  }
}
