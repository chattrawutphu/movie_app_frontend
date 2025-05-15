import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'edit_movie_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<List<Movie>> futureMovies;
  late TabController _tabController;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _refreshMovies();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshMovies() {
    setState(() {
      futureMovies = apiService.getMovies();
    });
  }

  Future<void> _deleteMovie(int id) async {
    try {
      await apiService.deleteMovie(id);
      VxToast.show(
        context,
        msg: 'Movie deleted successfully',
        bgColor: Colors.green,
        textColor: Colors.white,
        position: VxToastPosition.top,
      );
      _refreshMovies();
    } catch (e) {
      VxToast.show(
        context,
        msg: 'Error deleting movie: $e',
        bgColor: Colors.red,
        textColor: Colors.white,
        position: VxToastPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: "Admin Dashboard".text.xl.make(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search movies',
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: 'Toggle view',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh data',
            onPressed: _refreshMovies,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Movies"),
            Tab(text: "Stats"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoviesTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditMovieScreen(),
            ),
          );
          if (result == true) {
            _refreshMovies();
          }
        },
        icon: const Icon(Icons.add),
        label: "Add Movie".text.make(),
      ),
    );
  }
  
  Widget _buildMoviesTab() {
    return FutureBuilder<List<Movie>>(
      future: futureMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        } else {
          List<Movie> filteredMovies = snapshot.data!;
          
          // Apply search filter if provided
          if (_searchQuery.isNotEmpty) {
            filteredMovies = filteredMovies
                .where((movie) => movie.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }
          
          return _isGridView 
              ? _buildMoviesGrid(filteredMovies)
              : _buildMoviesList(filteredMovies);
        }
      },
    );
  }
  
  Widget _buildStatsTab() {
    return FutureBuilder<List<Movie>>(
      future: futureMovies,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final movies = snapshot.data!;
        final totalMovies = movies.length;
        final avgRating = movies.isNotEmpty 
            ? (movies.map((m) => m.rating).reduce((a, b) => a + b) / totalMovies)
            : 0.0;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: VStack([
            "Movies Statistics".text.xl2.bold.make().py16(),
            
            // Summary cards
            HStack([
              _buildStatCard(
                title: "Total Movies",
                value: "$totalMovies",
                icon: Icons.movie,
                color: Colors.blue,
              ).expand(),
              16.widthBox,
              _buildStatCard(
                title: "Avg Rating",
                value: avgRating.toStringAsFixed(1),
                icon: Icons.star,
                color: Colors.amber,
              ).expand(),
            ]),
            
            24.heightBox,
            
            // Genre distribution
            "Genres Distribution".text.xl.bold.make().py12(),
            VxBox(
              child: VStack([
                _buildGenreBar("Action", 25, Colors.redAccent),
                _buildGenreBar("Comedy", 20, Colors.greenAccent),
                _buildGenreBar("Drama", 30, Colors.blueAccent),
                _buildGenreBar("Sci-Fi", 15, Colors.purpleAccent),
                _buildGenreBar("Romance", 10, Colors.pinkAccent),
              ]).p16(),
            ).rounded.shadowSm.make(),
            
            24.heightBox,
            
            // Rating distribution
            "Rating Distribution".text.xl.bold.make().py12(),
            VxBox(
              child: VStack([
                HStack([
                  "5★".text.make().w(50),
                  LinearProgressIndicator(value: 0.3, minHeight: 10).expand(),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: "30%".text.make(),
                  ),
                ]),
                8.heightBox,
                HStack([
                  "4★".text.make().w(50),
                  LinearProgressIndicator(value: 0.45, minHeight: 10).expand(),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: "45%".text.make(),
                  ),
                ]),
                8.heightBox,
                HStack([
                  "3★".text.make().w(50),
                  LinearProgressIndicator(value: 0.15, minHeight: 10).expand(),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: "15%".text.make(),
                  ),
                ]),
                8.heightBox,
                HStack([
                  "2★".text.make().w(50),
                  LinearProgressIndicator(value: 0.08, minHeight: 10).expand(),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: "8%".text.make(),
                  ),
                ]),
                8.heightBox,
                HStack([
                  "1★".text.make().w(50),
                  LinearProgressIndicator(value: 0.02, minHeight: 10).expand(),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    child: "2%".text.make(),
                  ),
                ]),
              ]).p16(),
            ).rounded.shadowSm.make(),
            
            24.heightBox,
            
            ElevatedButton.icon(
              onPressed: () {
                VxToast.show(
                  context,
                  msg: "Generating report...",
                  showTime: 1000,
                );
              },
              icon: const Icon(Icons.download),
              label: "Export Report".text.make(),
            ).w(double.infinity),
          ]),
        );
      },
    );
  }
  
  Widget _buildGenreBar(String genre, int percentage, Color color) {
    return VStack([
      HStack([
        genre.text.make().expand(),
        "$percentage%".text.make(),
      ]),
      8.heightBox,
      LinearProgressIndicator(
        value: percentage / 100,
        minHeight: 10,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
      16.heightBox,
    ]);
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return VxBox(
      child: VStack([
        HStack([
          Icon(icon, color: color, size: 30),
          8.widthBox,
          title.text.lg.make(),
        ]),
        16.heightBox,
        value.text.xl3.bold.make(),
      ]).p16(),
    ).rounded.shadowSm.make();
  }
  
  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 75,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: VStack([
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        16.heightBox,
        "Error: $error".text.lg.make(),
        16.heightBox,
        ElevatedButton.icon(
          onPressed: _refreshMovies,
          icon: const Icon(Icons.refresh),
          label: "Try Again".text.make(),
        ),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: VStack([
        const Icon(Icons.movie_filter, size: 64, color: Colors.grey),
        16.heightBox,
        "No movies available".text.xl.make(),
        8.heightBox,
        "Click the + button to add a new movie".text.gray500.make(),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }
  
  Widget _buildMoviesList(List<Movie> movies) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshMovies();
      },
      child: ListView.separated(
        itemCount: movies.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: movie.posterUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie.posterUrl!,
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(
                            width: 50,
                            height: 75,
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie),
                          ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 75,
                    color: Colors.grey[300],
                    child: const Icon(Icons.movie),
                  ),
            title: movie.title.text.make(),
            subtitle: HStack([
              "${movie.releaseYear}".text.make(),
              " • ".text.make(),
              movie.genre.text.make(),
              " • ".text.make(),
              "${movie.rating}★".text.make(),
            ]),
            trailing: HStack([
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit movie',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMovieScreen(movie: movie),
                    ),
                  );
                  if (result == true) {
                    _refreshMovies();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete movie',
                color: Colors.red,
                onPressed: () {
                  _showDeleteConfirmation(movie);
                },
              ),
            ]),
          );
        },
      ),
    );
  }
  
  Widget _buildMoviesGrid(List<Movie> movies) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshMovies();
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMovieScreen(movie: movie),
                ),
              );
              if (result == true) {
                _refreshMovies();
              }
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Movie poster
                  movie.posterUrl != null
                      ? Image.network(
                          movie.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie, size: 50),
                              ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie, size: 50),
                        ),
                  
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Movie info
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VStack([
                      movie.title.text.white.bold.size(16).make(),
                      4.heightBox,
                      HStack([
                        "${movie.releaseYear}".text.white.make(),
                        8.widthBox,
                        "${movie.rating}★".text.white.make(),
                      ]),
                    ]).p12(),
                  ),
                  
                  // Delete button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.7),
                      ),
                      onPressed: () {
                        _showDeleteConfirmation(movie);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showDeleteConfirmation(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: "Delete Movie".text.make(),
        content: "Are you sure you want to delete \"${movie.title}\"?".text.make(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: "Cancel".text.make(),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMovie(movie.id);
            },
            child: "Delete".text.color(Colors.red).make(),
          ),
        ],
      ),
    );
  }
  
  void _showSearchDialog() {
    String tempQuery = _searchQuery;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: "Search Movies".text.make(),
        content: TextField(
          onChanged: (value) {
            tempQuery = value;
          },
          decoration: InputDecoration(
            hintText: "Enter movie title",
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            border: const OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _searchQuery),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: "Cancel".text.make(),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = tempQuery;
              });
              Navigator.pop(context);
            },
            child: "Search".text.make(),
          ),
        ],
      ),
    );
  }
} 