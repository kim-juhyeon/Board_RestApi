import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:study/common/model/item_model.dart';
import 'package:study/providers/board_provider.dart';
import 'package:study/screen/edit_page.dart';
import 'package:study/service/board_provider.dart';

class DetailPage extends StatefulWidget {
  final int bbsSeq;

  DetailPage({super.key, required this.bbsSeq});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Board? _board;

  @override
  void initState() {
    super.initState();
    Provider.of<BoradProvider>(context, listen: false)
        .fetchDetail(widget.bbsSeq);
  }

  @override
  Widget build(BuildContext context) {
    Board? _board = Provider.of<BoradProvider>(context).board;
    const apiUrl = "https://test.ahin07.com";

    Future<bool> _requestPermission(Permission permission) async {
      if (await permission.isGranted) {
        return true;
      }

      final result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }

      return false;
    }

    Future<void> _downloadAndOpenFile(String url, String fileName) async {
      try {
        if (await _requestPermission(Permission.storage)) {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String path = appDocDir.path;
          File file = File('$path/$fileName');
          var dio = Dio();
          var response = await dio.download(url, file.path,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              print(
                  "Files Download 진행중 : ${(received / total * 100).toStringAsFixed(0)}%");
            }
          });
          if (response.statusCode == 200) {
            OpenFile.open(file.path);
          } else {
            throw Exception('파일 다운로드에 실패했습니다.');
          }
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('내용'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              if (_board != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDetailPage(board: _board),
                  ),
                );
                if (result != null && result == true) {
                  Provider.of<BoradProvider>(context, listen: false)
                      .fetchDetail(widget.bbsSeq);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _board != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Category: ${_board.category}',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _board.subject!,
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.grey[600], size: 16.0),
                      SizedBox(width: 4.0),
                      Text(
                        '등록일: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(_board.updDt!))}',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    _board.content!,
                    style: TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 16.0),
                  _board.fileOrgNm != null
                      ? InkWell(
                          child: Row(
                            children: [
                              Icon(Icons.attach_file,
                                  color: Colors.blue, size: 16.0),
                              SizedBox(width: 4.0),
                              Text(
                                '파일명: ${_board.fileOrgNm}',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('파일 열기'),
                                    content: Text('파일을 여시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _downloadAndOpenFile(
                                              '$apiUrl${_board.fileNm}',
                                              _board.fileOrgNm!);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('확인'),
                                      ),
                                    ],
                                  );
                                });
                          },
                        )
                      : Container(),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오류',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
      ),
    );
  }
}
