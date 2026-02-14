import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/track.dart';
import '../../../core/models/deck_state.dart';
import '../../../core/services/library_service.dart';
import '../../deck/providers/deck_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/track_list_item.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/empty_library_widget.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure LibraryProvider is available (it's not in main.dart yet, but we will add it).
    // Or we can provide it here if it's scoped. But typically library is global.
    // Assuming we'll add it to main.dart.

    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E27),
          appBar: AppBar(
            title: const Text('Music Library'),
            backgroundColor: const Color(
              0xFF0A0E27,
            ), // Match scaffold background or slightly lighter
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Sort menu
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                color: const Color(0xFF1A1F3A),
                onSelected: (option) {
                  libraryProvider.setSortOption(option);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: SortOption.title,
                    child: Text(
                      'Sort by Title',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: SortOption.artist,
                    child: Text(
                      'Sort by Artist',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: SortOption.dateAdded,
                    child: Text(
                      'Sort by Date Added',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: SortOption.bpm,
                    child: Text(
                      'Sort by BPM',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBarWidget(
                  onSearch: (query) {
                    libraryProvider.searchTracks(query);
                  },
                ),
              ),

              // Track list
              Expanded(child: _buildTrackList(context, libraryProvider)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              try {
                await libraryProvider.importTracks();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tracks imported successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to import tracks')),
                  );
                }
              }
            },
            label: const Text(
              'Import Tracks',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.library_music, color: Colors.black),
            backgroundColor: const Color(0xFF00D9FF),
          ),
        );
      },
    );
  }

  Widget _buildTrackList(BuildContext context, LibraryProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF00D9FF)),
        ),
      );
    }

    if (provider.tracks.isEmpty) {
      return EmptyLibraryWidget(
        onImport: () async {
          await provider.importTracks();
        },
      );
    }

    return ListView.builder(
      itemCount: provider.tracks.length,
      itemBuilder: (context, index) {
        final track = provider.tracks[index];
        return TrackListItem(
          track: track,
          onTap: () => _showDeckSelectionSheet(context, track),
          onDelete: () => _confirmDelete(context, track),
        );
      },
    );
  }

  void _showDeckSelectionSheet(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.album, color: Color(0xFF00D9FF)),
                title: const Text(
                  'Load to Deck A',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final deckProvider = context.read<DeckProvider>();
                  deckProvider.loadTrackToDeck(DeckSide.A, track);
                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Return to DJ screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.album, color: Color(0xFFFF8000)),
                title: const Text(
                  'Load to Deck B',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final deckProvider = context.read<DeckProvider>();
                  deckProvider.loadTrackToDeck(DeckSide.B, track);
                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Return to DJ screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          title: const Text(
            'Delete Track?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${track.title}"? '
            'This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final provider = context.read<LibraryProvider>();
                await provider.deleteTrack(track);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Track deleted')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
