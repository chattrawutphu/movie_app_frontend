import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class EditMovieScreen extends StatefulWidget {
  final Movie? movie;

  const EditMovieScreen({Key? key, this.movie}) : super(key: key);

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _releaseYearController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _castController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _titleController.text = widget.movie!.title;
      _descriptionController.text = widget.movie!.description;
      _releaseYearController.text = widget.movie!.releaseYear.toString();
      _durationController.text = widget.movie!.duration.toString();
      _genreController.text = widget.movie!.genre;
      _directorController.text = widget.movie!.director ?? '';
      _castController.text = widget.movie!.cast ?? '';
      _ratingController.text = widget.movie!.rating.toString();
      _posterUrlController.text = widget.movie!.posterUrl ?? '';
    } else {
      _ratingController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _releaseYearController.dispose();
    _durationController.dispose();
    _genreController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _ratingController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final movieData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'releaseYear': int.parse(_releaseYearController.text),
          'duration': int.parse(_durationController.text),
          'genre': _genreController.text,
          'director': _directorController.text.isEmpty ? null : _directorController.text,
          'cast': _castController.text.isEmpty ? null : _castController.text,
          'rating': double.parse(_ratingController.text),
          'posterUrl': _posterUrlController.text.isEmpty ? null : _posterUrlController.text,
        };

        if (widget.movie != null) {
          await apiService.updateMovie(widget.movie!.id, movieData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movie updated successfully')),
            );
          }
        } else {
          await apiService.createMovie(movieData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movie created successfully')),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving movie: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie != null ? 'Edit Movie' : 'Add Movie'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _releaseYearController,
                            decoration: const InputDecoration(
                              labelText: 'Release Year',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final year = int.tryParse(value);
                              if (year == null || year < 1900 || year > 2100) {
                                return 'Invalid year';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Duration (min)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final duration = int.tryParse(value);
                              if (duration == null || duration <= 0) {
                                return 'Invalid duration';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genreController,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a genre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _directorController,
                      decoration: const InputDecoration(
                        labelText: 'Director (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _castController,
                      decoration: const InputDecoration(
                        labelText: 'Cast (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating (0-10)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 10) {
                          return 'Rating must be between 0 and 10';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _posterUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Poster URL (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveMovie,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.movie != null ? 'Update Movie' : 'Add Movie',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 