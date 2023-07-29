class Board {
  final int? bbsSeq;
  String? subject;
  int? hits;
  final String? delYn;
  final String? regDt;
  final String? updDt;
  final String? content;
  final String? category;
  final String? fileNm;
  final String? fileOrgNm;

  Board({
    this.bbsSeq,
    this.subject,
    this.hits,
    this.delYn,
    this.regDt,
    this.updDt,
    this.content,
    this.category,
    this.fileNm,
    this.fileOrgNm,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      bbsSeq: json['bbsSeq'],
      subject: json['subject'],
      hits: json['hits'] ?? 0,
      delYn: json['delYn'],
      regDt: json['regDt'],
      updDt: json['updDt'],
      content: json['content'],
      category: json['category'],
      fileNm: json['fileNm'],
      fileOrgNm: json['fileOrgNm'],
    );
  }
}
