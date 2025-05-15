import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function toggleTheme;
  
  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<List<Movie>> futureMovies;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 0;
  late TabController _tabController;
  List<Movie> _featuredMovies = [];

  @override
  void initState() {
    super.initState();
    futureMovies = apiService.getMovies();
    _tabController = TabController(length: 3, vsync: this);
    
    // Get featured movies for carousel
    futureMovies.then((movies) {
      if (movies.isNotEmpty) {
        setState(() {
          _featuredMovies = movies.where((m) => m.rating >= 4.0).take(5).toList();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: VStack([
              "Filter Movies".text.xl2.bold.make().p16(),
              const Divider(),
              
              VStack([
                "Genre".text.bold.make(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    "Action", "Comedy", "Drama", "Sci-Fi", "Horror", "Romance"
                  ].map((genre) => FilterChip(
                    label: genre.text.make(),
                    selected: false,
                    onSelected: (bool selected) {},
                  )).toList(),
                ),
              ]).p16(),
              
              VStack([
                "Rating".text.bold.make(),
                const SizedBox(height: 8),
                RangeSlider(
                  values: const RangeValues(0, 5),
                  max: 5,
                  divisions: 10,
                  labels: const RangeLabels('0', '5'),
                  onChanged: (RangeValues values) {},
                ),
              ]).p16(),
              
              VStack([
                "Release Year".text.bold.make(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    "2023", "2022", "2021", "2020", "2019", "Older"
                  ].map((year) => ChoiceChip(
                    label: year.text.make(),
                    selected: false,
                    onSelected: (bool selected) {},
                  )).toList(),
                ),
              ]).p16(),
              
              HStack([
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: "Reset".text.make(),
                ).expand(),
                16.widthBox,
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: "Apply".text.make(),
                ).expand(),
              ]).p16(),
            ]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(colorScheme),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          VxToast.show(context, msg: "Feature coming soon!");
        },
        tooltip: 'Find nearby theaters',
        child: const Icon(Icons.theaters),
      ),
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: "Movie App".text.xl.make(),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search movies',
          onPressed: () {
            showSearch(
              context: context,
              delegate: MovieSearchDelegate(apiService),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter movies',
          onPressed: _showFilterBottomSheet,
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.light 
                ? Icons.dark_mode 
                : Icons.light_mode,
          ),
          tooltip: 'Toggle theme',
          onPressed: () => widget.toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          tooltip: 'Admin panel',
          onPressed: () {
            Navigator.pushNamed(context, '/admin');
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: "Now Playing"),
          Tab(text: "Popular"),
          Tab(text: "Top Rated"),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return VStack([
      // Featured movies carousel
      if (_featuredMovies.isNotEmpty)
        VStack([
          HStack([
            "Featured Movies".text.xl.bold.make().expand(),
            "See all".text.color(Theme.of(context).colorScheme.primary).make().onTap(() {
              // Handle see all
            }),
          ]).px16().py8(),
          
          // Custom Carousel Implementation
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.8),
              itemCount: _featuredMovies.length,
              itemBuilder: (context, index) {
                final movie = _featuredMovies[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => _navigateToDetail(context, movie.id),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: movie.posterUrl != null
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
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: movie.title.text.white.bold.make(),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: HStack([
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              4.widthBox,
                              movie.rating.toStringAsFixed(1).text.white.make(),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMoviesTab('now_playing'),
            _buildMoviesTab('popular'),
            _buildMoviesTab('top_rated'),
          ],
        ),
      ),
    ]);
  }
  
  Widget _buildMoviesTab(String category) {
    return FutureBuilder<List<Movie>>(
      future: futureMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else if (snapshot.hasError) {
          return ErrorMessage(error: snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateMessage();
        } else {
          return _buildMovieGrid(snapshot.data!);
        }
      },
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(movie: movie);
      },
    );
  }
  
  void _navigateToDetail(BuildContext context, int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movieId),
      ),
    );
  }
  
  Widget _buildBottomNavigation(ColorScheme colorScheme) {
    return NavigationBar(
      selectedIndex: _currentNavIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentNavIndex = index;
        });
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.movie_outlined),
          selectedIcon: Icon(Icons.movie),
          label: 'Movies',
        ),
        const NavigationDestination(
          icon: Icon(Icons.tv_outlined),
          selectedIcon: Icon(Icons.tv),
          label: 'TV Shows',
        ),
        const NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorites',
          ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final ApiService apiService;
  
  MovieSearchDelegate(this.apiService);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(child: "Enter a search term".text.make());
    }
    
    return FutureBuilder<List<Movie>>(
      future: apiService.getMovies(), // Should be apiService.searchMovies(query)
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else if (snapshot.hasError) {
          return ErrorMessage(error: snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: "No movies found for '$query'".text.make(),
          );
        } else {
          // Filter movies by query
          final filteredMovies = snapshot.data!
              .where((movie) => movie.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
          
          if (filteredMovies.isEmpty) {
            return Center(
              child: "No movies found for '$query'".text.make(),
            );
          }
          
          return ListView.builder(
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              final movie = filteredMovies[index];
              return ListTile(
                leading: movie.posterUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          movie.posterUrl!,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 75,
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 30),
                          ),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 75,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 30),
                      ),
                title: movie.title.text.make(),
                subtitle: "${movie.releaseYear} • ${movie.rating.toStringAsFixed(1)}★".text.make(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(movieId: movie.id),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return VStack([
        "Popular Searches".text.xl.bold.make().p16(),
        ListView(
          shrinkWrap: true,
          children: [
            "Action Movies",
            "Latest Releases",
            "Top Rated Movies",
            "Oscar Winners"
          ].map((suggestion) => ListTile(
            leading: const Icon(Icons.history),
            title: suggestion.text.make(),
            onTap: () {
              query = suggestion;
              showResults(context);
            },
          )).toList(),
        ),
      ]);
    }
    
    return buildResults(context);
  }
}

// Widget for Loading
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10,
        itemBuilder: (_, __) => Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// Widget for error messages
class ErrorMessage extends StatelessWidget {
  final Object? error;
  
  const ErrorMessage({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VStack([
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        16.heightBox,
        "Error: $error".text.make(),
        16.heightBox,
        ElevatedButton.icon(
          onPressed: () {
            // Implement refresh functionality
          },
          icon: const Icon(Icons.refresh),
          label: "Try Again".text.make(),
        ),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }
}

// Widget for empty state
class EmptyStateMessage extends StatelessWidget {
  const EmptyStateMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VStack([
        const Icon(Icons.movie_filter, size: 64, color: Colors.grey),
        16.heightBox,
        "No movies available".text.xl.make(),
        8.heightBox,
        "Check back later for updates".text.gray500.make(),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }
}

// Widget for movie cards
class MovieCard extends StatelessWidget {
  final Movie movie;
  
  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      onLongPress: () => _showQuickInfo(context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: VStack([
          _buildPosterImage(),
          _buildMovieInfo(context),
        ]),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movie.id),
      ),
    );
  }
  
  void _showQuickInfo(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: movie.title.text.make(),
        content: VStack([
          if (movie.posterUrl != null)
            Image.network(
              movie.posterUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          16.heightBox,
          "Year: ${movie.releaseYear}".text.make(),
          "Rating: ${movie.rating.toStringAsFixed(1)}".text.make(),
          16.heightBox,
          RatingBar.builder(
            initialRating: movie.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 20,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              // Store user rating
            },
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: "Close".text.make(),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDetail(context);
            },
            child: "Details".text.make(),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterImage() {
    return Hero(
      tag: 'movie-poster-${movie.id}',
      child: AspectRatio(
        aspectRatio: 2/3,
        child: movie.posterUrl != null
            ? Image.network(
                movie.posterUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
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
      ),
    );
  }

  Widget _buildMovieInfo(BuildContext context) {
    return VStack([
      Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        child: movie.title.text.medium.ellipsis.make(),
      ),
      HStack([
        const Icon(Icons.star, color: Colors.amber, size: 16),
        4.widthBox,
        movie.rating.toStringAsFixed(1).text.make(),
        8.widthBox,
        movie.releaseYear.toString().text.make(),
      ]).px12().py8(),
    ]);
  }
} 