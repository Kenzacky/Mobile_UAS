import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/match.dart';

class AddEditMatchScreen extends StatefulWidget {
  final MatchModel? match;
  const AddEditMatchScreen({super.key, this.match});

  @override
  State<AddEditMatchScreen> createState() => _AddEditMatchScreenState();
}

class _AddEditMatchScreenState extends State<AddEditMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _homeTeamId;
  String? _awayTeamId;
  int _homeScore = 0;
  int _awayScore = 0;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.match != null) {
      _homeTeamId = widget.match!.homeTeamId;
      _awayTeamId = widget.match!.awayTeamId;
      _homeScore = widget.match!.homeScore;
      _awayScore = widget.match!.awayScore;
      _date = widget.match!.date;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_homeTeamId == _awayTeamId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tim tidak boleh sama')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    try {
      if (widget.match == null) {
        final newMatch = MatchModel(
          id: '',
          homeTeamId: _homeTeamId!,
          awayTeamId: _awayTeamId!,
          homeScore: _homeScore,
          awayScore: _awayScore,
          date: _date,
          isPlayed: true,
        );
        await matchProvider.addMatch(newMatch);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertandingan ditambahkan')),
          );
        }
      } else {
        final updatedMatch = MatchModel(
          id: widget.match!.id,
          homeTeamId: _homeTeamId!,
          awayTeamId: _awayTeamId!,
          homeScore: _homeScore,
          awayScore: _awayScore,
          date: _date,
          isPlayed: true,
        );
        await matchProvider.updateMatch(updatedMatch);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertandingan diperbarui')),
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _homeTeamId,
              decoration: const InputDecoration(labelText: 'Tim Tuan Rumah'),
              items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _homeTeamId = v),
              validator: (v) => v == null ? 'Pilih tim' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _awayTeamId,
              decoration: const InputDecoration(labelText: 'Tim Tamu'),
              items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _awayTeamId = v),
              validator: (v) => v == null ? 'Pilih tim' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _homeScore.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Skor Tuan Rumah'),
                    onChanged: (v) => _homeScore = int.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _awayScore.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Skor Tim Tamu'),
                    onChanged: (v) => _awayScore = int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Tanggal: ${_date.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMatch,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}