import 'package:flutter/material.dart';
import 'package:study/common/model/item_model.dart';

class BoardListState extends ChangeNotifier {
  List<Board> _boards = [];
  List<Board> get boards => _boards;

  void setBoards(List<Board> boards) {
    _boards = boards;
    notifyListeners();
  }

  void addBoard(List<Board> board) {
    _boards.addAll(boards);
    notifyListeners();
  }

  void deleteBoard(int index) {
    _boards.removeAt(index);
    notifyListeners();
  }
}
