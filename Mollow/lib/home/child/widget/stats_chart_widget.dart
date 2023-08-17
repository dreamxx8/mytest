
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';

class LineData{
  //点数据
  List<FlSpot> datas = [FlSpot(1, 0),FlSpot(2, 0),FlSpot(3, 0)];
  //x轴坐标 最多7个
  Map<int, String> xAxis = {1:"0",2:"0",3:"0"};
  //x轴坐标 最多3个
  Map<int, String> yAxis = {1:"0",2:"0",3:"0"};

  double? minX;
  double? maxX;
  double? minY;
  double? maxY;
}


class StatsChartWidget extends StatefulWidget {
  Color mainColor;
  Color rightTitleColor;
  LineData data;
  StatsChartWidget(this.data, {Key? key, this.mainColor = color_drop, this.rightTitleColor = color_drop}) : super(key: key);

  @override
  State<StatsChartWidget> createState() => _StatsChartWidgetState();
}

class _StatsChartWidgetState extends State<StatsChartWidget> with AutomaticKeepAliveClientMixin {
 late List<Color> gradientColors;

  bool showAvg = false;

  @override
  void initState() {
    super.initState();
    gradientColors = [
      widget.mainColor,
      widget.mainColor
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 12,
            left: 12,
            top: 12,
            bottom: 5,
          ),
          child: LineChart(
            showAvg ? avgData() : mainData(),
          ),
        ),
        // SizedBox(
        //   width: 60,
        //   height: 34,
        //   child: TextButton(
        //     onPressed: () {
        //       setState(() {
        //         showAvg = !showAvg;
        //       });
        //     },
        //     child: Text(
        //       'avg',
        //       style: TextStyle(
        //         fontSize: 12,
        //         color: showAvg ?  widget.mainColor.withOpacity(0.5) :  widget.mainColor,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = StRegular(12, text_main2);
    Widget text;
    String? x = widget.data.xAxis[value.toInt()];
    if( x != null){
      text =  Text(x, style: style);
    }else{
      text = Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = StMedium(12,  widget.rightTitleColor);
    String? y = widget.data.yAxis[value];
    if(y!=null){
      return Text(y, style: style, textAlign: TextAlign.right);
    }
    return Container();

  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: transparent,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: transparent,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 60,
            ),),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: transparent),
      ),
      minX: widget.data.minX,
      maxX: widget.data.maxX,
      minY: widget.data.minY,
      maxY: widget.data.maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.data.datas,
          isCurved: true,
          curveSmoothness: 0,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.08))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color:  widget.mainColor.withAlpha(20),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color:  widget.mainColor.withAlpha(20),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles:AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 60,
            interval: 1,
          ),
        ),

      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color:  widget.mainColor.withAlpha(20)),
      ),
      minX: widget.data.minX,
      maxX: widget.data.maxX,
      minY: widget.data.minY,
      maxY: widget.data.maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.data.datas,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}


