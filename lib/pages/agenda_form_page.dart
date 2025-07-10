import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../models/agenda_model.dart';
import '../services/realtimedb_service.dart';

class AgendaFormPage extends StatefulWidget {
  const AgendaFormPage({super.key});

  @override
  State<AgendaFormPage> createState() => _AgendaFormPageState();
}

class _AgendaFormPageState extends State<AgendaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _mulaiController = TextEditingController();
  final _selesaiController = TextEditingController();

  DateTime? selectedDate;
  bool isEdit = false;
  late RealtimeDatabase realDb;

  @override
  void initState() {
    super.initState();
    realDb = RealtimeDatabase();
    initializeDateFormatting('id_ID', null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mulaiController.dispose();
    _selesaiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    selectedDate = args['date'] ?? args['selectedDate'];
    final AgendaItem? agenda = args['agenda'];

    if (agenda != null) {
      isEdit = true;
      _titleController.text = agenda.title;
      _mulaiController.text = agenda.mulai;
      _selesaiController.text = agenda.selesai;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final agenda = AgendaItem(
        title: _titleController.text.trim(),
        mulai: _mulaiController.text.trim(),
        selesai: _selesaiController.text.trim(),
      );

      if (selectedDate != null) {
        await realDb.saveAgendaForDay(selectedDate!, agenda);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEdit ? 'Agenda diperbarui!' : 'Agenda ditambahkan!'),
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formatted = picked.format(context);
      controller.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = selectedDate != null
        ? DateFormat.yMMMMd('id_ID').format(selectedDate!)
        : 'Tanggal tidak valid';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Agenda' : 'Tambah Agenda'),
        backgroundColor: Color(0xFFD6C9E7),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '📅 $dateStr',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Agenda',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Judul tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mulaiController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Waktu Mulai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () => _selectTime(_mulaiController),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _selesaiController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Waktu Selesai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time_filled),
                        ),
                        onTap: () => _selectTime(_selesaiController),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: Icon(isEdit ? Icons.save : Icons.add),
                          label: Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Agenda',
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD6C9E7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
