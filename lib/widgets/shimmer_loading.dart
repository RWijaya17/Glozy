import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';

class ShimmerSalonCard extends StatelessWidget {
  const ShimmerSalonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primary,
      highlightColor: AppColors.lightGrey.withOpacity(0.3),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerBoxWidget extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const ShimmerBoxWidget({
    Key? key,
    required this.height,
    this.width,
    this.margin,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primary,
      highlightColor: AppColors.lightGrey.withOpacity(0.3),
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ShimmerTextWidget extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const ShimmerTextWidget({
    Key? key,
    required this.width,
    this.height = 16,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerBoxWidget(
      height: height,
      width: width,
      margin: margin,
      borderRadius: BorderRadius.circular(8),
    );
  }
}
