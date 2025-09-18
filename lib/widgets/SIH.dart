// pubspec.yaml dependencies needed:
/*
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.64.0
*/

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmMonitor',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
      ),
      home: FarmMonitorDashboard(),
    );
  }
}

// Mock Data Service
class DataService {
  static Map<String, dynamic> _sensorData = {
    'soil_moisture': 72.0,
    'battery_level': 85.0,
    'latitude': 40.7128,
    'longitude': -74.0060,
    'accuracy': 2.1,
    'timestamp': DateTime.now().toIso8601String(),
    'device_status': 'Active',
    'coverage': 85.0,
    'active_zones': 3
  };

  static List<Map<String, dynamic>> _activities = [
    {
      'activity_type': 'Calibration',
      'description': 'Moisture sensor calibrated',
      'timestamp': 'just now',
      'icon': 'settings'
    },
    {
      'activity_type': 'GPS',
      'description': 'GPS position updated',
      'timestamp': 'just now',
      'icon': 'location'
    }
  ];

  static Map<String, dynamic> getSensorData() {
    // Simulate random data changes
    _sensorData['soil_moisture'] = 65 + Random().nextDouble() * 20;
    _sensorData['battery_level'] = 80 + Random().nextDouble() * 20;
    return Map.from(_sensorData);
  }

  static List<Map<String, dynamic>> getActivities() {
    return List.from(_activities);
  }

  static void updateDeviceStatus(String status) {
    _sensorData['device_status'] = status;
  }
}

// Main Dashboard Widget
class FarmMonitorDashboard extends StatefulWidget {
  @override
  _FarmMonitorDashboardState createState() => _FarmMonitorDashboardState();
}

class _FarmMonitorDashboardState extends State<FarmMonitorDashboard> {
  Map<String, dynamic> sensorData = {};
  List<Map<String, dynamic>> activities = [];
  bool isDeviceActive = true;
  Timer? _dataUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startDataUpdate();
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      sensorData = DataService.getSensorData();
      activities = DataService.getActivities();
    });
  }

  void _startDataUpdate() {
    _dataUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTopSection(),
            SizedBox(height: 12),
            _buildMiddleSection(),
            SizedBox(height: 12),
            _buildFarmOperationsCard(),
            SizedBox(height: 12),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('FM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FarmMonitor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Device Dashboard', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Icon(Icons.wifi, color: Colors.green, size: 14),
            SizedBox(width: 4),
            Text('Connected', style: TextStyle(color: Colors.green, fontSize: 10)),
            SizedBox(width: 12),
            Stack(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.grey, size: 20),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 16),
            ),
            SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        // Soil Moisture and Battery in one row
        Row(
          children: [
            Expanded(child: _buildSoilMoistureCard()),
            SizedBox(width: 12),
            Expanded(child: _buildBatteryCard()),
          ],
        ),
        SizedBox(height: 12),
        // Activity card takes full width
        _buildActivityCard(),
      ],
    );
  }

  Widget _buildSoilMoistureCard() {
    final moisture = sensorData['soil_moisture'] ?? 0.0;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text('Soil Moisture', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text('${moisture.toInt()}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
          SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 70,
              width: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: moisture / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  Center(
                    child: Icon(Icons.water_drop, color: Colors.green, size: 20),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Text('Good condition', style: TextStyle(color: Colors.grey[600], fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBatteryCard() {
    final battery = sensorData['battery_level'] ?? 0.0;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_full, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text('Battery Level', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text('${battery.toInt()}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
          SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: battery / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.green,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Battery healthy', style: TextStyle(color: Colors.white, fontSize: 9)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text('Live Activity', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Spacer(),
              Text('Online', style: TextStyle(color: Colors.green, fontSize: 11)),
            ],
          ),
          SizedBox(height: 16),
          ...activities.take(2).map((activity) => _buildActivityItem(activity)),
          SizedBox(height: 12),
          Container(
            height: 30,
            child: Row(
              children: List.generate(7, (index) =>
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(bottom: Random().nextInt(20).toDouble()),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text('Last sync: 2 min ago', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity['icon'] == 'settings' ? Icons.settings : Icons.location_on,
              size: 10,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['description'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                Text(activity['timestamp'], style: TextStyle(fontSize: 9, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleSection() {
    return Column(
      children: [
        // Location and Device Control in one row
        Row(
          children: [
            Expanded(child: _buildLocationCard()),
            SizedBox(width: 12),
            Expanded(child: _buildDeviceControlCard()),
          ],
        ),
        SizedBox(height: 12),
        // Area Management takes full width
        _buildAreaManagementCard(),
      ],
    );
  }

  Widget _buildLocationCard() {
    final lat = sensorData['latitude'] ?? 40.7128;
    final lng = sensorData['longitude'] ?? -74.0060;
    final accuracy = sensorData['accuracy'] ?? 2.1;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text('Location', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.green[100]!],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 24, color: Colors.green),
                  Text('GPS Active', style: TextStyle(color: Colors.green[600], fontSize: 10)),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Text('Lat: ${lat.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          Text('Lng: ${lng.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          Text('±${accuracy}m', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDeviceControlCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.power_settings_new, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text('Control', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isDeviceActive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
                isDeviceActive ? 'Active' : 'Inactive',
                style: TextStyle(
                    color: isDeviceActive ? Colors.green : Colors.red,
                    fontSize: 10
                )
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isDeviceActive = !isDeviceActive;
                  DataService.updateDeviceStatus(isDeviceActive ? 'Active' : 'Inactive');
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDeviceActive ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'TURN ${isDeviceActive ? 'OFF' : 'ON'}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaManagementCard() {
    final coverage = sensorData['coverage'] ?? 85.0;
    final zones = sensorData['active_zones'] ?? 3;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.crop_free, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Text('Area Management', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Spacer(),
              Text('2.4 acres', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.green[50],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.agriculture, color: Colors.green, size: 20),
                  Text('Active Zone', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 10)),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit Area functionality'))
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text('Edit', style: TextStyle(fontSize: 11)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Zone saved!'))
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text('Save', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Coverage: ${coverage.toInt()}%', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('Zones: $zones active', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmOperationsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture_outlined, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Farm Operations', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Ready', style: TextStyle(color: Colors.green, fontSize: 10)),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOperationButton(
                  icon: Icons.eco,
                  label: 'PLANTING',
                  color: Colors.green,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Planting mode activated!'),
                          backgroundColor: Colors.green,
                        )
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildOperationButton(
                  icon: Icons.grass,
                  label: 'WEEDING',
                  color: Colors.orange,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Weeding mode activated!'),
                          backgroundColor: Colors.orange,
                        )
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildOperationButton(
                  icon: Icons.handyman,
                  label: 'MANUAL',
                  color: Colors.blue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Manual mode activated!'),
                          backgroundColor: Colors.blue,
                        )
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select an operation mode to begin farming tasks',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.videocam_outlined, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('Live Camera', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[100]!, Colors.blue[200]!],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.camera_alt, size: 24, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text('Camera Feed', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  Text('1920x1080 • 30fps', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Recording started!'))
                    );
                  },
                  icon: Icon(Icons.fiber_manual_record, color: Colors.white, size: 14),
                  label: Text('Start Recording', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Connected', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}