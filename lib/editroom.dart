import 'package:flutter/material.dart';

/// ===== Enum + helper (ใช้ร่วมกับ AddRoom ได้) =====
enum RoomStatus { free, reserved, pending, disabled }

String statusLabel(RoomStatus s) => switch (s) {
  RoomStatus.free => 'Free',
  RoomStatus.reserved => 'Reserved',
  RoomStatus.pending => 'Pending',
  RoomStatus.disabled => 'Disabled',
};

Color statusColor(RoomStatus s) => switch (s) {
  RoomStatus.free => Colors.green,
  RoomStatus.reserved => Colors.red,
  RoomStatus.pending => Colors.orange,
  RoomStatus.disabled => Colors.grey,
};

/// ===== EditRoomScreen =====
/// รองรับค่าเริ่มต้น (เช่นโหลดจาก DB มาก่อน) ผ่าน constructor
class EditRoomScreen extends StatefulWidget {
  const EditRoomScreen({
    super.key,
    this.roomId,
    this.initialName = 'Deluxe Twin Room',
    this.initialDesc = '2 single beds • breakfast • air-conditioned',
    this.initialStatus = RoomStatus.free,
    this.initialImagePath,
  });

  final String? roomId;
  final String initialName;
  final String initialDesc;
  final RoomStatus initialStatus;
  final String? initialImagePath;

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  // single source of truth
  late RoomStatus _status;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDesc);
    _status = widget.initialStatus;
    _imagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _rounded([Color? color]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color ?? Colors.grey.shade400),
      );

  void _saveChanges() {
    // TODO: ส่งข้อมูลไป backend / JSON-Server / MySQL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Changes saved!\n'
          'ID: ${widget.roomId ?? "-"}\n'
          'Name: ${_nameCtrl.text}\n'
          'Desc: ${_descCtrl.text}\n'
          'Status: ${statusLabel(_status)}\n'
          'Image: ${_imagePath ?? "-"}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F7FF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Manage Booking',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Requested'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Check'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'User'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ปุ่ม Edit Room ด้านบน (เหลืองพาสเทล)
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.yellow.shade400,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black87, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Edit Room',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Room Pictures
              const Text('Room Pictures',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  // TODO: ใช้ image_picker เปิดแกลเลอรีจริง
                  setState(() => _imagePath = 'DEMO_EDIT.jpg'); // demo
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _imagePath == null ? Icons.image_outlined : Icons.check_circle,
                        size: 40,
                        color: _imagePath == null ? Colors.grey : Colors.green,
                      ),
                      Text(
                        _imagePath == null ? 'Tap to upload room picture' : 'Image selected',
                        style: TextStyle(
                          color: _imagePath == null ? Colors.grey : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Room name
              const Text('Room name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  border: _rounded(),
                  enabledBorder: _rounded(),
                  focusedBorder: _rounded(Colors.blue.shade600),
                ),
              ),
              const SizedBox(height: 20),

              // Room Description
              const Text('Room Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  border: _rounded(),
                  enabledBorder: _rounded(),
                  focusedBorder: _rounded(Colors.blue.shade600),
                ),
              ),
              const SizedBox(height: 20),

              // Room Status (Dropdown)
              const Text('Room Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RoomStatus>(
                    value: _status,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: RoomStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: statusColor(s)),
                            const SizedBox(width: 8),
                            Text(statusLabel(s)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Room Status (Radio – sync กับ dropdown)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    RadioListTile<RoomStatus>(
                      value: RoomStatus.free,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v!),
                      title: const Text('Free'),
                      secondary:
                          Icon(Icons.circle, size: 12, color: statusColor(RoomStatus.free)),
                      activeColor: statusColor(RoomStatus.free),
                    ),
                    RadioListTile<RoomStatus>(
                      value: RoomStatus.reserved,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v!),
                      title: const Text('Reserved'),
                      secondary: Icon(Icons.circle,
                          size: 12, color: statusColor(RoomStatus.reserved)),
                      activeColor: statusColor(RoomStatus.reserved),
                    ),
                    RadioListTile<RoomStatus>(
                      value: RoomStatus.disabled,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v!),
                      title: const Text('Disabled'),
                      secondary: Icon(Icons.circle,
                          size: 12, color: statusColor(RoomStatus.disabled)),
                      activeColor: statusColor(RoomStatus.disabled),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Changes button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A78F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
