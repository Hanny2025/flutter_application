import 'package:flutter/material.dart';

/// ===== 1) Enum + helper สำหรับสถานะห้อง =====
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

/// ===== 2) หน้า Add Room (พร้อมฟอร์มครบ) =====
class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // เก็บสถานะ “แหล่งความจริงเดียว”
  RoomStatus _status = RoomStatus.free;

  // ไฟล์รูป (เดโม: เก็บ path เป็นสตริง; ถ้าใช้ image_picker ค่อยเปลี่ยน)
  String? _imagePath;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ปุ่มบันทึก
  void _saveRoom() {
    if (!_formKey.currentState!.validate()) return;

    final snack = SnackBar(
      content: Text(
        'Saved!\n'
        'Name: ${_nameCtrl.text}\n'
        'Desc: ${_descCtrl.text}\n'
        'Status: ${statusLabel(_status)}\n'
        'Image: ${_imagePath ?? "-"}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);

    // TODO: ส่งข้อมูลไป backend / JSON-Server / MySQL ตามที่คุณใช้อยู่
  }

  OutlineInputBorder _rounded([Color? color]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color ?? Colors.grey.shade400),
      );

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ปุ่ม Add Room ด้านบน (โทนเขียวพาสเทล)
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.lightGreen.shade400,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {}, // กดแล้วจะใส่ logic เพิ่มภายหลังได้
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.black87, size: 26),
                            SizedBox(width: 12),
                            Text('Add Room',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ===== Room Pictures =====
                const Text('Room Pictures',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    // TODO: ใช้ image_picker เลือกรูปจริง
                    // final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                    // if (img != null) setState(() => _imagePath = img.path);
                    setState(() => _imagePath = 'DEMO_PATH.jpg'); // เดโม
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
                          _imagePath == null
                              ? 'Tap to upload room picture'
                              : 'Image selected',
                          style: TextStyle(
                            color: _imagePath == null ? Colors.grey : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ===== Room name =====
                const Text('Room name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter room name' : null,
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

                // ===== Room Description =====
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

                // ===== Room Status (Dropdown) =====
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

                // ===== Room Status (Radio sync กับ dropdown) =====
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
                      ),
                      RadioListTile<RoomStatus>(
                        value: RoomStatus.reserved,
                        groupValue: _status,
                        onChanged: (v) => setState(() => _status = v!),
                        title: const Text('Reserved'),
                        secondary: Icon(Icons.circle,
                            size: 12, color: statusColor(RoomStatus.reserved)),
                      ),
                      RadioListTile<RoomStatus>(
                        value: RoomStatus.pending,
                        groupValue: _status,
                        onChanged: (v) => setState(() => _status = v!),
                        title: const Text('Pending'),
                        secondary: Icon(Icons.circle,
                            size: 12, color: statusColor(RoomStatus.pending)),
                      ),
                      RadioListTile<RoomStatus>(
                        value: RoomStatus.disabled,
                        groupValue: _status,
                        onChanged: (v) => setState(() => _status = v!),
                        title: const Text('Disabled'),
                        secondary: Icon(Icons.circle,
                            size: 12, color: statusColor(RoomStatus.disabled)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ===== Save Button =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A78F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Room',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
