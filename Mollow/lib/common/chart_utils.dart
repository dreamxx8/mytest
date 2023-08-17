
import 'package:coinw_flutter/bean/follow/follow_statistic_item_entity.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_follow/home/child/widget/stats_chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
///
LineData managerChartData(List<FollowStatisticItemEntity> dataList, {bool isPercent = false}) {
  LineData lineData = LineData();
  List<FlSpot> datas = [];
  Map<int, String> xAxis = {};
  Map<int, String> yAxis = {};
  int minX = 0;
  int maxX = 0;
  double minY = 0;
  double maxY = 0;
  //单位，
  int uint = 1;
  //如果是百分数 所有value*100
  if(isPercent){
    for (var element in dataList) {
      if(element.value != null){
        element.value = element.value!.percent;
      }
    }
  }
  //获取Y最大值
  for (int i=0; i<dataList.length; i++) {
    FollowStatisticItemEntity element = dataList[i];
    if(element.date != null && element.value != null){
      double yValue = double.tryParse(element.value!) ?? 0;
      if(maxY < yValue || i ==0) maxY = yValue;
    }
  }
  uint =  getUnit(maxY.toString());
  maxY = 0;
  //数据封装
  for (int i=0; i<dataList.length; i++) {
    FollowStatisticItemEntity element = dataList[i];
    if(element.date != null && element.value != null){
      int xValue = i+1;
      double yValue = (double.tryParse(element.value!) ?? 0)/uint;
      FlSpot flSpot = FlSpot(xValue.toDouble(), yValue);
      datas.add(flSpot);
      xAxis[xValue] = _getMonthAndDay(element.date!, "MM/dd");
      yAxis[yValue.toInt()] = (element.value ?? "0").fixNumberTwoDecimal;
      if(minX >= xValue || i ==0) minX = xValue;
      if(maxX < xValue || i ==0) maxX = xValue;
      if(minY >= yValue || i ==0) minY = yValue;
      if(maxY < yValue || i ==0) maxY = yValue;
    }
  }
  if(minY == maxY && minY>0){
    minY = 0.0;
  }
  if(minY == maxY && minY<0){
    maxY = 0.0;
  }
  lineData.datas = datas;
  lineData.maxY = maxY;
  lineData.maxX = maxX.toDouble();
  lineData.minY = minY;
  lineData.minX = minX.toDouble();
  //删除多余x轴值，最多保留7个
  if(dataList.length > 7){
    List<FollowStatisticItemEntity> catchList = keepSevenElements<FollowStatisticItemEntity>(dataList);
    //xAxis.clear();
    Map<int, String> newxAxis = {};
    for (int i=0; i<catchList.length; i++){
      FollowStatisticItemEntity element = catchList[i];
      if(element.date != null && element.value != null){
        String dataValue = _getMonthAndDay(element.date!, "MM/dd");
        for (var key in xAxis.keys.toList()) {
          String cValue = xAxis[key] ?? "0";
          if(cValue == dataValue){
            newxAxis[key] = cValue;
            break;
          }
        }
      }
    }
    xAxis = newxAxis;
  }
  lineData.xAxis = xAxis;

  //删除多余压轴，最多保留3个
  Map<int, String> catchYAxis = {};
  if(dataList.length > 3){
    catchYAxis[maxY.toInt()] = (yAxis[maxY.toInt()] ?? "0");
    catchYAxis[minY.toInt()] = (yAxis[minY.toInt()] ?? "0");
    int midY = findClosestToAverage(yAxis.keys.toList());
    catchYAxis[midY] = (yAxis[midY] ?? "0");
    yAxis = catchYAxis;
  }
  if(isPercent){
    for (var key in yAxis.keys.toList()) {
      yAxis[key] = "${yAxis[key]}%";
    }
  }

  lineData.yAxis = yAxis;
  return lineData;
}

int findClosestToAverage(List<int> arr) {
  int sum = 0;
  for (int d in arr) {
    sum += d;
  }
  double avg = sum / arr.length;

  int closest = arr[0];
  int minDiff = (avg - arr[0]).abs().toInt();

  for (int d in arr) {
    int diff = (avg - d).abs().toInt();
    if (diff < minDiff) {
      closest = d;
      minDiff = diff;
    }
  }

  return closest;
}


List<T> keepSevenElements<T>(List<T> arr) {
  final n = arr.length;
  int max = 7;
  if (n <= max) {
    return arr;
  }

  final interval = (n / max).ceil();
  final result = <T>[];
  int count = 0;
  while(count < n){
    result.add(arr[count]);
    if(n-result.length > (max - result.length)){
      count += interval;
    }else{
      count++;
    }
  }

  return result;
}

//查询月份
String _getMonthAndDay(String dateStr, String format){
  DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
  var formatter = DateFormat(format);
  String formatted = formatter.format(date);
  return formatted;

}

int getUnit(String value){
  String fixString = value.fixNumberTwoDecimal;
  if(fixString.contains("K")){
    return 1000;
  }else if(fixString.contains("M")){
    return 1000000;
  }else if(fixString.contains("B")){
    return 1000000000;
  }
  return 1;
}
