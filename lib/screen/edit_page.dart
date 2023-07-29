import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:study/common/model/item_model.dart';
import 'package:http/http.dart' as http;
import 'package:study/providers/board_provider.dart';
import 'package:study/service/board_provider.dart';

Future<bool> updateBoard(int bbsSeq, String subject, String content,
    String category, File? file) async {
  const apiUrl = 'https://test.ahin07.com';

  var request =
      http.MultipartRequest('Put', Uri.parse('$apiUrl/api/board/file/$bbsSeq'));
  request.fields['subject'] = subject;
  request.fields['content'] = content;
  request.fields['category'] = category;

  if (file != null) {
    request.files.add(http.MultipartFile.fromBytes(
        'board_file', await File(file.path).readAsBytesSync(),
        filename: file.path.split('/').last,
        contentType: MediaType('multipart', 'from-data')));
  }

  request.headers.addAll({
    'Content-Type': 'multipart/form-data; charset=UTF-8',
  });

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error Code: ${response.statusCode}');
      print('Error Message: ${response.reasonPhrase}');
      return false;
    }
  } catch (e) {
    print('Exception: $e');
    return false;
  }
}

class EditDetailPage extends StatefulWidget {
  final Board board;

  EditDetailPage({Key? key, required this.board}) : super(key: key);

  @override
  _EditDetailPageState createState() => _EditDetailPageState();
}

class _EditDetailPageState extends State<EditDetailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _categoryController;
  File? _file;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.board.subject);
    _contentController = TextEditingController(text: widget.board.content);
    _categoryController = TextEditingController(text: widget.board.category);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Board? _board = Provider.of<BoradProvider>(context).board;
    return Scaffold(
      appBar: AppBar(
        title: Text('수정하기'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z0-9]{0,20}'),
                  ),
                ],
                decoration: InputDecoration(labelText: 'Subject'),
                validator: (value) =>
                    value == null || value.isEmpty ? '필수 입력 항목입니다.' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '필수 입력 항목입니다.' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z]{0,5}')),
                ],
                decoration: InputDecoration(labelText: 'category'),
                validator: (value) =>
                    value == null || value.isEmpty ? '필수 입력 항목입니다.' : null,
              ),
              SizedBox(
                height: 16.0,
              ),
              IconButton(
                icon: Icon(Icons.file_upload),
                onPressed: _pickFile,
              ),
              Text(
                '파일명: ${_file != null ? _file!.path.split('/').last : _board!.fileOrgNm ?? "파일을 추가해주세요."}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateBoard(
                      widget.board.bbsSeq!,
                      _titleController.text.trim(),
                      _contentController.text.trim(),
                      _categoryController.text.trim(),
                      _file,
                    ).then(
                      (result) {
                        if (result) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error Occured during update'),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
                child: Text('업데이트'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'pdf', 'doc', 'txt'],
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    } else {
      print('No file was picked');
    }
  }
}
