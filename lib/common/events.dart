/*
 * @Author: Monte
 * @Date: 2022-01-04
 * @Description: 
 */
import 'package:flutter/material.dart';

abstract class Event {}

class BottomBarSelectIndexEvent extends Event {
  int index;

  BottomBarSelectIndexEvent(this.index);
}

class FieldItemMoveEvent extends Event {
  String fieldKey;
  Offset delta;
  FieldItemMoveEvent(this.fieldKey, this.delta);
}