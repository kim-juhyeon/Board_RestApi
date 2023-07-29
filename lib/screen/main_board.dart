import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/common/model/item_model.dart';
import 'package:study/screen/board_creat.dart';
import 'package:study/screen/board_detail.dart';
import 'package:study/screen/sub_screen/appbar_menubutton.dart';
import 'package:study/screen/sub_screen/board_dismissible.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ScrollController _scrollController = ScrollController();
  String _currentOrderTxt = 'R';
  late List<Board> _boardList = [];
  int _currentPage = 1;
  int _maxPage = 1;
  bool _isLoading = false;
  late List<Board> _searchResult = [];
//searchResult
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBoard(_currentPage); //현재 페이지 시작
  }

  void disposed() {
    _searchController.dispose();
    // _streamSearch.close();
    // _searchController.dispose();
  }

  Future<void> fetchBoard(
    int page, {
    bool clearList = false,
    String? searchQuery,
  }) async {
    if (_isLoading || _currentPage > _maxPage) return;
    _isLoading = true; //currentPage가 maxpage보다 클경우에는 데이터를 더 이상 가져올게 없음.

    const apiUrl = 'https://test.ahin07.com';
    final response = await http.get(
      Uri.parse(
          '$apiUrl/api/board?nowPage=$page&orderTxt=$_currentOrderTxt${searchQuery != null ? '&searchTxt=$searchQuery' : ''}'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> listData = jsonResponse['resultMap']['list'];
      //print('curpage : ${jsonResponse['resultMap']['nowPage']}');
      setState(() {
        _currentPage = page;
        _maxPage = jsonResponse['resultMap']['maxPage'];
        if (clearList) {
          _boardList.clear();
        }
        _boardList.addAll(listData
                .map<Board>((json) => Board.fromJson(json))
                .toList() //수정일 기준으로 비교해서 상단에 위치
            );
      });

      _isLoading = false;
    } else {
      throw Exception('exit');
    }
  }

//검색
  Future<void> _searchBoard(int page, String searchTxt) async {
    const apiUrl = 'https://test.ahin07.com';
    final response = await http
        .get(Uri.parse('$apiUrl/api/board?nowPage=$page&searchTxt=$searchTxt'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] ?? "") {
        List<Board> result = [];

        for (var boardJson in jsonResponse['boards']) {
          Board board = Board();
          board.subject = boardJson['subject'];
          result.add(board);
        }
        setState(() {
          _searchResult = result;
        });
      }
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
    fetchBoard(1, clearList: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API 연동 게시판'),
        actions: [
          AppBarMenuButton(
            onOrderChangedWithResult: (orderTxt, fetchedResults, page) {
              setState(() {
                _currentPage = page;
                _currentOrderTxt = orderTxt;
                // 현재 페이지를 리셋
                _boardList.clear(); // 이전 검색 결과를 제거
                _boardList.addAll(fetchedResults); // 새 검색 결과를 추가
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostPage(),
                ),
              );
              if (result != null && result == true) {
                fetchBoard(1, clearList: true); //page update.
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "검색어",
                    border: InputBorder.none,
                    icon: Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = false;
                    _currentPage = 1;
                    _boardList.clear(); //새로고침
                  });
                  if (_searchController.text.isEmpty) {
                    fetchBoard(_currentPage, clearList: true);
                  } else {
                    fetchBoard(
                      _currentPage,
                      clearList: true,
                      searchQuery: _searchController.text,
                    );
                  }
                },
                child: Text('검색'),
              ),
            ]),
            Expanded(
              child: StreamBuilder(
                initialData: "",
                builder: (context, snapshot) {
                  final query = snapshot.data?.toString() ?? "";
                  _searchResult = _boardList
                      .where((board) => board.subject!
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!_isLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        fetchBoard(_currentPage + 1,
                            searchQuery: _searchController.text);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _searchResult.length,
                      itemBuilder: (context, index) {
                        Board board = _searchResult[index];
                        return Dismissible(
                          key: ValueKey(board.bbsSeq),
                          background: Container(color: Colors.green),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (direction) async {
                            final bool? result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: const Text("확인"),
                                      content: const Text("해당 게시물을 삭제하시겠습니까?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("네"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("아니오"),
                                        )
                                      ]);
                                });
                            if (result != null && result) {
                              await deleteBoard(board.bbsSeq!);
                              setState(() {
                                _boardList.removeAt(index);
                              });
                            }
                            fetchBoard(1, clearList: true);
                            _scrollController.animateTo(0.0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                            return result;
                          },
                          child: ListTile(
                            title: Row(
                              children: [
                                Text("${board.bbsSeq}. ${board.subject!}"),
                                Spacer(),
                                Text("조회수 : ${board.hits}")
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                    "등록일: ${DateFormat('yy-MM-dd').format(DateTime.parse(board.regDt!))}"),
                                Spacer(),
                                Text(
                                    "수정일 : ${DateFormat('yy-MM-dd').format(DateTime.parse(board.updDt!))}"),
                              ],
                            ),
                            onTap: () async {
                              await hitsBoard(_boardList[index].bbsSeq!);
                              final editResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(bbsSeq: board.bbsSeq!),
                                ),
                              );
                              setState(() {
                                _boardList[index].hits =
                                    _boardList[index].hits! + 1;
                              });
                              //page update.
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
