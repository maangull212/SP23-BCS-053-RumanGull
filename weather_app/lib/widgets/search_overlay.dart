import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchOverlay extends StatefulWidget {
  final Function(String) onSearch;

  const SearchOverlay({super.key, required this.onSearch});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(city);
    _recentSearches.insert(0, city);
    if (_recentSearches.length > 5) _recentSearches = _recentSearches.take(5).toList();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    _saveSearch(value.trim());
    widget.onSearch(value.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF0288D1), size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Search City',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C2B3A),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close, color: Color(0xFF546E7A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _submit,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C2B3A),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter city name...',
                          hintStyle: const TextStyle(color: Color(0xFF90A4AE)),
                          filled: true,
                          fillColor: const Color(0xFFF0F7FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF0288D1),
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Color(0xFF0288D1),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () => _submit(_controller.text),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0288D1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      if (_recentSearches.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'RECENT SEARCHES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF90A4AE),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._recentSearches.map(
                          (city) => GestureDetector(
                            onTap: () => _submit(city),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FBFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history,
                                    color: Color(0xFF90A4AE),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF1C2B3A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.north_west,
                                    color: Color(0xFF90A4AE),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
