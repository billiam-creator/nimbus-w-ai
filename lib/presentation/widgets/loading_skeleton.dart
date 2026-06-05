import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WeatherLoadingSkeleton extends StatelessWidget {
  const WeatherLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF142038),
      highlightColor: const Color(0xFF1E3050),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Hero placeholder
            Container(
              height: 360,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF142038),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
            ),
            const SizedBox(height: 24),
            // Hourly placeholder
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  6,
                  (_) => Container(
                    width: 68,
                    height: 110,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142038),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Daily rows placeholder
            ...List.generate(
              6,
              (_) => Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF142038),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}