import 'package:flutter/material.dart';

class PlaylistSyncScreen extends StatefulWidget {
  final String? initialSourcePlatform;

  const PlaylistSyncScreen({super.key, this.initialSourcePlatform});

  @override
  State<PlaylistSyncScreen> createState() => _PlaylistSyncScreenState();
}

class _PlaylistSyncScreenState extends State<PlaylistSyncScreen> {
  String _operationType = 'Sync Playlist';
  String? _sourcePlatform;
  String? _targetPlatform;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sourcePlatform = widget.initialSourcePlatform;
  }

  final List<String> _operations = [
    'Sync Playlist',
    'Transfer Playlist',
    'Backup Playlist',
  ];

  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'youtube',
      'name': 'YouTube',
      'icon': Icons.play_arrow,
      'color': Colors.red,
    },
    {
      'id': 'spotify',
      'name': 'Spotify',
      'icon': Icons.circle,
      'color': Colors.green,
    }, // Circle approx Spotify dot
    {
      'id': 'apple',
      'name': 'Apple Music',
      'icon': Icons.music_note,
      'color': Colors.pinkAccent,
    },
    {
      'id': 'tidal',
      'name': 'Tidal',
      'icon': Icons.diamond,
      'color': Colors.black,
    }, // Diamond approx Tidal
    {
      'id': 'local',
      'name': 'Local Storage',
      'icon': Icons.storage,
      'color': Colors.grey,
    },
    {
      'id': 'ytmusic',
      'name': 'YouTube Music',
      'icon': Icons.play_circle_outline,
      'color': Colors.redAccent,
    },
    {
      'id': 'amazon',
      'name': 'Amazon Music',
      'icon': Icons.shopping_cart,
      'color': Colors.blueGrey,
    }, // Approx
    {
      'id': 'soundcloud',
      'name': 'SoundCloud',
      'icon': Icons.cloud,
      'color': Colors.orange,
    },
    {
      'id': 'deezer',
      'name': 'Deezer',
      'icon': Icons.equalizer,
      'color': Colors.purpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Streaming Playlist Sync'),
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner (approximate)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4DFF), Color(0xFF9867FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.sync, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Streaming Playlist Sync',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sync your playlists across YouTube, Spotify, Apple Music, and more using AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Operation Type
            const Text(
              'Operation Type',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2342),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _operationType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E2342),
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                  items: _operations.map((op) {
                    return DropdownMenuItem(value: op, child: Text(op));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _operationType = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Source Platform
            const Text(
              'Source Platform',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            _buildPlatformGrid(
              selectedId: _sourcePlatform,
              onSelect: (id) => setState(() => _sourcePlatform = id),
            ),

            const SizedBox(height: 24),

            // Playlist URL
            const Text(
              'Playlist URL/ID',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter playlist URL or ID',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1E2342),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00D9FF)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Target Platform (for sync)
            const Text(
              'Target Platforms (for sync)',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            _buildPlatformGrid(
              selectedId: _targetPlatform,
              onSelect: (id) => setState(() => _targetPlatform = id),
            ),

            const SizedBox(height: 48),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_sourcePlatform == null || _targetPlatform == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select source and target platforms',
                        ),
                      ),
                    );
                    return;
                  }

                  // Mock Sync Process
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const _SyncProgressDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Start Sync',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformGrid({
    required String? selectedId,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _platforms.map((platform) {
        final isSelected = selectedId == platform['id'];
        return GestureDetector(
          onTap: () => onSelect(platform['id']),
          child: Container(
            width: 100, // Fixed width for consistent grid
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2342),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF00D9FF) : Colors.white10,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(platform['icon'], color: platform['color'], size: 32),
                const SizedBox(height: 8),
                Text(
                  platform['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SyncProgressDialog extends StatefulWidget {
  const _SyncProgressDialog();

  @override
  State<_SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends State<_SyncProgressDialog> {
  double _progress = 0.0;
  String _status = 'Connecting to source...';

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    // 1. Connecting
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _progress = 0.2;
      _status = 'Fetching playlist data...';
    });

    // 2. Fetching
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _progress = 0.5;
      _status = 'Analyzing metadata...';
    });

    // 3. Analyzing
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _progress = 0.8;
      _status = 'Syncing to target...';
    });

    // 4. Finishing
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _status = 'Sync Complete!';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playlist synced successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          CircularProgressIndicator(
            value: _progress,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF00D9FF)),
            backgroundColor: Colors.white10,
          ),
          const SizedBox(height: 24),
          Text(
            _status,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).toInt()}%',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
