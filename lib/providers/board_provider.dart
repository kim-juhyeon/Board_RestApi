import 'package:flutter/cupertino.dart';
import 'package:study/common/model/item_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BoradProvider with ChangeNotifier {
  Board? _board;

  Board? get board => _board;

  Future<void> fetchDetail(int bbsSeq) async {
    const apiUrl = 'https://test.ahin07.com';
    final response = await http.get(Uri.parse('$apiUrl/api/board/$bbsSeq'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      _board = Board.fromJson(jsonResponse['resultMap']);
      notifyListeners();
    }
  }

  Future<void> deleteBoard(int id) async {
    const apiUrl = 'https://test.ahin07.com';
    final response = await http.delete(
      Uri.parse('$apiUrl/api/board/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('exit');
    }
  }

  Future<void> hitsBoard(int bbsSeq) async {
    const apiUrl = 'https://test.ahin07.com';
    final response =
        await http.post(Uri.parse('$apiUrl/api/board/hits/$bbsSeq'));

    if (response.statusCode != 200) {
      throw Exception('exit');
    }
  }

  Future<Board> getBoardById(int bbsSeq) async {
    const apiUrl = 'https://test.ahin07.com';
    final response = await http.get(Uri.parse('$apiUrl/api/board/$bbsSeq'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Board.fromJson(jsonResponse['resultMap']);
    } else {
      throw Exception('Failed to load board');
    }
  }
}
