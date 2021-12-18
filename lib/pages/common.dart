/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'package:flutter/material.dart';

class ViewPage extends StatelessWidget {
  const ViewPage({Key?key, required this.content, required this.icon, required this.header}):super(key: key);
  final String content;
  final IconData icon;
  final String header;
  
  @override
  Widget build(BuildContext context) {
    return Text(content);
  }
}