/*
 * @Author: Monte
 * @Date: 2022-01-04
 * @Description: 
 */
abstract class Event {}

class BottomBarSelectIndexEvent extends Event {
  int index;

  BottomBarSelectIndexEvent(this.index);
}