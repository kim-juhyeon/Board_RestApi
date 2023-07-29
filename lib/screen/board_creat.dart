import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String subject = '';
  String content = '';
  String category = '';
  String fileNm = '';
  String fileOrgNm = '';
  File? _file;

  Future<bool> _uploadFile(String apiUrl, File? file) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final apiUrl = 'https://test.ahin07.com';
        var request =
            http.MultipartRequest('POST', Uri.parse('$apiUrl/api/board/file/'));

        request.fields['subject'] = subject;
        request.fields['content'] = content;
        request.fields['category'] = category;
        request.fields['fileNm'] = fileNm;
        request.fields['fileOrgNm'] = fileOrgNm;

        if (file != null) {
          request.files.add(http.MultipartFile.fromBytes(
              'board_file', File(file.path).readAsBytesSync(),
              filename: file.path.split('/').last,
              contentType: MediaType('multipart', 'form-data')));
        }

        request.headers.addAll({
          'Content-Type': 'multipart/form-data; charset=UTF-8',
        });

        var response = await request.send();

        if (response.statusCode == 200) {
          print("success");
          return true;
        } else {
          print("fail");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Subject', hintText: 'Enter'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please more Text';
                  }
                  return null;
                },
                onSaved: (value) {
                  subject = value!;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Content', hintText: "Enter"),
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  if (value.length < 5) {
                    return 'text is very short';
                  }
                  return null;
                },
                onSaved: (value) {
                  content = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'category', hintText: '2자리 이상, 5자리 이하 영문만 허용'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please more Text';
                  }
                  RegExp regExp = RegExp(r'^[a-zA-Z]{2,5}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Invalid input';
                  }
                  return null;
                },
                onSaved: (value) {
                  category = value!;
                },
              ),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text('Upload'),
              ),
              SizedBox(height: 10.0),
              if (_file != null)
                Text(
                  'Chosen File: ${_file!.path.split('/').last}',
                ),
              ElevatedButton(
                  onPressed: () async {
                    bool isSuccess =
                        await _uploadFile('https://test.ahin07.com', _file);
                    if (isSuccess) {
                      Navigator.pop(context,
                          true); // Return 'true' to indicate a new post was created.
                    }
                  },
                  child: Text('Submit'))
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
