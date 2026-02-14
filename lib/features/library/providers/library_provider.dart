import 'package:flutter/foundation.dart';
import '../../../core/models/track.dart';
import '../../../core/services/library_service.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryService _libraryService = LibraryService();

  List<Track> _tracks = [];
  List<Track> _filteredTracks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  SortOption _sortBy = SortOption.dateAdded;

  List<Track> get tracks => _filteredTracks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  SortOption get sortBy => _sortBy;

  LibraryProvider() {
    _loadTracks();
  }

  // Load tracks from Firestore
  void _loadTracks() {
    _libraryService.getAllTracks().listen((tracks) {
      _tracks = tracks;
      _applyFiltersAndSort();
    });
  }

  // Import new tracks
  Future<void> importTracks() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Tracks automatically added via stream, but import is async
      await _libraryService.importTracks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Search tracks
  void searchTracks(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  // Change sort option
  void setSortOption(SortOption option) {
    _sortBy = option;
    _applyFiltersAndSort();
  }

  // Apply filters and sorting
  void _applyFiltersAndSort() {
    var filtered = List<Track>.from(_tracks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((track) {
        return track.title.toLowerCase().contains(query) ||
            track.artist.toLowerCase().contains(query) ||
            track.album.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    filtered = _libraryService.sortTracks(filtered, _sortBy);

    _filteredTracks = filtered;
    notifyListeners();
  }

  // Delete track
  Future<void> deleteTrack(Track track) async {
    await _libraryService.deleteTrack(track.id);
    // Will update via stream
  }
}
