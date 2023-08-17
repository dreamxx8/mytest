
import 'package:coinw_flutter/bean/follow/follow_statistic_item_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_tab_bar.dart';
import 'package:module_follow/common/chart_utils.dart';
import 'package:module_follow/home/child/widget/button/follow_select_time_widget.dart';
import 'package:module_follow/home/child/widget/stats_chart_widget.dart';

class StatsChartLine2Widget extends StatefulWidget {
  const StatsChartLine2Widget({Key? key, required this.leaderId}) : super(key: key);
  final String leaderId;
  @override
  State<StatsChartLine2Widget> createState() => _StatsChartLine2WidgetState();
}

class _StatsChartLine2WidgetState extends State<StatsChartLine2Widget> with SingleTickerProviderStateMixin, _StatsChartLine2WidgetBloc,AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if(_tabController.index ==_tabController.animation?.value) {
        _getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!_isInitialized){
      _isInitialized = true;
      _init();
    }
    return Container(
      decoration: RegularBorder(colorBorder: text_main2.withOpacity(0.1), backgroundColor: Colors.transparent, radius: 12.0),
      margin: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _titleWidget(),
          _tabBarView(),
        ],
      ),
    );
  }

  _titleWidget(){
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Row(
        children: [
          Expanded(child: SingleChildScrollView(
            child: _tabBar(),
          )),
          const SizedBox(width: 10,),
          _popupMenu(),
        ],
      ),
    );
  }
  Widget _popupMenu(){

    return PopupMenuButton<String>(
      offset:const Offset(20, 30),
      onSelected: (String value) {
        setState(() {
          _selectTitle = value;
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

  _tabBar() {
    return CustomTabBar(
      controller: _tabController,
      indicatorColor: Colors.transparent,
      fontSize: 14,
      tabs: _tabs.map((e) => Tab(text: e)).toList(),
      isScrollable: true,
      labelPadding: const EdgeInsets.only(right: 10),
    );
  }

  _tabBarView() {
    return Container(
      height: 200,
      child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: tabBarWidgets(),
        ),
    );
  }

  List<Widget> tabBarWidgets(){
    List<Widget> list = [];
    list.add(StatsChartWidget(_lineData1, mainColor: text_main2, rightTitleColor: text_main,));
    list.add(StatsChartWidget(_lineData2,mainColor: text_main2, rightTitleColor: text_main,));
    return list;
  }

  bool get wantKeepAlive => true;
}
mixin _StatsChartLine2WidgetBloc on State<StatsChartLine2Widget> {
  bool _isInitialized = false;
  late TabController _tabController;
  late List _tabs;
  LineData _lineData1 = LineData();
  LineData _lineData2 = LineData();
  //选择日期index
  late String _selectTitle;
  late List<String> _timeTitles;

  _init() {
    ///"跟单人数","跟单价值"
    _tabs = [S.of(context).follow_user_numbers,S.of(context).follow_be_worth];
    ///"近三天","近一周","近三周"
    _timeTitles = [S.of(context).follow_stats_three_day,S.of(context).otc_nearly_a_week,S.of(context).follow_three_week];
    _selectTitle = S.of(context).otc_nearly_a_week;
    _getData();
  }

  _getData(){
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.leaderId;
    //1 -按月份 分组 2-按年分组
    int date = 7;
    if(_selectTitle == S.of(context).follow_stats_three_day){
      date= 3;
    }else if(_selectTitle == S.of(context).follow_three_week){
      date = 21;
    }
    params["recentDay"] = date;
    params["queryKind"] = _tabController.index+4;
    httpClientContract.post<List<FollowStatisticItemEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_TRADER_STATISTIC,
        parameters: params,
        showErrorMessage: true,
        showLoading: true,
        onSuccess: (resp) {
          if(resp != null){
            _managerData(resp);
          }
        });
  }

  _managerData(List<FollowStatisticItemEntity> data){
    LineData lineData = managerChartData(data);
    setState(() {
      if(_tabController.index == 0){
        _lineData1 = lineData;
      }else{
        _lineData2 = lineData;
      }
    });
  }

}