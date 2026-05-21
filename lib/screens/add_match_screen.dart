import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import '../models/match.dart';

class AddMatchScreen extends StatefulWidget {
  final MatchModel? match; // Jika null -> tambah, jika ada -> edit
  const AddMatchScreen({super.key, this.match});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _homeTeamId, _awayTeamId;
  final TextEditingController _homeScoreController = TextEditingController();
  final TextEditingController _awayScoreController = TextEditingController();
  DateTime _matchDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.match != null) {
      // Mode edit: isi data lama
      _homeTeamId = widget.match!.homeTeamId;
      _awayTeamId = widget.match!.awayTeamId;
      _homeScoreController.text = widget.match!.homeScore.toString();
      _awayScoreController.text = widget.match!.awayScore.toString();
      _matchDate = widget.match!.date;
    }
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_homeTeamId == null || _awayTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kedua tim terlebih dahulu')),
      );
      return;
    }
    if (_homeTeamId == _awayTeamId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tim tuan rumah dan tamu tidak boleh sama')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    try {
      final match = MatchModel(
        id: widget.match?.id ?? '',
        homeTeamId: _homeTeamId!,
        awayTeamId: _awayTeamId!,
        homeScore: int.tryParse(_homeScoreController.text) ?? 0,
        awayScore: int.tryParse(_awayScoreController.text) ?? 0,
        date: _matchDate,
        isPlayed: true,
      );

      if (widget.match == null) {
        await matchProvider.addMatch(match);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertandingan berhasil ditambahkan')),
          );
        }
      } else {
        await matchProvider.updateMatch(match);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertandingan berhasil diperbarui')),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = Provider.of<TeamProvider>(context).teams;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match == null ? 'Tambah Pertandingan' : 'Edit Pertandingan'),
        backgroundColor: const Color(0xFF0A1020),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dropdown Tim Tuan Rumah
            DropdownButtonFormField<String>(
              value: _homeTeamId,
              decoration: const InputDecoration(labelText: 'Tim Tuan Rumah'),
              items: teams.map((t) {
                return DropdownMenuItem(value: t.id, child: Text(t.name));
              }).toList(),
              onChanged: (v) => setState(() => _homeTeamId = v),
              validator: (v) => v == null ? 'Pilih tim tuan rumah' : null,
            ),
            const SizedBox(height: 16),
            // Skor
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _homeScoreController,
                    decoration: const InputDecoration(labelText: 'Skor Tuan Rumah'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Skor harus angka' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _awayScoreController,
                    decoration: const InputDecoration(labelText: 'Skor Tim Tamu'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Skor harus angka' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown Tim Tamu
            DropdownButtonFormField<String>(
              value: _awayTeamId,
              decoration: const InputDecoration(labelText: 'Tim Tamu'),
              items: teams.map((t) {
                return DropdownMenuItem(value: t.id, child: Text(t.name));
              }).toList(),
              onChanged: (v) => setState(() => _awayTeamId = v),
              validator: (v) => v == null ? 'Pilih tim tamu' : null,
            ),
            const SizedBox(height: 16),
            // Pilih Tanggal
            ListTile(
              title: const Text('Tanggal Pertandingan'),
              subtitle: Text(DateFormat('dd MMM yyyy').format(_matchDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _matchDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _matchDate = picked);
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMatch,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.match == null ? 'Simpan Pertandingan' : 'Perbarui Pertandingan'),
            ),
          ],
        ),
      ),
    );
  }
}