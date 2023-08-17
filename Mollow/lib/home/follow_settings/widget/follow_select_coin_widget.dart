
import 'package:coinw_flutter/bean/follow/follow_setting_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

///选择更单币种弹窗
class FollowSelectCoinWidget extends StatefulWidget {

  FollowSelectCoinWidget({Key? key, this.followTrader, required this.selectList, this.callBack}) : super(key: key);
  FollowTraderEntity? followTrader;
  List<FollowCurrency> selectList;
  ValueChanged<List<FollowCurrency>>? callBack;

  static List<FollowCurrency> currencyList(String? jsonString){
    if (StringUtils.isBlank(jsonString)) {
      return [];
    }
    List list= json.decode(jsonString!);
    List<FollowCurrency> currency = list.map((json) => FollowCurrency.fromJson(json)).toList();
    return currency;
  }

  @override
  State<FollowSelectCoinWidget> createState() => _FollowSelectCoinWidgetState();
}

class _FollowSelectCoinWidgetState extends State<FollowSelectCoinWidget> {
  ///过滤后数据
  List<FollowCurrency> allList = [];
  double listHeight = 300;
  ///整合数据
  List<FollowCurrency> getCurrencyList() {
    List alljson= json.decode(widget.followTrader!.currencyJson!);
    List<FollowCurrency> allList = alljson.map((json) => FollowCurrency.fromJson(json)).toList();


    for (FollowCurrency currency in allList) {
      for (FollowCurrency selectCurrency in widget.selectList) {
        if(selectCurrency.currencyId == currency.currencyId){
          currency.selected = true;
          break;
        }
      }
    }

    return allList;
  }

  @override
  void initState() {
    super.initState();
    allList = getCurrencyList();
    if(allList.isNotEmpty){
      int row = (allList.length/3.0).ceil() + 1;
      listHeight = row * 47;
      listHeight = listHeight > 400 ? 400 : listHeight;
    }

  }

  List<FollowCurrency> _reloadFilter(){
    List<FollowCurrency> filterList = [];
    for (FollowCurrency currency in allList) {
      if(currency.selected == true){
        filterList.add(currency);
      }
    }
    return filterList;
  }


  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: listHeight + 130,
      decoration: BoxDecoration(
          color: globalColorManager.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _header(),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: listHeight,
            child: ListView(
              children: [
              Wrap(
              //mainAxisAlignment: MainAxisAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: allList.map((e){
                return _items(e);
              }).toList(),
            ),

              ],
            ),
          ),
          BigButton(text: S.of(context).common_confirm, onPressed: (){
              Navigator.pop(context);
              if(widget.callBack != null){
                widget.callBack!(_reloadFilter());
              }
          },)
        ],
      ),
    );
  }

  Widget _header(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// 跟单合约
        Text(S.of(context).follow_contract, style: StMedium(14, text_main),),
        InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 30, top: 5, bottom: 5),
            child: Image.asset(
              ImageSourceConst.LIVE_ALERT_CLOSE,
              width: 14,
              height: 14,
              color: globalColorManager.imageThemColor(),
            ),
          ),
        )
      ],
    );
  }

  Widget _items(FollowCurrency currency){
    if(currency.currencyName == null){
      return Container();
    }
    double width = (ScreenUtil().screenWidth -54)/3.0;
    return InkWell(
      onTap: (){
        currency.selected = !currency.selected;
        setState(() {});
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: RegularBorder(colorBorder: currency.selected ? colorTheme : text_main2.withOpacity(0.2), radius: 4, backgroundColor: currency.selected ? colorTheme : transparent),
        child: Center(child: Text('${currency.currencyName!}USDT', style: StRegular(14, currency.selected ? white : text_main),)),
      ),
    );
  }

}

class FollowCurrency {
  int? currencyId;
  String? currencyName;
  bool selected = false;

  FollowCurrency({this.currencyId, this.currencyName});

  factory FollowCurrency.fromJson(Map<String, dynamic> json) {
    return FollowCurrency(currencyId: json['currencyId'], currencyName: json['currencyName']);
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['currencyId'] = currencyId;
    data['currencyName'] = currencyName;
    return data;
  }

  @override
  String toString() {
    return '{currencyId: $currencyId, currencyName: $currencyName, selected: $selected}';
  }
}
