import 'package:flutter/material.dart';
import 'package:study/common/model/item_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum SortOrder { R, T, H }

class AppBarMenuButton extends StatefulWidget {
  final Function(String, List<Board>, int)
      onOrderChangedWithResult; //콜백함수 정렬버튼 누르고 새함수 호출

  AppBarMenuButton({Key? key, required this.onOrderChangedWithResult})
      : super(key: key);

  @override
  State<AppBarMenuButton> createState() => _AppBarMenuButtonState();
}

class _AppBarMenuButtonState extends State<AppBarMenuButton> {
  List<String> _sortOderNames = ['등록순', '제목순', '조회순'];
  SortOrder _currentSortOrder = SortOrder.R;
  final int _currentPage = 1;

  Future<List<Board>> _fetchSortedBoard(String orderText, int page) async {
    const apiUrl = 'https://test.ahin07.com';
    final response = await http.get(
      Uri.parse('$apiUrl/api/board?nowPage=$page&orderTxt=$orderText'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> listData = jsonResponse['resultMap']['list'];
      List<Board> boardList =
          listData.map<Board>((json) => Board.fromJson(json)).toList();

      return boardList;
    } else {
      throw Exception('Failed to fetch sorted board data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<SortOrder>(
        value: _currentSortOrder,
        onChanged: (SortOrder? newValue) {
          if (newValue != null) {
            setState(() {
              _currentSortOrder = newValue;
            });
            String orderTxt;
            switch (_currentSortOrder) {
              case SortOrder.R:
                orderTxt = 'R';
                break;
              case SortOrder.T:
                orderTxt = 'T';
                break;
              case SortOrder.H:
                orderTxt = 'H';
                break;
            }
            _fetchSortedBoard(orderTxt, _currentPage).then((value) {
              widget.onOrderChangedWithResult(orderTxt, value, _currentPage);
            });
          }
        },
        items: <DropdownMenuItem<SortOrder>>[
          DropdownMenuItem<SortOrder>(
            value: SortOrder.R,
            child: Text(_sortOderNames[0]),
          ),
          DropdownMenuItem<SortOrder>(
            value: SortOrder.T,
            child: Text(_sortOderNames[1]),
          ),
          DropdownMenuItem<SortOrder>(
            value: SortOrder.H,
            child: Text(_sortOderNames[2]),
          ),
        ],
      ),
    );
  }
}
