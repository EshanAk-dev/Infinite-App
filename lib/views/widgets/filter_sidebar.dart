// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:infinite_app/models/products_filters.dart';
import 'package:iconsax/iconsax.dart';

class FilterSidebar extends StatefulWidget {
  final ProductFilters initialFilters;
  final Function(ProductFilters) onFiltersChanged;
  final VoidCallback onClearFilters;

  const FilterSidebar({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  late ProductFilters _filters;
  final Map<String, bool> _expandedSections = {
    'price': true,
    'category': true,
    'gender': true,
    'colors': true,
    'sizes': true,
    'materials': true,
    'brands': true,
  };

  final List<String> categories = [
    "Top Wear",
    "Bottom Wear",
    "Dresses",
    "Hats",
    "Aprons"
  ];

  final List<Map<String, String>> colors = [
    {"name": "Red", "value": "Red"},
    {"name": "Blue", "value": "Blue"},
    {"name": "Green", "value": "Green"},
    {"name": "Yellow", "value": "Yellow"},
    {"name": "Black", "value": "Black"},
    {"name": "White", "value": "White"},
    {"name": "Orange", "value": "Orange"},
    {"name": "Purple", "value": "Purple"},
    {"name": "Pink", "value": "Pink"},
    {"name": "Brown", "value": "Brown"},
  ];

  final List<String> sizes = ["XS", "S", "M", "L", "XL", "XXL", "XXXL"];

  final List<String> materials = [
    "Cotton",
    "Polyester",
    "Wool",
    "Linen",
    "Silk",
    "Denim",
    "Leather",
    "Rayon"
  ];

  final List<String> brands = ["Infinite"];
  final List<String> genders = ["Men", "Women", "Unisex"];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  void _handleFilterChange(ProductFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      width: 320,
      backgroundColor: colorScheme.surface,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.filter,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Filters',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_filters.hasFilters)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _filters = ProductFilters();
                      });
                      widget.onClearFilters();
                    },
                    icon: const Icon(Icons.refresh,
                        size: 20, color: Colors.black),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),

          // Filter sections
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Filter
                  _buildFilterSection(
                    title: 'Price Range',
                    sectionKey: 'price',
                    icon: Icons.attach_money,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rs. ${_filters.minPrice.toInt()}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Rs. ${_filters.maxPrice.toInt()}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.black,
                            inactiveTrackColor: Colors.black.withOpacity(0.2),
                            thumbColor: Colors.black,
                            overlayColor: Colors.black.withOpacity(0.2),
                            trackHeight: 4,
                          ),
                          child: RangeSlider(
                            values: RangeValues(
                                _filters.minPrice, _filters.maxPrice),
                            min: 0,
                            max: 10000,
                            divisions: 100,
                            labels: RangeLabels(
                              'Rs. ${_filters.minPrice.toInt()}',
                              'Rs. ${_filters.maxPrice.toInt()}',
                            ),
                            onChanged: (values) {
                              _handleFilterChange(_filters.copyWith(
                                minPrice: values.start,
                                maxPrice: values.end,
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories Filter
                  _buildFilterSection(
                    title: 'Categories',
                    sectionKey: 'category',
                    icon: Icons.category,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 4), // top padding
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _filters.category == category;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _handleFilterChange(_filters.copyWith(
                                category: isSelected ? null : category,
                              ));
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 4),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: category,
                                    groupValue: _filters.category,
                                    onChanged: (value) {
                                      _handleFilterChange(
                                          _filters.copyWith(category: value));
                                    },
                                    activeColor: Colors.black,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity
                                        .compact, // Compact radio button
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Gender Filter
                  _buildFilterSection(
                    title: 'Gender',
                    sectionKey: 'gender',
                    icon: Icons.person,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: genders.map((gender) {
                            final isSelected = _filters.gender == gender;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _handleFilterChange(_filters.copyWith(
                                      gender: isSelected ? null : gender,
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? Colors.black
                                        : colorScheme.surfaceVariant,
                                    foregroundColor: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                    elevation: isSelected ? 2 : 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(gender),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Colors Filter
                  _buildFilterSection(
                    title: 'Colors',
                    sectionKey: 'colors',
                    icon: Icons.palette,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        children: colors.map((color) {
                          final isSelected = _filters.color == color['value'];
                          return GestureDetector(
                            onTap: () {
                              _handleFilterChange(_filters.copyWith(
                                color: isSelected ? '' : color['value'],
                              ));
                            },
                            child: Tooltip(
                              message: color['name'],
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getColorFromString(color['value']!),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 22,
                                        color: _isLightColor(color['value']!)
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Sizes Filter
                  _buildFilterSection(
                    title: 'Sizes',
                    sectionKey: 'sizes',
                    icon: Icons.straighten,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: sizes.map((size) {
                          final isSelected = _filters.sizes.contains(size);
                          return GestureDetector(
                            onTap: () {
                              final newSizes =
                                  List<String>.from(_filters.sizes);
                              if (isSelected) {
                                newSizes.remove(size);
                              } else {
                                newSizes.add(size);
                              }
                              _handleFilterChange(
                                  _filters.copyWith(sizes: newSizes));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black
                                    : colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Materials Filter
                  _buildFilterSection(
                    title: 'Materials',
                    sectionKey: 'materials',
                    icon: Icons.layers,
                    child: Column(
                      children: materials.map((material) {
                        final isSelected =
                            _filters.materials.contains(material);
                        return InkWell(
                          onTap: () {
                            final newMaterials =
                                List<String>.from(_filters.materials);
                            if (isSelected) {
                              newMaterials.remove(material);
                            } else {
                              newMaterials.add(material);
                            }
                            _handleFilterChange(
                                _filters.copyWith(materials: newMaterials));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 4),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (selected) {
                                    final newMaterials =
                                        List<String>.from(_filters.materials);
                                    if (selected == true) {
                                      newMaterials.add(material);
                                    } else {
                                      newMaterials.remove(material);
                                    }
                                    _handleFilterChange(_filters.copyWith(
                                        materials: newMaterials));
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  material,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Brands Filter
                  _buildFilterSection(
                    title: 'Brands',
                    sectionKey: 'brands',
                    icon: Icons.shopping_bag,
                    child: Column(
                      children: brands.map((brand) {
                        final isSelected = _filters.brands.contains(brand);
                        return InkWell(
                          onTap: () {
                            final newBrands =
                                List<String>.from(_filters.brands);
                            if (isSelected) {
                              newBrands.remove(brand);
                            } else {
                              newBrands.add(brand);
                            }
                            _handleFilterChange(
                                _filters.copyWith(brands: newBrands));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (selected) {
                                    final newBrands =
                                        List<String>.from(_filters.brands);
                                    if (selected == true) {
                                      newBrands.add(brand);
                                    } else {
                                      newBrands.remove(brand);
                                    }
                                    _handleFilterChange(
                                        _filters.copyWith(brands: newBrands));
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  brand,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply Filters Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String sectionKey,
    required Widget child,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleSection(sectionKey),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expandedSections[sectionKey]! ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: child,
            ),
            crossFadeState: _expandedSections[sectionKey]!
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  bool _isLightColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
      case 'white':
        return true;
      default:
        return false;
    }
  }
}
