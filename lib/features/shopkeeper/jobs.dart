import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_partner/features/shopkeeper/controllers/shopkeeper_controller.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final ShopkeeperController controller = Get.find<ShopkeeperController>();

  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _showJobDetails = false;
  Map<String, dynamic>? _selectedJob;

  @override
  void initState() {
    super.initState();
    if (controller.jobs.isEmpty) {
      controller.fetchJobs(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showJobDetails && _selectedJob != null) {
      return _buildJobDetailsView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => _buildHeader(context)),
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.jobsLoading.value &&
                    controller.jobs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9C27B0),
                    ),
                  );
                }

                final filteredJobs = controller.jobs.where((j) {
                  final job = j as Map;
                  final matchesSearch = _searchQuery.isEmpty ||
                      (job['title'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  final matchesFilter = _selectedFilter == 'All' ||
                      (job['status'] ?? '') == _selectedFilter;
                  return matchesSearch && matchesFilter;
                }).toList();

                return RefreshIndicator(
                  color: const Color(0xFF9C27B0),
                  onRefresh: () => controller.fetchJobs(refresh: true),
                  child: _buildJobsList(filteredJobs),
                );
              }),
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
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF9C27B0)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${controller.jobs.length} job(s) total',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const CreateJobPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              'Post Job',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.filter_list, color: Color(0xFF9C27B0)),
            ),
            onSelected: (value) =>
                setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'open', child: Text('Open')),
              const PopupMenuItem(
                  value: 'in_progress', child: Text('In Progress')),
              const PopupMenuItem(
                  value: 'completed', child: Text('Completed')),
              const PopupMenuItem(
                  value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(List<dynamic> jobs) {
    if (jobs.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No jobs found',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job =
            Map<String, dynamic>.from(jobs[index] as Map);
        final budgetRaw = job['budget'];
        final budgetDisplay =
            budgetRaw != null ? 'PKR $budgetRaw' : 'N/A';
        final createdAt = job['created_at'] ?? '';
        final displayDate = createdAt.length >= 10
            ? createdAt.substring(0, 10)
            : createdAt;
        // Backend returns skills_required, not city
        final skillsOrDate =
            job['skills_required']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusBadge(job['status'] ?? ''),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                [
                                  if (skillsOrDate.isNotEmpty)
                                    skillsOrDate,
                                  budgetDisplay,
                                  if (displayDate.isNotEmpty) displayDate,
                                ].join(' · '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedJob = job;
                            _showJobDetails = true;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9C27B0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('View'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _confirmDelete(job),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> job) {
    Get.defaultDialog(
      title: 'Delete Job',
      middleText:
          'Are you sure you want to delete "${job['title']}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        final id = job['id'];
        if (id != null) {
          await controller.deleteJob(int.parse(id.toString()));
        }
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF4CAF50);
        break;
      case 'in_progress':
      case 'in progress':
        color = const Color(0xFF2196F3);
        break;
      case 'open':
        color = const Color(0xFFFF9800);
        break;
      default:
        color = Colors.red;
    }

    final displayText = status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() +
            status.substring(1).replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildJobDetailsView() {
    final job = _selectedJob!;
    final budgetRaw = job['budget'];
    final budgetDisplay =
        budgetRaw != null ? 'PKR $budgetRaw' : 'N/A';
    final createdAt = job['created_at'] ?? '';
    final displayDate = createdAt.length >= 10
        ? createdAt.substring(0, 10)
        : createdAt;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showJobDetails = false),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      job['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(job['status'] ?? ''),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Budget', budgetDisplay),
                      _buildDetailRow('Skills Required',
                          job['skills_required']?.toString() ?? 'N/A'),
                      _buildDetailRow('Deadline',
                          job['deadline']?.toString() ?? 'N/A'),
                      _buildDetailRow('Posted',
                          displayDate.isNotEmpty ? displayDate : 'N/A'),
                      _buildDetailRow('Address',
                          job['address']?.toString() ?? 'N/A'),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(job['description'] ?? ''),
                      const SizedBox(height: 24),
                      const Text(
                        'Installer Applications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAssignmentsSection(job),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Get.to(() => CreateJobPage(job: job)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _confirmDelete(job),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side:
                                    const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection(Map<String, dynamic> job) {
    final jobId = job['id'];
    if (jobId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
            child: Text('No applications yet.',
                style: TextStyle(color: Colors.grey))),
      );
    }

    return FutureBuilder<List>(
      future: controller
          .fetchJobAssignments(int.parse(jobId.toString())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
                color: Color(0xFF9C27B0), strokeWidth: 2),
          ));
        }
        final assignments = snapshot.data ?? [];
        if (assignments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
                child: Text('No applications yet.',
                    style: TextStyle(color: Colors.grey))),
          );
        }
        return Column(
          children: assignments.map((a) {
            final assignment = a as Map;
            final installerName =
                assignment['installer_name']?.toString() ?? 'Installer';
            final status =
                assignment['status']?.toString() ?? 'assigned';
            final installerId = assignment['installer_id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            const Color(0xFF9C27B0).withValues(alpha: 0.1),
                        child: Text(
                            installerName.isNotEmpty
                                ? installerName[0].toUpperCase()
                                : 'I',
                            style: const TextStyle(
                                color: Color(0xFF9C27B0),
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(installerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(status,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (status == 'completed' && installerId != null)
                        Row(children: [
                          TextButton(
                            onPressed: () async {
                              final confirmed = await Get.defaultDialog<bool>(
                                title: 'Release Payment',
                                middleText:
                                    'Release payment to $installerName?',
                                textConfirm: 'Confirm',
                                textCancel: 'Cancel',
                                confirmTextColor: Colors.white,
                                buttonColor: const Color(0xFF9C27B0),
                                onConfirm: () => Get.back(result: true),
                                onCancel: () => Get.back(result: false),
                              );
                              if (confirmed == true) {
                                await controller.releasePayment(
                                  int.parse(jobId.toString()),
                                  int.parse(installerId.toString()),
                                  double.tryParse(
                                          job['budget']?.toString() ?? '0') ??
                                      0,
                                );
                              }
                            },
                            child: const Text('Pay',
                                style:
                                    TextStyle(color: Color(0xFF4CAF50))),
                          ),
                          TextButton(
                            onPressed: () async {
                              final reasonController =
                                  TextEditingController();
                              final confirmed = await Get.defaultDialog<bool>(
                                title: 'Raise Dispute',
                                content: TextField(
                                  controller: reasonController,
                                  decoration: const InputDecoration(
                                      hintText: 'Reason for dispute'),
                                ),
                                textConfirm: 'Submit',
                                textCancel: 'Cancel',
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () => Get.back(result: true),
                                onCancel: () => Get.back(result: false),
                              );
                              if (confirmed == true &&
                                  reasonController.text.isNotEmpty) {
                                await controller.raiseDispute(
                                  int.parse(jobId.toString()),
                                  int.parse(installerId.toString()),
                                  reasonController.text.trim(),
                                );
                              }
                            },
                            child: const Text('Dispute',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ]),
                    ],
                  ),
                  if ((assignment['payment_released_at'] != null) &&
                      (assignment['payment_received_at'] == null))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Awaiting installer confirmation',
                        style: TextStyle(fontSize: 11, color: Colors.orange[700]),
                      ),
                    ),
                  if (assignment['payment_received_at'] != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '✅ Payment confirmed',
                        style: TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class CreateJobPage extends StatefulWidget {
  final Map<String, dynamic>? job;

  const CreateJobPage({super.key, this.job});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final ShopkeeperController controller =
      Get.find<ShopkeeperController>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final budgetController = TextEditingController();
  final addressController = TextEditingController();
  final skillsController = TextEditingController();

  DateTime? _deadlineDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      final job = widget.job!;
      titleController.text = job['title'] ?? '';
      descriptionController.text = job['description'] ?? '';
      budgetController.text = job['budget']?.toString() ?? '';
      addressController.text = job['address']?.toString() ?? '';
      skillsController.text = job['skills_required']?.toString() ?? '';
      final deadlineStr = job['deadline']?.toString();
      if (deadlineStr != null && deadlineStr.length >= 10) {
        _deadlineDate = DateTime.tryParse(deadlineStr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.job != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEditing ? 'Edit Job' : 'Create New Job',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Job Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill in the details to create a new job posting.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      const Text('Job Title *',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: _inputDecoration(
                            'e.g. Solar Panel Installation'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Description *',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration:
                            _inputDecoration('Describe the job...'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Budget (PKR) *',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: budgetController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        decoration:
                            _inputDecoration('e.g. 12000'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Address *',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressController,
                        decoration:
                            _inputDecoration('Job site address'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Skills Required',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: skillsController,
                        decoration: _inputDecoration(
                            'e.g. Solar Installation, Electrical'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Deadline *',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deadlineDate ??
                                DateTime.now()
                                    .add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF9C27B0),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setState(() => _deadlineDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.grey, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                _deadlineDate != null
                                    ? '${_deadlineDate!.year}-${_deadlineDate!.month.toString().padLeft(2, '0')}-${_deadlineDate!.day.toString().padLeft(2, '0')}'
                                    : 'Select deadline date',
                                style: TextStyle(
                                  color: _deadlineDate != null
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF9C27B0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEditing
                                          ? 'Update Job'
                                          : 'Create Job',
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final budgetText = budgetController.text.trim();
    final address = addressController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        budgetText.isEmpty ||
        address.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill in all required fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_deadlineDate == null) {
      Get.snackbar(
        'Validation',
        'Please select a deadline date.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final budget = double.tryParse(budgetText);
    if (budget == null) {
      Get.snackbar(
        'Validation',
        'Budget must be a valid number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final deadlineStr =
        '${_deadlineDate!.year}-${_deadlineDate!.month.toString().padLeft(2, '0')}-${_deadlineDate!.day.toString().padLeft(2, '0')}';

    final data = {
      'title': title,
      'description': description,
      'address': address,
      'budget': budget,
      'deadline': deadlineStr,
      if (skillsController.text.trim().isNotEmpty)
        'skills_required': skillsController.text.trim(),
    };

    bool success;
    if (widget.job != null) {
      final id = widget.job!['id'];
      success =
          await controller.updateJob(int.parse(id.toString()), data);
    } else {
      success = await controller.createJob(data);
    }

    if (mounted) setState(() => _isSubmitting = false);

    if (success) {
      // Navigate back to jobs list immediately
      Get.back();
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    budgetController.dispose();
    addressController.dispose();
    skillsController.dispose();
    super.dispose();
  }
}
