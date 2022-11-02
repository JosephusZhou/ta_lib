import 'package:ta_lib/src/m_integer.dart';
import 'package:ta_lib/ta_lib.dart';

void main(List<String> arguments) {
  List<double> close = [364.55999755859375, 376.4800109863281, 377.5, 366.92999267578125, 389.3999938964844, 412.5, 407.29998779296875, 404.25, 404.4200134277344, 379.75, 415.1000061035156, 445.4800109863281, 452.260009765625, 442.5, 448.75, 461.57000732421875, 460.94000244140625, 470.45001220703125, 446.3800048828125, 458.69000244140625, 480.739990234375, 476.7200012207031, 469.69000244140625, 506.8800048828125, 557.3900146484375, 606.8699951171875, 603.0599975585938, 567.0700073242188, 517.97998046875, 512.969970703125, 574.2100219726562, 614.4400024414062, 583.3900146484375, 595.0399780273438, 614.3200073242188, 577.9400024414062, 599.6199951171875, 589.52001953125, 552.5800170898438, 571.3400268554688, 556.6300048828125, 547.3699951171875, 588.3300170898438, 584.2100219726562, 587.1099853515625, 635.1900024414062, 641.1500244140625, 649.4500122070312, 635.8800048828125, 612.5700073242188, 634.2899780273438, 582.9000244140625, 592.3699951171875, 681.6500244140625, 727.4299926757812, 729.1199951171875, 750.3499755859375, 738.3300170898438, 973.6300048828125, 1038.7099609375, 1099.530029296875, 1208.719970703125, 1223.030029296875, 1180.47998046875, 1251.469970703125, 1084.1600341796875, 1046.18994140625, 1126.5999755859375, 1226.800048828125, 1154.0799560546875, 1229.25, 1254.02001953125, 1361.4000244140625, 1372.0899658203125, 1107.3399658203125, 1241.8599853515625, 1390.699951171875, 1315.0899658203125, 1364.8299560546875, 1237.1700439453125, 1330.760009765625, 1370.1700439453125, 2728.800048828125, 2500.800048828125, 2561.300048828125, 2468.89990234375, 2386.0, 2505.39990234375, 2536.300048828125, 2529.10009765625, 2415.60009765625, 2370.699951171875, 2185.39990234375, 2240.5, 1941.800048828125, 1894.4000244140625, 1913.199951171875, 1986.5999755859375, 1857.5999755859375, 1980.5, 2112.5, 2220.60009765625, 2241.10009765625, 2103.699951171875, 2085.39990234375, 2319.199951171875, 2243.5, 2323.0, 2326.89990234375, 2310.39990234375, 1977.5, 1915.800048828125, 1900.800048828125, 1889.300048828125, 1822.0999755859375, 1787.4000244140625, 1934.699951171875, 2021.800048828125, 2035.9000244140625, 2189.800048828125, 2360.699951171875, 2227.699951171875, 2308.10009765625, 2380.39990234375, 2427.60009765625, 2552.39990234375, 2599.10009765625, 2471.5, 2691.699951171875, 2825.5, 2907.10009765625, 3010.60009765625, 3145.199951171875, 3141.10009765625, 3247.10009765625, 3044.10009765625, 3275.0, 3308.0, 3173.10009765625, 3114.300048828125, 3005.10009765625, 3181.39990234375, 3261.699951171875, 3237.60009765625, 3306.199951171875, 3216.0, 3211.699951171875, 3090.39990234375, 3256.10009765625, 3222.300048828125, 3338.10009765625, 3413.199951171875, 3709.60009765625, 3783.699951171875, 3911.89990234375, 3947.39990234375, 3937.10009765625, 3403.60009765625, 3521.199951171875, 3422.10009765625, 3256.0, 3401.0, 3251.0, 3347.5, 3532.10009765625, 3565.199951171875, 3384.39990234375, 3325.300048828125, 3069.699951171875, 2883.39990234375, 3025.199951171875, 3151.10009765625, 2941.60009765625, 3057.699951171875, 2992.10009765625, 2833.699951171875, 2805.699951171875, 2996.199951171875, 3288.89990234375, 3416.800048828125, 3413.699951171875, 3486.5, 3585.199951171875, 3585.300048828125, 3552.39990234375, 3412.10009765625, 3512.39990234375, 3463.699951171875, 3518.60009765625, 3788.300048828125, 3868.199951171875, 3843.699951171875, 3743.89990234375, 3813.60009765625, 4098.2998046875, 4049.300048828125, 3982.60009765625, 4077.699951171875, 4179.2998046875, 4207.10009765625, 3997.89990234375, 4284.39990234375, 4400.5, 4286.10009765625, 4363.7001953125, 4510.2001953125, 4646.39990234375, 4531.89990234375, 4456.5, 4612.5, 4746.7998046875, 4746.89990234375, 4800.7001953125, 4716.39990234375, 4667.7998046875, 4621.7001953125, 4595.2998046875, 4264.10009765625, 4241.2998046875, 3993.39990234375, 4286.89990234375, 4257.7998046875, 4064.300048828125, 4324.89990234375, 4210.2001953125, 4521.7001953125, 4025.60009765625, 4294.2998046875, 4384.7998046875, 4663.39990234375, 4637.89990234375, 4509.5, 4312.89990234375, 4197.89990234375, 4194.2998046875, 4311.89990234375, 4380.7001953125, 4101.7001953125, 4029.199951171875, 4128.5, 3763.0, 3768.10009765625, 3936.89990234375, 3954.89990234375, 3849.800048828125, 3921.0, 3869.699951171875, 4005.199951171875, 3995.800048828125, 4108.7998046875, 4061.89990234375, 4061.199951171875, 4075.39990234375, 3804.300048828125, 3722.0, 3706.39990234375, 3642.5, 3826.300048828125, 3735.699951171875, 3807.300048828125, 3654.89990234375, 3402.5, 3215.5, 3149.0, 3024.699951171875, 3236.5, 3379.699951171875, 3239.10009765625, 3301.699951171875, 3346.300048828125, 3216.5, 3125.89990234375, 3126.800048828125, 2997.5, 2701.0, 2537.800048828125, 2270.60009765625, 2495.800048828125, 2610.5, 2400.60009765625, 2474.300048828125, 2599.800048828125, 2671.300048828125, 2751.10009765625, 2706.0, 2695.0, 2953.5, 3054.0, 3166.300048828125, 3051.0, 3246.699951171875, 3071.0, 2991.699951171875, 2869.39990234375, 2904.10009765625, 3106.800048828125, 3162.60009765625, 2889.800048828125, 2781.39990234375, 2618.699951171875, 2651.60009765625, 2611.5, 2631.10009765625, 2592.699951171875, 2716.0, 2805.800048828125, 2943.300048828125, 2929.89990234375, 2830.699951171875, 2616.800048828125, 2547.699951171875, 2524.699951171875, 2612.5, 2712.89990234375, 2604.199951171875, 2526.60009765625, 2513.10009765625, 2530.699951171875, 2656.60009765625, 2672.10009765625, 2810.800048828125, 2951.39990234375, 2859.199951171875, 2916.10009765625, 2982.89990234375, 2960.699951171875, 3108.5, 3123.300048828125, 3292.699951171875, 3408.300048828125, 3426.39990234375, 3392.0, 3278.800048828125, 3437.10009765625, 3519.5, 3487.699951171875, 3462.199951171875, 3222.800048828125, 3224.199951171875, 3245.800048828125, 3199.60009765625, 3001.89990234375, 2970.0, 3083.199951171875, 3018.89990234375, 3025.5, 2985.0, 3001.89990234375, 3108.39990234375, 3067.0, 2980.699951171875, 2966.300048828125, 2918.300048828125, 3009.10009765625, 2836.10009765625, 2849.0, 2934.0, 2805.0, 2822.0, 2836.5, 2770.199951171875, 2942.39990234375, 2744.10009765625, 2701.199951171875, 2515.0, 2267.60009765625, 2350.5, 2106.199951171875, 1951.300048828125, 2039.0999755859375, 2139.60009765625, 2002.199951171875, 2041.699951171875, 1976.0999755859375, 2014.0999755859375, 1956.0, 2038.300048828125, 2016.5, 1948.300048828125, 1790.0999755859375, 1746.9000244140625, 1811.199951171875, 1914.5999755859375, 1933.0999755859375, 1819.0, 1831.5999755859375, 1757.199951171875, 1804.199951171875, 1861.300048828125, 1844.800048828125, 1788.300048828125, 1786.5, 1679.0, 1432.800048828125, 1229.4000244140625, 1203.0999755859375, 1160.0999755859375, 1066.5, 1092.5, 1126.4000244140625, 1104.5999755859375, 1122.800048828125, 1069.199951171875, 1143.5, 1221.4000244140625, 1196.5, 1195.0999755859375, 1154.300048828125, 1116.4000244140625, 1069.5999755859375, 1069.800048828125, 1072.5, 1121.300048828125, 1145.0999755859375, 1151.5999755859375, 1236.0, 1242.4000244140625, 1167.199951171875, 1140.0999755859375, 1039.9000244140625, 1075.199951171875, 1192.0, 1257.4000244140625, 1337.5999755859375, 1471.0, 1560.0, 1551.0999755859375, 1574.9000244140625, 1520.800048828125, 1597.0, 1494.5, 1365.800048828125, 1586.9000244140625, 1724.5, 1729.9000244140625, 1678.300048828125, 1622.5, 1636.5999755859375, 1654.199951171875, 1607.5, 1678.5, 1699.9000244140625, 1782.9000244140625, 1687.800048828125, 1817.5999755859375, 1880.5, 1925.9000244140625, 1935.4000244140625, 1889.300048828125, 1879.0, 1837.800048828125, 1845.4000244140625, 1686.800048828125, 1617.300048828125, 1566.5, 1649.699951171875, 1677.9000244140625, 1694.800048828125, 1555.0999755859375, 1425.5, 1530.5999755859375, 1543.199951171875, 1574.699951171875, 1585.5999755859375, 1560.199951171875, 1578.699951171875, 1585.199951171875, 1575.800048828125, 1569.9000244140625, 1635.0, 1719.9000244140625, 1766.0999755859375, 1725.5999755859375, 1604.5999755859375, 1599.300048828125, 1472.0, 1436.5999755859375, 1334.0999755859375, 1362.0999755859375, 1351.4000244140625, 1322.5999755859375, 1325.9000244140625, 1303.5999755859375, 1294.300048828125, 1330.199951171875, 1324.0, 1333.199951171875, 1335.5999755859375, 1330.5999755859375, 1270.699951171875, 1317.5999755859375, 1354.0999755859375, 1350.699951171875, 1351.699951171875, 1331.199951171875, 1322.9000244140625, 1307.0, 1281.9000244140625, 1296.9000244140625, 1297.5];
  calculateMA(close, 5, 10, 20);
}

void calculateMA(List<double> dataList, int optInTimePeriod1, int optInTimePeriod2, int optInTimePeriod3) {

  int length = dataList.length;

  List<double> tempOutPut = List.filled(length, 0.0);

  MInteger outBegIdx = MInteger();
  MInteger outNBElement = MInteger();

  Core core = Core();

  RetCode retCode1 = core.sma(0, length - 1, dataList, optInTimePeriod1, outBegIdx, outNBElement, tempOutPut);
  if (RetCode.Success == retCode1) {
    int lookback1 = core.smaLookback(optInTimePeriod1);
    print("lookback1: $lookback1,\nMa$optInTimePeriod1:\n$tempOutPut");
  }

  tempOutPut = List.filled(length, 0.0);
  RetCode retCode2 = core.sma(0, length - 1, dataList, optInTimePeriod2, outBegIdx, outNBElement, tempOutPut);
  if (RetCode.Success == retCode2) {
    int lookback2 = core.smaLookback(optInTimePeriod2);
    print("lookback2: $lookback2,\nMa$optInTimePeriod2:\n$tempOutPut");
  }

  tempOutPut = List.filled(length, 0.0);
  RetCode retCode3 = core.sma(0, length - 1, dataList, optInTimePeriod3, outBegIdx, outNBElement, tempOutPut);
  if (RetCode.Success == retCode3) {
    int lookback3 = core.smaLookback(optInTimePeriod3);
    print("lookback3: $lookback3,\nMa$optInTimePeriod3:\n$tempOutPut");
  }
}
