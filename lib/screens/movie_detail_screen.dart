import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Movie> futureMovie;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    futureMovie = apiService.getMovie(widget.movieId);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    VxToast.show(
      context, 
      msg: _isFavorite ? "Added to favorites" : "Removed from favorites",
      bgColor: Theme.of(context).colorScheme.primaryContainer,
      textColor: Theme.of(context).colorScheme.onPrimaryContainer,
      position: VxToastPosition.center,
    );
  }

  void _showTrailer() {
    VxToast.show(
      context, 
      msg: "Trailer feature coming soon!",
      position: VxToastPosition.center,
    );
  }

  void _openBookingSheet(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookingBottomSheet(movie: movie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: FutureBuilder<Movie>(
        future: futureMovie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          } else if (!snapshot.hasData) {
            return _buildEmptyState();
          } else {
            final movie = snapshot.data!;
            return _buildMovieDetail(movie, colorScheme);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
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
          onPressed: () {
            setState(() {
              futureMovie = apiService.getMovie(widget.movieId);
            });
          },
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
        "Movie not found".text.xl.make(),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: "Go Back".text.make(),
        ),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }

  Widget _buildMovieDetail(Movie movie, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              tooltip: 'Add to favorites',
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share movie',
              onPressed: () => VxToast.show(context, msg: "Share feature coming soon!"),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'movie-poster-${movie.id}',
              child: movie.posterUrl != null
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 100),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, size: 100),
                    ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: VStack([
            // Movie title and basic info
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: movie.title.text.xl3.bold.make(),
            ),
            
            HStack([
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: movie.genre.text.color(colorScheme.onPrimaryContainer).make(),
              ),
              8.widthBox,
              HStack([
                const Icon(Icons.star, color: Colors.amber, size: 18),
                ' ${movie.rating.toStringAsFixed(1)}'.text.make(),
              ]),
              8.widthBox,
              '${movie.duration} min'.text.make(),
              8.widthBox,
              movie.releaseYear.toString().text.make(),
            ]).px16().py8(),
            
            // Rating bar
            VStack([
              "Rate this movie".text.semiBold.make(),
              8.heightBox,
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  VxToast.show(
                    context, 
                    msg: "You rated this movie $rating stars",
                    position: VxToastPosition.center,
                  );
                },
              ),
            ]).p16().card.elevation(0).color(colorScheme.surfaceVariant).make().p16(),
            
            // Action buttons
            HStack([
              ElevatedButton.icon(
                onPressed: _showTrailer,
                icon: const Icon(Icons.play_arrow),
                label: "Watch Trailer".text.make(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ).expand(),
              16.widthBox,
              OutlinedButton.icon(
                onPressed: () => _openBookingSheet(movie),
                icon: const Icon(Icons.calendar_today),
                label: "Book Tickets".text.make(),
              ).expand(),
            ]).px16(),
            
            // Description
            VStack([
              "Description".text.xl.semiBold.make(),
              12.heightBox,
              movie.description.text.make(),
            ]).p16(),
            
            // Director info
            if (movie.director != null && movie.director!.isNotEmpty)
              VStack([
                "Director".text.xl.semiBold.make(),
                12.heightBox,
                movie.director!.text.make(),
              ]).px16().py8(),
            
            // Cast info
            if (movie.cast != null && movie.cast!.isNotEmpty)
              VStack([
                "Cast".text.xl.semiBold.make(),
                12.heightBox,
                movie.cast!.text.make(),
              ]).px16().py8(),
            
            30.heightBox, // Bottom padding for scroll
          ]),
        ),
      ],
    );
  }
}

class BookingBottomSheet extends StatefulWidget {
  final Movie movie;
  
  const BookingBottomSheet({Key? key, required this.movie}) : super(key: key);

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _dates = ['Today', 'Tomorrow', 'Wed, 15 May', 'Thu, 16 May', 'Fri, 17 May'];
  final List<String> _times = ['10:30 AM', '1:45 PM', '4:30 PM', '7:15 PM', '10:00 PM'];
  String? _selectedDate;
  String? _selectedTime;
  int _quantity = 1;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = _dates[0];
    _selectedTime = _times[0];
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            VxBox(
              child: VStack([
                HStack([
                  "Book Tickets".text.xl2.bold.make().expand(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ]),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Standard"),
                    Tab(text: "IMAX/3D"),
                  ],
                ),
              ]).p12(),
            ).make(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingForm(colorScheme, scrollController),
                  Center(child: "IMAX/3D booking coming soon".text.make()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBookingForm(ColorScheme colorScheme, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Movie info summary
        HStack([
          if (widget.movie.posterUrl != null)
            Image.network(
              widget.movie.posterUrl!,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
            ).cornerRadius(8),
          16.widthBox,
          VStack([
            widget.movie.title.text.xl.bold.make(),
            4.heightBox,
            widget.movie.genre.text.make(),
            4.heightBox,
            "${widget.movie.duration} min • ${widget.movie.releaseYear}".text.make(),
          ]).expand(),
        ]),
        
        24.heightBox,
        
        // Date selection
        "Select Date".text.bold.make(),
        16.heightBox,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dates.map((date) => ChoiceChip(
            label: date.text.make(),
            selected: _selectedDate == date,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          )).toList(),
        ),
        
        24.heightBox,
        
        // Time selection
        "Select Time".text.bold.make(),
        16.heightBox,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _times.map((time) => ChoiceChip(
            label: time.text.make(),
            selected: _selectedTime == time,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
          )).toList(),
        ),
        
        24.heightBox,
        
        // Ticket quantity
        "Number of Tickets".text.bold.make(),
        16.heightBox,
        HStack([
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          ),
          _quantity.toString().text.xl.make(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
          ),
        ]).box.border(color: colorScheme.outlineVariant).p8.roundedSM.make(),
        
        24.heightBox,
        
        // Price summary
        VStack([
          HStack([
            "Tickets".text.make().expand(),
            "₹${(250 * _quantity).toStringAsFixed(2)}".text.make(),
          ]),
          8.heightBox,
          HStack([
            "Convenience Fee".text.make().expand(),
            "₹${(25 * _quantity).toStringAsFixed(2)}".text.make(),
          ]),
          8.heightBox,
          HStack([
            "GST".text.make().expand(),
            "₹${(30 * _quantity).toStringAsFixed(2)}".text.make(),
          ]),
          8.heightBox,
          const Divider(),
          8.heightBox,
          HStack([
            "Total".text.bold.make().expand(),
            "₹${(305 * _quantity).toStringAsFixed(2)}".text.bold.make(),
          ]),
        ]).p16().box.color(colorScheme.surfaceVariant).roundedSM.make(),
        
        24.heightBox,
        
        // Book button
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            VxToast.show(
              context, 
              msg: "Tickets booked successfully!",
              bgColor: Colors.green,
              textColor: Colors.white,
              position: VxToastPosition.top,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: "Book Tickets".text.make(),
        ),
      ],
    );
  }
}