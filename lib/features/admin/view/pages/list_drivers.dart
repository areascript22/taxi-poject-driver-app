import 'package:driver_app/features/admin/view/widgets/driver_tile.dart';
import 'package:driver_app/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ListDriversPage extends StatefulWidget {
  const ListDriversPage({super.key});

  @override
  _ListDriversPageState createState() => _ListDriversPageState();
}

class _ListDriversPageState extends State<ListDriversPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AdminViewModel adminViewModelToDispose;

  bool _hasMore = true;

  bool _notFound = false;

  DocumentSnapshot? _lastDocument;
  final int _limit = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final adminViewModel =
            Provider.of<AdminViewModel>(context, listen: false);
        adminViewModelToDispose = adminViewModel;
        _loadMore();
        _scrollController.addListener(() {
          //Clear search bar
          adminViewModel.isSearching = false;
          if (_scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent - 200 &&
              !adminViewModel.loading &&
              _hasMore &&
              !adminViewModel.isSearching) {
            _loadMore();
          }
        });
      },
    );
  }

  Future<void> _loadMore() async {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);

    adminViewModel.loading = true;
    adminViewModel.isSearching = false;
    Query query = FirebaseFirestore.instance
        .collection('g_user')
        .where('role', arrayContains: 'driver')
        .orderBy('name')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;

    if (docs.length < _limit) {
      _hasMore = false;
    }

    if (docs.isNotEmpty) {
      _lastDocument = docs.last;
      adminViewModel.addDocuments(docs);
    }

    adminViewModel.loading = false;
  }

  Future<void> _performSearch(BuildContext context) async {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);
    FocusScope.of(context).unfocus();
    final code = _searchController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      adminViewModel.isSearching = true;
      _notFound = false;
    });
    adminViewModel.clearSearchResults();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('g_user')
          .where('role', arrayContains: 'driver')
          .where('vehicle.taxiCode', isEqualTo: code)
          .get();

      final results = querySnapshot.docs;
      adminViewModel.addsearchResults(results);
      setState(() {
        _notFound = results.isEmpty;
      });
    } catch (e) {
      print('Error al buscar: $e');
      setState(() => _notFound = true);
    }
  }

  void _clearSearch() {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);
    adminViewModel.isSearching = false;
    setState(() {
      _searchController.clear();
      _notFound = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    adminViewModelToDispose.documents.clear();
    adminViewModelToDispose.searchResults.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);
    final dataToShow = adminViewModel.isSearching
        ? adminViewModel.searchResults
        : adminViewModel.documents;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar por Código de taxi',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(context),
          ),
          if (adminViewModel.isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: _notFound
          ? const Center(
              child: Text('No se encontró un usuario con este código'),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: dataToShow.length +
                  (adminViewModel.loading && !adminViewModel.isSearching
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == dataToShow.length && !adminViewModel.isSearching) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  );
                }
                return DriverTile(
                  driver: dataToShow[index],
                  indexInArray: index,
                );
              },
            ),
    );
  }
}
