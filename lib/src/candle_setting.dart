import 'candle_setting_type.dart';
import 'range_type.dart';

class CandleSetting {

  late CandleSettingType settingType;
  late RangeType rangeType;
  late int avgPeriod;
  late double factor;

  CandleSetting(this.settingType, this.rangeType, this.avgPeriod, this.factor);

  CandleSetting.withThat(CandleSetting that) {
    settingType = that.settingType;
    rangeType = that.rangeType;
    avgPeriod = that.avgPeriod;
    factor = that.factor;
  }

  void copyFrom(CandleSetting src) {
    settingType = src.settingType;
    rangeType = src.rangeType;
    avgPeriod = src.avgPeriod;
    factor = src.factor;
  }
}