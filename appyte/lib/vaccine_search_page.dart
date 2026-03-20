import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VaccineSearchPage extends StatefulWidget {
  const VaccineSearchPage({super.key});

  @override
  State<VaccineSearchPage> createState() => _VaccineSearchPageState();
}

class _VaccineSearchPageState extends State<VaccineSearchPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedVaccine;
  DateTime? _selectedDate;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> vaccines = [
    // Trẻ em
    'BCG (Lao)',
    'Viêm gan B',
    '5 trong 1',
    '6 trong 1',
    'Sởi – Quai bị – Rubella (MMR)',
    'Thủy đậu',
    'Viêm não Nhật Bản',
    'Rotavirus',
    'Phế cầu',

    // Người lớn
    'Uốn ván',
    'Cúm mùa',
    'COVID-19',
    'Viêm gan A',
    'Zona thần kinh',
    'HPV',
    'Phế cầu (người lớn)',

    // Nguy cơ đặc biệt
    'Dại',
    'Não mô cầu',
    'Thương hàn',
    'Sốt xuất huyết (Qdenga)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        title: const Text("Đăng ký tiêm vắc xin"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionTitle("Thông tin người tiêm"),
              _inputCard(
                child: Column(
                  children: [
                    _textField(
                      controller: _nameController,
                      label: "Họ và tên",
                      icon: Icons.person,
                    ),
                    _textField(
                      controller: _ageController,
                      label: "Tuổi",
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                    ),
                    _textField(
                      controller: _phoneController,
                      label: "Số điện thoại",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle("Thông tin tiêm chủng"),
              _inputCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedVaccine,
                      decoration: _inputDecoration(
                        "Chọn loại vắc xin",
                        Icons.vaccines,
                      ),
                      items: vaccines
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(v),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedVaccine = v),
                      validator: (v) =>
                          v == null ? "Vui lòng chọn vắc xin" : null,
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration(
                            _selectedDate == null
                                ? "Ngày tiêm"
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                            Icons.calendar_today,
                          ),
                          validator: (_) => _selectedDate == null
                              ? "Vui lòng chọn ngày tiêm"
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _textField(
                      controller: _locationController,
                      label: "Cơ sở tiêm",
                      icon: Icons.local_hospital,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    "XÁC NHẬN",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? "Không được để trống" : null,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký tiêm vắc xin thành công"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
