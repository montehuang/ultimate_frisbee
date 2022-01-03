/*
 * @Author: Monte
 * @Date: 2021-12-25
 * @Description: 
 */
import 'package:flutter/material.dart';

class UserStatsPage extends StatelessWidget {
  const UserStatsPage({Key? key, required this.statsData}) : super(key: key);
  final Map<String, dynamic> statsData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: Column(children: [
        SizedBox(
          height: 300,
          child: Column(
            children: [
              Card(
                color: Colors.white60,
                margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                child: Center(
                  child: Column(
                    children: [
                      const Text('已经看过的战术板', style:TextStyle(fontSize: 30),),
                      const SizedBox(height: 10.0,),
                      Builder(builder: (context) {
                        int seenNum = statsData['seen']!.toInt();
                        int total = statsData['total']!.toInt();
                        var viewedPercent =
                            (seenNum / total * 100).toStringAsFixed(1);
                        return Text(
                          '$viewedPercent %',
                          style: const TextStyle(
                              color: Colors.green, fontSize: 25, fontWeight: FontWeight.bold),
                        );
                      }),
                      const SizedBox(height: 10.0,),
                      Builder(builder: (context) {
                        int seenNum = statsData['seen']!.toInt();
                        int total = statsData['total']!.toInt();
                        return Text(
                          '$seenNum of $total plays',
                          style: const TextStyle(color: Colors.grey, fontSize: 18),
                        );
                      })
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
