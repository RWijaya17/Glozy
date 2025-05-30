import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/salon_model.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../booking/booking_form_screen.dart';

class SalonDetailScreen extends StatefulWidget {
  final SalonModel salon;

  const SalonDetailScreen({
    Key? key,
    required this.salon,
  }) : super(key: key);

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user != null) {
      setState(() {
        _isFavorite = user.favorites.contains(widget.salon.id);
      });
    }
  }

  void _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.toggleFavorite(widget.salon.id);

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      Get.snackbar(
        'Success',
        _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: widget.salon.phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone app',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  void _openMaps() async {
    final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.salon.latitude},${widget.salon.longitude}');

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch maps',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Widget _buildImageGallery() {
    final images = [widget.salon.imageUrl, ...widget.salon.images];

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.darkGrey,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.darkGrey,
              child: const Icon(Icons.image_not_supported, size: 48),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.salon.name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: _isFavorite ? AppColors.error : AppColors.grey,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBarIndicator(
                rating: widget.salon.rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: AppColors.secondary,
                ),
                itemCount: 5,
                itemSize: 20,
                direction: Axis.horizontal,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.salon.rating} (${widget.salon.reviewCount} reviews)',
                style: TextStyle(color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.salon.description,
            style: TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: AppColors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.salon.address,
                  style: TextStyle(color: AppColors.text),
                ),
              ),
              TextButton(
                onPressed: _openMaps,
                child: Text('Direction',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 20, color: AppColors.grey),
              const SizedBox(width: 8),
              Text(
                widget.salon.phone,
                style: TextStyle(color: AppColors.text),
              ),
              const Spacer(),
              TextButton(
                onPressed: _makePhoneCall,
                child: Text('Call', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          if (widget.salon.homeService) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.home_outlined, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Home Service Available',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpeningHours() {
    if (widget.salon.openingHours.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opening Hours',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...widget.salon.openingHours.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(color: AppColors.text),
                  ),
                  Text(
                    entry.value,
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildServices() {
    if (widget.salon.services.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.salon.services.length,
            itemBuilder: (context, index) {
              final service = widget.salon.services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (service.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: service.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.darkGrey,
                            child: const Icon(Icons.content_cut,
                                color: AppColors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.description,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: AppColors.grey,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Rp ${service.price.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Spacer(),
                              Icon(Icons.access_time,
                                  size: 16, color: AppColors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${service.duration} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: AppColors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.white,
                ),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildInfoSection(),
                _buildOpeningHours(),
                _buildServices(),
                const SizedBox(height: 80), // Space for floating button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => BookingFormScreen(
                        salon: widget.salon,
                        isHomeService: false,
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (widget.salon.homeService) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => BookingFormScreen(
                          salon: widget.salon,
                          isHomeService: true,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Book at Home',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
