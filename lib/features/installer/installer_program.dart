import 'package:flutter/material.dart';

class InstallerProgramPage extends StatefulWidget {
  const InstallerProgramPage({super.key});

  @override
  State<InstallerProgramPage> createState() => _InstallerProgramPageState();
}

class _InstallerProgramPageState extends State<InstallerProgramPage> {
  final List<Map<String, dynamic>> _programs = [
    {
      'title': 'Solar Panel Installation Basic',
      'description': 'Learn the fundamentals of solar panel installation',
      'duration': '2 weeks',
      'level': 'Beginner',
      'status': 'Completed',
      'progress': 100,
    },
    {
      'title': 'Advanced Inverter Setup',
      'description':
          'Master advanced inverter configuration and troubleshooting',
      'duration': '3 weeks',
      'level': 'Advanced',
      'status': 'In Progress',
      'progress': 65,
    },
    {
      'title': 'Electrical Safety Certification',
      'description':
          'Complete electrical safety training for solar installations',
      'duration': '1 week',
      'level': 'Intermediate',
      'status': 'Not Started',
      'progress': 0,
    },
    {
      'title': 'Energy Storage Systems',
      'description': 'Battery storage system installation and maintenance',
      'duration': '2 weeks',
      'level': 'Advanced',
      'status': 'Not Started',
      'progress': 0,
    },
    {
      'title': 'Customer Service Excellence',
      'description': 'Best practices for customer interactions',
      'duration': '1 week',
      'level': 'Beginner',
      'status': 'Completed',
      'progress': 100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildProgressCard(),
                  const SizedBox(height: 20),
                  _buildProgramsList(),
                ],
              ),
            ),
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
                color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Installer Program',
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

  Widget _buildProgressCard() {
    final completed = _programs.where((p) => p['progress'] == 100).length;
    final total = _programs.length;
    final percentage = ((completed / total) * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed of $total programs completed',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completed / total,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Programs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._programs.map((program) => _buildProgramCard(program)),
      ],
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    Color statusColor;
    switch (program['status']) {
      case 'Completed':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'In Progress':
        statusColor = const Color(0xFFFF8F00);
        break;
      default:
        statusColor = Colors.grey;
    }

    Color levelColor;
    switch (program['level']) {
      case 'Beginner':
        levelColor = const Color(0xFF4CAF50);
        break;
      case 'Intermediate':
        levelColor = const Color(0xFFFF8F00);
        break;
      case 'Advanced':
        levelColor = const Color(0xFFF44336);
        break;
      default:
        levelColor = Colors.grey;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  program['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  program['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            program['description'],
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  program['level'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: levelColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.schedule, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                program['duration'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          if (program['progress'] > 0 && program['progress'] < 100) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: program['progress'] / 100,
                      backgroundColor: const Color(0xFFF5F5F5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF8F00),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${program['progress']}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8F00),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  program['status'] == 'Not Started' ||
                      program['status'] == 'In Progress'
                  ? () {}
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                program['status'] == 'Completed'
                    ? 'View Certificate'
                    : program['status'] == 'In Progress'
                    ? 'Continue Learning'
                    : 'Start Program',
                style: TextStyle(
                  color:
                      program['status'] == 'Completed' ||
                          program['status'] == 'In Progress'
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
