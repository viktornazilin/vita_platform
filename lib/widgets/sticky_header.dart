import 'package:flutter/material.dart';

class StickyHeader extends SliverPersistentHeaderDelegate {
  final double _min;
  final double _max;
  final Widget child;

  StickyHeader({
    required double minExtent,
    required double maxExtent,
    required this.child,
  })  : _min = minExtent,
        _max = maxExtent;

  @override
  double get minExtent => _min;

  @override
  double get maxExtent => _max;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: maxExtent,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyHeader old) =>
      _min != old._min || _max != old._max || child != old.child;
}
