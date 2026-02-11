import 'dart:ui';

import 'package:flutter/material.dart';

class ProfileFieldCard extends StatelessWidget {
  final String label;
  final dynamic value; // int, List, String, null

  const ProfileFieldCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;

    Widget body;
    if (value is List) {
      final list = value.cast<dynamic>();
      if (list.isEmpty) return const SizedBox.shrink();

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final v in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: Text(
                      v.toString(),
                      style: tt.bodyMedium?.copyWith(
                        color: const Color(0xFF2E4B5A).withOpacity(0.75),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      body = Text(
        value.toString(),
        style: tt.bodyMedium?.copyWith(
          color: const Color(0xFF2E4B5A).withOpacity(0.75),
          height: 1.25,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFD6E6F5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A2B5B7A),
                  blurRadius: 26,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E4B5A),
                  ),
                ),
                const SizedBox(height: 10),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
