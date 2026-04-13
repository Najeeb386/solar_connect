import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRRewardPage extends StatefulWidget {
  const QRRewardPage({super.key});

  @override
  State<QRRewardPage> createState() => _QRRewardPageState();
}

class _QRRewardPageState extends State<QRRewardPage> {
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _isRewardFound = false;
  bool _hasScanned = false;

  String _brandName = '';
  String _rewardAmount = '';
  Color _brandColor = const Color(0xFFFF8F00);

  final List<Map<String, dynamic>> _availableRewards = [
    {
      'code': 'ECO001',
      'brand': 'EcoSolar Panels',
      'reward': 'Rs 500',
      'color': const Color(0xFF2196F3),
    },
    {
      'code': 'TESLA01',
      'brand': 'Tesla Powerwall',
      'reward': 'Rs 2,000',
      'color': const Color(0xFFE91E63),
    },
    {
      'code': 'FRON01',
      'brand': 'Fronius Inverters',
      'reward': 'Rs 1,500',
      'color': const Color(0xFF4CAF50),
    },
    {
      'code': 'HUAWEI1',
      'brand': 'Huawei Solar',
      'reward': 'Rs 3,000',
      'color': const Color(0xFFFF5722),
    },
    {
      'code': 'LUMI001',
      'brand': 'Luminous Batteries',
      'reward': 'Rs 800',
      'color': const Color(0xFF9C27B0),
    },
    {
      'code': 'GROW001',
      'brand': 'Growatt Inverters',
      'reward': 'Rs 1,200',
      'color': const Color(0xFF00BCD4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _checkReward(barcode.rawValue!);
        break;
      }
    }
  }

  void _checkReward(String code) {
    final reward = _availableRewards.firstWhere(
      (r) => r['code'] == code,
      orElse: () => {
        'code': '',
        'brand': 'Unknown',
        'reward': 'Rs 0',
        'color': Colors.grey,
      },
    );

    if (reward['code'] != '') {
      setState(() {
        _hasScanned = true;
        _isRewardFound = true;
        _isScanning = false;
        _brandName = reward['brand'];
        _rewardAmount = reward['reward'];
        _brandColor = reward['color'];
      });
      _scannerController?.stop();
    } else {
      setState(() {
        _hasScanned = true;
        _isRewardFound = false;
        _isScanning = false;
      });
      _scannerController?.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Claim Reward',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildScanner()),
            _buildInstructions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_giftcard, color: Color(0xFFFF8F00)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan QR to Claim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Scan the brand QR code to claim your reward',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _isRewardFound
            ? _buildRewardFoundView()
            : _hasScanned && !_isRewardFound
            ? _buildInvalidView()
            : _isScanning
            ? _buildCameraView()
            : _buildWaitingView(),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        MobileScanner(controller: _scannerController, onDetect: _onDetect),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: _brandColor, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Point camera at brand QR code',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            onPressed: () => _scannerController?.toggleTorch(),
            icon: const Icon(Icons.flash_on, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingView() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 50,
              color: Color(0xFFFF8F00),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Claim Your Reward',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan the QR code provided by the brand to claim your reward',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isScanning = true;
                  _hasScanned = false;
                  _isRewardFound = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Scanning',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardFoundView() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _brandColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 50, color: _brandColor),
          ),
          const SizedBox(height: 20),
          Text(
            _brandName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _brandColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reward Found!',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _rewardAmount,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Claimed!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidView() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel, size: 50, color: Color(0xFFF44336)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Invalid QR Code',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF44336),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This QR code is not valid for any reward',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isScanning = true;
                  _hasScanned = false;
                  _isRewardFound = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Scan Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFF8F00)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Scan the QR code provided by the brand after completing the installation to claim your reward.',
              style: TextStyle(color: Color(0xFFE65100), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
