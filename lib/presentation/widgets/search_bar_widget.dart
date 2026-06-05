import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nimbus/presentation/providers/weather_provider.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _loading = false;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onTextChanged() async {
    final query = _controller.text.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final locations = await locationFromAddress(query);
      final seen = <String>{};
      final results = <String>[];

      for (final loc in locations.take(5)) {
        final placemarks = await placemarkFromCoordinates(
            loc.latitude, loc.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final city = p.locality ?? p.administrativeArea ?? '';
          final country = p.country ?? '';
          if (city.isNotEmpty) {
            final label = country.isNotEmpty ? '$city, $country' : city;
            if (seen.add(label)) results.add(label);
          }
        }
      }

      if (mounted) {
        setState(() {
          _suggestions = results;
          _showDropdown = results.isNotEmpty && _focusNode.hasFocus;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _search(String city) {
    _focusNode.unfocus();
    setState(() {
      _showDropdown = false;
      _suggestions = [];
    });

    ref.read(weatherProvider.notifier).loadByCity(city.trim());

    final recent = List<String>.from(ref.read(recentSearchesProvider));
    recent.remove(city);
    recent.insert(0, city);
    if (recent.length > 5) recent.removeLast();
    ref.read(recentSearchesProvider.notifier).state = recent;

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF142038) : Colors.white;
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white38 : Colors.black38;
    final dropdownColor = isDark ? const Color(0xFF1C2E48) : Colors.white;
    final suggestionTextColor = isDark ? Colors.white70 : Colors.black87;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(color: textColor, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(color: hintColor),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  onTap: () {
                    if (_suggestions.isNotEmpty) {
                      setState(() => _showDropdown = true);
                    }
                  },
                ),
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor,
                    ),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close, color: iconColor, size: 18),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _suggestions = [];
                      _showDropdown = false;
                    });
                  },
                )
              else
                IconButton(
                  icon: Icon(Icons.my_location, color: iconColor, size: 18),
                  onPressed: () {
                    ref.read(weatherProvider.notifier).loadByLocation();
                    setState(() => _showDropdown = false);
                  },
                ),
            ],
          ),
        ),

        // Autocomplete dropdown
        if (_showDropdown && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            decoration: BoxDecoration(
              color: dropdownColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _suggestions.asMap().entries.map((entry) {
                final i = entry.key;
                final city = entry.value;
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.location_city,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 16),
                      title: Text(
                        city,
                        style: TextStyle(
                            color: suggestionTextColor, fontSize: 14),
                      ),
                      onTap: () => _search(city),
                    ),
                    if (i < _suggestions.length - 1)
                      Divider(
                          color: dividerColor,
                          height: 1,
                          indent: 16,
                          endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),

        // Recent searches (when input is empty and focused)
        if (_showDropdown && _suggestions.isEmpty && _controller.text.isEmpty)
          Builder(builder: (context) {
            final recent = ref.watch(recentSearchesProvider);
            if (recent.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              decoration: BoxDecoration(
                color: dropdownColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Text('Recent',
                        style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  ...recent.map((city) => ListTile(
                        dense: true,
                        leading: Icon(Icons.history,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 16),
                        title: Text(city,
                            style: TextStyle(
                                color: suggestionTextColor, fontSize: 14)),
                        onTap: () => _search(city),
                      )),
                ],
              ),
            );
          }),
      ],
    );
  }
}