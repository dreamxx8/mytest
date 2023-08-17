
import 'dart:core';
import 'dart:math';
import 'package:coinw_flutter/bean/follow/follow_statistic_item_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_follow/home/child/widget/button/follow_select_time_widget.dart';
import 'package:intl/intl.dart';

//概述柱状图
class OverViewChartWidget extends StatefulWidget {
  const OverViewChartWidget({Key? key, required this.leaderId}) : super(key: key);
  final String leaderId;

  @override
  State<OverViewChartWidget> createState() => _OverViewChartWidgetState();
}

class _OverViewChartWidgetState extends State<OverViewChartWidget> with AutomaticKeepAliveClientMixin{

  List<Map> data = [];
  double maxValue = 0;
  double columnarWidth = 0;
  List<FollowStatisticItemEntity> _dataList = [];
  //是否是月数据，默认月数据
  bool isMonth = true;
  //选择日期index
  late String _selectTitle;
  late List<String> _timeTitles;
  bool isInit = false;
  @override
  void initState() {
    super.initState();
    _managerData();
    columnarWidth =(ScreenUtil().screenWidth - 90)/data.length - 6 ;
    _getData();
  }

  _init(){
    _timeTitles = [S.of(context).follow_common_date_month,S.of(context).follow_common_date_year];
    _selectTitle = S.of(context).follow_common_date_month;
  }

  _managerData(){
    data.clear();
    DateTime lastDate = DateTime.now();
    int lastIndex = 0;
    for(int i=0;i<12;i++){
      FollowStatisticItemEntity? statistic;
      if(_dataList.length > i){
        statistic = _dataList[i];
      }
      String? month;
      double? value;
      if(statistic != null && statistic.date != null){
        DateTime date = _valueToDateTime(statistic.date!);
        lastDate = date;
        lastIndex = i;
        month = _getMonthAndYear(date, 0);
        value = double.tryParse(statistic.value ?? '0');
      }
      Map map = {};
      map["title"] = month ?? _getMonthAndYear(lastDate, i-lastIndex);
      map["value"] = value ?? 0.0;
      data.add(map);
      double valueAbs = map["value"].abs();
      if(maxValue<valueAbs){
        maxValue = valueAbs;
      }
    }
    if(maxValue == 0){
      maxValue = 1;
    }
    setState(() {});
  }


  //查询月份
  String _getMonthAndYear(DateTime now, int offset){
    if(isMonth){
      var lastMonth = now.month == 1
          ? DateTime(now.year + offset, 12, now.day)
          : DateTime(now.year, now.month + offset, now.day);
      var formatter = DateFormat('MM');
      String formatted = formatter.format(lastMonth);
      return formatted;
    }else{
      int year = now.year + offset;
      return year.toString().substring(2);
    }

  }

  DateTime _valueToDateTime(String time){
    DateTime dateTime = isMonth ? DateTime.parse(time + '-01') : DateTime.parse(time + '-01-01');
    return dateTime;
  }

  _getData(){
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.leaderId;
    //1 -按月份 分组 2-按年分组
    params["monthOrYear"] = isMonth ? 1 : 2;
    httpClientContract.post<List<FollowStatisticItemEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_MONTH_STATISTIC,
        parameters: params,
        showErrorMessage: true,
        showLoading: true,
        onSuccess: (resp) {
          if(resp != null){
            _dataList = resp;
            _managerData();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if(isInit == false){
      isInit = true;
      _init();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          _headerTitle(),
          SizedBox(height: 30,),
          _chartWidget()
        ],
      ),
    );
  }

  _chartWidget(){
    return Container(
      child: Row(
        children: [
          Expanded(child: _columnarWidget()),
          _graduationWidget()
        ],



      ),
    );
  }

  ///刻度
  _graduationWidget(){
    return Container(
      padding: EdgeInsets.only(bottom: 15,),
      width: 60,
      height: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${maxValue}".fixNumberTwoDecimal, style: StRegular(12, text_main2),),
          Text("0", style: StRegular(12, text_main2),),
          Text("-${maxValue}".fixNumberTwoDecimal, style: StRegular(12, text_main2),)
        ],
      ),
    );
  }

  //柱状图父
  _columnarWidget(){
    List<Widget> list = [];
    data.forEach((element) {
      list.add(_columnarElemnt(element["value"], element["title"]));
      list.add(SizedBox(width: 6,));
    });

    return Row(
      children: list,
    );
  }
  //柱状图子
  _columnarElemnt(double value, String title){
    double height = 60;
    double top = 70;
    //柱形高度
    double columnarheight = (value.abs()/maxValue)*height;
    if(value>0){
      top = top - columnarheight;
    }
    return Expanded(
      child: Container(
        height: height*2+40,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child:
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          text_main2.withAlpha(25),
                          text_main2.withAlpha(0),
                        ]
                      )
                    ),
                  )
                ),
                Expanded(child:
                Container(
                  height: height,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            text_main2.withAlpha(25),
                            text_main2.withAlpha(0),
                          ]
                      )
                  ),
                )
                ),
                const SizedBox(height: 6,),
                Text(title, style: StRegular(12, text_main2),)
              ],
            ),
            Positioned(
              top: top,
                child:Container(
                  height: columnarheight,
                  width: columnarWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(value>0?2:0),
                        topRight: Radius.circular(value>0?2:0),
                        bottomLeft: Radius.circular(value>0?0:2),
                        bottomRight: Radius.circular(value>0?0:2),
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            value>0? AppConfig.getRiseUpColor().withAlpha(153) : AppConfig.getRiseFallColor(),
                            value>0? AppConfig.getRiseUpColor() :  AppConfig.getRiseFallColor().withAlpha(153),
                          ]
                      )
                  ),
                )
            )
          ],
        ),
      ),
    );
  }



  _headerTitle(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ///数据表现
        Text(S.of(context).profit_over_data_show, style: StRegular(14, text_main),),
        _popupMenu(),
        // InkWell(
        //   onTap: (){
        //     setState(() {
        //       isMonth = !isMonth;
        //     });
        //     _getData();
        //   },
        //   ///"按月":"按年"
        //   child: FollowSelectTimeWidget(isMonth ? S.of(context).follow_common_date_month:S.of(context).follow_common_date_year),
        // )

      ],
    );
  }

  Widget _popupMenu(){

    return PopupMenuButton<String>(
      offset:const Offset(20, 30),
      onSelected: (String value) {
        setState(() {
          _selectTitle = value;
          isMonth = S.of(context).follow_common_date_month == value;
          _getData();
        });
      },
      itemBuilder: (BuildContext context) {
        return _timeTitles.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(value, style: StMedium(14, text_main),),
          );
        }).toList();
      },
      child: FollowSelectTimeWidget(_selectTitle),
    );
  }

  @override
  bool get wantKeepAlive => true;

}
