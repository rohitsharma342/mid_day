import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:badges/badges.dart' as badges;
import '../controllers/cart_controller.dart';
import '../models/tiffin.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../widgets/tiffin_card.dart';
import 'tiffin_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Tiffin> _allTiffins = [];
  List<Tiffin> _filteredTiffins = [];
  String _selectedCategory = 'All';
  String _selectedMetalType = 'All';
  String _selectedPriceRange = 'All';
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTiffins();
    _searchController.addListener(_filterTiffins);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTiffins() {
    _allTiffins = DataService.getTiffins();
    _filteredTiffins = List.from(_allTiffins);
    setState(() {});
  }

  void _filterTiffins() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredTiffins = _allTiffins.where((tiffin) {
        bool matchesSearch = tiffin.name.toLowerCase().contains(searchQuery) ||
                           tiffin.description.toLowerCase().contains(searchQuery);
        
        bool matchesCategory = _selectedCategory == 'All' || tiffin.category == _selectedCategory;
        bool matchesMetalType = _selectedMetalType == 'All' || tiffin.metalType == _selectedMetalType;
        bool matchesPriceRange = _matchesPriceRange(tiffin.price);
        
        return matchesSearch && matchesCategory && matchesMetalType && matchesPriceRange;
      }).toList();
    });
  }

  bool _matchesPriceRange(double price) {
    switch (_selectedPriceRange) {
      case 'Under ₹150':
        return price < 150;
      case '₹150-₹200':
        return price >= 150 && price <= 200;
      case '₹200-₹250':
        return price >= 200 && price <= 250;
      case 'Above ₹250':
        return price > 250;
      default:
        return true;
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterTiffins();
  }

  void _onMetalTypeChanged(String? metalType) {
    setState(() {
      _selectedMetalType = metalType ?? 'All';
    });
    _filterTiffins();
  }

  void _onPriceRangeChanged(String? priceRange) {
    setState(() {
      _selectedPriceRange = priceRange ?? 'All';
    });
    _filterTiffins();
  }

  @override
  Widget build(BuildContext context) {
    final trendingTiffins = _allTiffins.where((tiffin) => tiffin.isTrending).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Consumer<CartController>(
            builder: (context, cartController, child) {
              return badges.Badge(
                badgeContent: Text(
                  cartController.itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                showBadge: cartController.itemCount > 0,
                badgeStyle: badges.BadgeStyle(
                  badgeColor: AppConstants.primaryColor,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTiffins();
        },
        child: SingleChildScrollView(
          padding: AppConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 24),
              if (trendingTiffins.isNotEmpty) ...[
                _buildSectionTitle('Trending Tiffins'),
                const SizedBox(height: 16),
                _buildTrendingCarousel(trendingTiffins),
                const SizedBox(height: 24),
              ],
              _buildSectionTitle('All Tiffins (${_filteredTiffins.length})'),
              const SizedBox(height: 16),
              _buildTiffinGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: AppStrings.search,
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            'Metal Type',
            _selectedMetalType,
            DataService.getMetalTypes(),
            _onMetalTypeChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFilterDropdown(
            'Price Range',
            _selectedPriceRange,
            DataService.getPriceRanges(),
            _onPriceRangeChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(label),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = DataService.getCategories();
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _onCategoryChanged(category),
              selectedColor: AppConstants.primaryColor.withOpacity(0.2),
              checkmarkColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppConstants.primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTrendingCarousel(List<Tiffin> trendingTiffins) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: trendingTiffins.length,
          itemBuilder: (context, index, realIndex) {
            final tiffin = trendingTiffins[index];
            return GestureDetector(
              onTap: () => _navigateToTiffinDetail(tiffin),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          tiffin.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tiffin.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${tiffin.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: trendingTiffins.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == entry.key
                    ? AppConstants.primaryColor
                    : Colors.grey[300],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTiffinGrid() {
    if (_filteredTiffins.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tiffins found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredTiffins.length,
      itemBuilder: (context, index) {
        final tiffin = _filteredTiffins[index];
        return TiffinCard(
          tiffin: tiffin,
          onTap: () => _navigateToTiffinDetail(tiffin),
        );
      },
    );
  }

  void _navigateToTiffinDetail(Tiffin tiffin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TiffinDetailScreen(tiffin: tiffin),
      ),
    );
  }
}