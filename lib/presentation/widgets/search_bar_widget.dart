import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skycast/presentation/providers/weather_provider.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String city) {
    if (city.trim().isEmpty) return;
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);

    ref.read(weatherProvider.notifier).loadByCity(city.trim());

    // Save to recent searches
    final recent = List<String>.from(ref.read(recentSearchesProvider));
    recent.remove(city);
    recent.insert(0, city);
    if (recent.length > 5) recent.removeLast();
    ref.read(recentSearchesProvider.notifier).state = recent;

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(recentSearchesProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF142038),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  onTap: () => setState(() => _showSuggestions = true),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.my_location,
                      color: Colors.white38, size: 18),
                  onPressed: () {
                    ref.read(weatherProvider.notifier).loadByLocation();
                    setState(() => _showSuggestions = false);
                  },
                ),
            ],
          ),
        ),

        // Recent searches dropdown
        if (_showSuggestions && recent.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2E48),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: recent
                  .map(
                    (city) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.history,
                          color: Colors.white38, size: 16),
                      title: Text(
                        city,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      onTap: () => _search(city),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
