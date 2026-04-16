import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopkeepersPage extends StatefulWidget {
  const ShopkeepersPage({super.key});

  @override
  State<ShopkeepersPage> createState() => _ShopkeepersPageState();
}

class _ShopkeepersPageState extends State<ShopkeepersPage> {
  final List<Map<String, dynamic>> _installers = [
    {
      'name': 'Ahmed Khan',
      'phone': '+92 300 1234567',
      'skills': 'Solar Installation, Electrical',
      'rating': 4.8,
      'jobsCompleted': 45,
      'location': 'Lahore',
      'verified': true,
    },
    {
      'name': 'Muhammad Ali',
      'phone': '+92 301 2345678',
      'skills': 'Battery Setup, Inverter Repair',
      'rating': 4.5,
      'jobsCompleted': 32,
      'location': 'Karachi',
      'verified': true,
    },
    {
      'name': 'Saeed Ahmed',
      'phone': '+92 302 3456789',
      'skills': 'Maintenance, Cleaning',
      'rating': 4.2,
      'jobsCompleted': 18,
      'location': 'Islamabad',
      'verified': false,
    },
    {
      'name': 'Rashid Mehmood',
      'phone': '+92 303 4567890',
      'skills': 'Solar Installation, Wiring',
      'rating': 4.9,
      'jobsCompleted': 67,
      'location': 'Lahore',
      'verified': true,
    },
    {
      'name': 'Bilal Hussain',
      'phone': '+92 304 5678901',
      'skills': 'Electrical, Repair',
      'rating': 4.0,
      'jobsCompleted': 12,
      'location': 'Faisalabad',
      'verified': false,
    },
  ];

  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    var filteredInstallers = _installers.where((i) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          i['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          i['skills'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesFilter =
          _selectedFilter == 'All' ||
          (_selectedFilter == 'Verified' && i['verified']) ||
          (_selectedFilter == 'Unverified' && !i['verified']);
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildInstallersList(filteredInstallers)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF9C27B0)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Find Installers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by name or skills...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Verified', 'Unverified'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
                selectedColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF9C27B0),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF9C27B0) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInstallersList(List<Map<String, dynamic>> installers) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: installers.length,
      itemBuilder: (context, index) {
        final installer = installers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(
                      0xFF9C27B0,
                    ).withValues(alpha: 0.1),
                    child: Text(
                      installer['name'][0],
                      style: const TextStyle(
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              installer['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (installer['verified']) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Color(0xFF4CAF50),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          installer['phone'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            installer['rating'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${installer['jobsCompleted']} jobs',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    installer['location'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.build, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      installer['skills'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showHireDialog(installer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHireDialog(Map<String, dynamic> installer) {
    Get.dialog(
      AlertDialog(
        title: Text(installer['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${installer['phone']}'),
            const SizedBox(height: 8),
            Text('Skills: ${installer['skills']}'),
            const SizedBox(height: 8),
            Text('Location: ${installer['location']}'),
            const SizedBox(height: 8),
            Text('Rating: ${installer['rating']}/5'),
            const SizedBox(height: 8),
            Text('Jobs Completed: ${installer['jobsCompleted']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Installer hired successfully!',
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text('Hire', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
