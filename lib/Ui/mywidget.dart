import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class connectbtn extends StatelessWidget {
  String type;
  Color color;


  connectbtn({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 216,
        height: 216,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF06070A),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 50,
              spreadRadius: 3,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Text(
          '$type',
          style: TextStyle(
            color: color ,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class detail extends StatelessWidget {
  String name;
  String Value;


  detail({required this.name, required this.Value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      height: 94,
      decoration: BoxDecoration(
        color: Color(0xFF403737),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF808080)),
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.only(top: 10),
        child: Column(
          children: [
            Text(
              "$name",
              style: TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 13,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "$Value",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogWidget extends StatelessWidget {
  List<String>logs;
  LogWidget( {
    required this.logs
  });



  @override
  Widget build(BuildContext context) {
    print("dat $logs");
    return Container(
      width: 137,
      height: 137,
      padding: EdgeInsets.only(left: 14, top: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Color(0xFF403737),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF808080)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: Colors.white,
                size: 25,
              ),
              SizedBox(width: 5),
              Text(
                "LOGS",
                style: TextStyle(
                  color: Color(0xFFffffff),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(left: 5),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Color(0xFF902ED1),
                        ),
                        SizedBox(width: 4),
                        Text(
                          logs[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class aboutitem extends StatelessWidget {
  Icon icon;
  String title;
  String description;

  aboutitem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Color(0xFF403737),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Color(0xFF808080)),
          ),
          child: icon,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFffffff),
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFBDBDBD),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}