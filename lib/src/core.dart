import 'dart:math' as math;

import 'candle_setting.dart';
import 'candle_setting_type.dart';
import 'compatibility.dart';
import 'func_unst_id.dart';
import 'm_integer.dart';
import 'ma_type.dart';
import 'range_type.dart';
import 'ret_code.dart';

class Core {
  late List<int> _unstablePeriod;
  late List<CandleSetting> _candleSettings;
  late Compatibility _compatibility;
  late final List<CandleSetting> _taCandleDefaultSettings;

  Core() {
    _taCandleDefaultSettings = [
      CandleSetting(CandleSettingType.BodyLong, RangeType.RealBody, 10, 1.0),
      CandleSetting(
          CandleSettingType.BodyVeryLong, RangeType.RealBody, 10, 3.0),
      CandleSetting(CandleSettingType.BodyShort, RangeType.RealBody, 10, 1.0),
      CandleSetting(CandleSettingType.BodyDoji, RangeType.HighLow, 10, 0.1),
      CandleSetting(CandleSettingType.ShadowLong, RangeType.RealBody, 0, 1.0),
      CandleSetting(
          CandleSettingType.ShadowVeryLong, RangeType.RealBody, 0, 2.0),
      CandleSetting(CandleSettingType.ShadowShort, RangeType.Shadows, 10, 1.0),
      CandleSetting(
          CandleSettingType.ShadowVeryShort, RangeType.HighLow, 10, 0.1),
      CandleSetting(CandleSettingType.Near, RangeType.HighLow, 5, 0.2),
      CandleSetting(CandleSettingType.Far, RangeType.HighLow, 5, 0.6),
      CandleSetting(CandleSettingType.Equal, RangeType.HighLow, 5, 0.05)
    ];
    _unstablePeriod = List.filled(FuncUnstId.values.length, 0);
    _compatibility = Compatibility.Default;
    _candleSettings =
        List.generate(CandleSettingType.AllCandleSettings.index, (index) {
          return CandleSetting.withThat(_taCandleDefaultSettings[index]);
        }, growable: false);
  }

  RetCode setCandleSettings(CandleSettingType settingType, RangeType rangeType,
      int avgPeriod, double factor) {
    if (settingType.index >= CandleSettingType.AllCandleSettings.index) {
      return RetCode.BadParam;
    } else {
      _candleSettings[settingType.index].settingType = settingType;
      _candleSettings[settingType.index].rangeType = rangeType;
      _candleSettings[settingType.index].avgPeriod = avgPeriod;
      _candleSettings[settingType.index].factor = factor;
      return RetCode.Success;
    }
  }

  RetCode restoreCandleDefaultSettings(CandleSettingType settingType) {
    if (settingType.index > CandleSettingType.AllCandleSettings.index) {
      return RetCode.BadParam;
    } else {
      if (settingType == CandleSettingType.AllCandleSettings) {
        for (int i = 0; i < CandleSettingType.AllCandleSettings.index; ++i) {
          _candleSettings[i].copyFrom(_taCandleDefaultSettings[i]);
        }
      } else {
        _candleSettings[settingType.index]
            .copyFrom(_taCandleDefaultSettings[settingType.index]);
      }
      return RetCode.Success;
    }
  }

  RetCode setUnstablePeriod(FuncUnstId id, int period) {
    if (id.index >= FuncUnstId.All.index) {
      return RetCode.BadParam;
    } else {
      _unstablePeriod[id.index] = period;
      return RetCode.Success;
    }
  }

  int getUnstablePeriod(FuncUnstId id) {
    return _unstablePeriod[id.index];
  }

  void setCompatibility(Compatibility compatibility) {
    _compatibility = compatibility;
  }

  Compatibility getCompatibility() {
    return _compatibility;
  }

  int acosLookback() {
    return 0;
  }

  RetCode acos(int startIdx, int endIdx, List<double> inReal,
      MInteger outBegIdx, MInteger outNBElement, List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int i = startIdx;

      int outIdx;
      for (outIdx = 0; i <= endIdx; ++outIdx) {
        outReal[outIdx] = math.acos(inReal[i]);
        ++i;
      }

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int adLookback() {
    return 0;
  }

  RetCode ad(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      List<double> inVolume,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int nbBar = endIdx - startIdx + 1;
      outNBElement.value = nbBar;
      outBegIdx.value = startIdx;
      int currentBar = startIdx;
      int outIdx = 0;

      for (double ad = 0.0; nbBar != 0; --nbBar) {
        double high = inHigh[currentBar];
        double low = inLow[currentBar];
        double tmp = high - low;
        double close = inClose[currentBar];
        if (tmp > 0.0) {
          ad += (close - low - (high - close)) / tmp * inVolume[currentBar];
        }

        outReal[outIdx++] = ad;
        ++currentBar;
      }

      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int addLookback() {
    return 0;
  }

  RetCode add(int startIdx,
      int endIdx,
      List<double> inReal0,
      List<double> inReal1,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int i = startIdx;

      int outIdx;
      for (outIdx = 0; i <= endIdx; ++outIdx) {
        outReal[outIdx] = inReal0[i] + inReal1[i];
        ++i;
      }

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int adOscLookback(int optInFastPeriod, int optInSlowPeriod) {
    if (optInFastPeriod < 2 || optInFastPeriod > 100000) {
      return -1;
    }

    if (optInSlowPeriod < 2 || optInSlowPeriod > 100000) {
      return -1;
    }

    int slowestPeriod;
    if (optInFastPeriod < optInSlowPeriod) {
      slowestPeriod = optInSlowPeriod;
    } else {
      slowestPeriod = optInFastPeriod;
    }

    return emaLookback(slowestPeriod);
  }

  RetCode adOsc(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      List<double> inVolume,
      int optInFastPeriod,
      int optInSlowPeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInFastPeriod < 2 || optInFastPeriod > 100000) {
        return RetCode.BadParam;
      }

      if (optInSlowPeriod < 2 || optInSlowPeriod > 100000) {
        return RetCode.BadParam;
      }

      int slowestPeriod;
      if (optInFastPeriod < optInSlowPeriod) {
        slowestPeriod = optInSlowPeriod;
      } else {
        slowestPeriod = optInFastPeriod;
      }

      int lookbackTotal = emaLookback(slowestPeriod);
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        outBegIdx.value = startIdx;
        int today = startIdx - lookbackTotal;
        double ad = 0.0;
        double fastk = 2.0 / (optInFastPeriod + 1);
        double oneMinusFastk = 1.0 - fastk;
        double slowk = 2.0 / (optInSlowPeriod + 1);
        double oneMinusSlowk = 1.0 - slowk;
        double high = inHigh[today];
        double low = inLow[today];
        double tmp = high - low;
        double close = inClose[today];
        if (tmp > 0.0) {
          ad += (close - low - (high - close)) / tmp * inVolume[today];
        }

        ++today;
        double fastEMA = ad;

        double slowEMA;
        for (slowEMA = ad;
        today < startIdx;
        slowEMA = slowk * ad + oneMinusSlowk * slowEMA) {
          high = inHigh[today];
          low = inLow[today];
          tmp = high - low;
          close = inClose[today];
          if (tmp > 0.0) {
            ad += (close - low - (high - close)) / tmp * inVolume[today];
          }

          ++today;
          fastEMA = fastk * ad + oneMinusFastk * fastEMA;
        }

        int outIdx;
        for (outIdx = 0;
        today <= endIdx;
        outReal[outIdx++] = fastEMA - slowEMA) {
          high = inHigh[today];
          low = inLow[today];
          tmp = high - low;
          close = inClose[today];
          if (tmp > 0.0) {
            ad += (close - low - (high - close)) / tmp * inVolume[today];
          }

          ++today;
          fastEMA = fastk * ad + oneMinusFastk * fastEMA;
          slowEMA = slowk * ad + oneMinusSlowk * slowEMA;
        }

        outNBElement.value = outIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int adxLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return 2 * optInTimePeriod + _unstablePeriod[FuncUnstId.Adx.index] - 1;
  }

  RetCode adx(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      int lookbackTotal =
          2 * optInTimePeriod + _unstablePeriod[FuncUnstId.Adx.index] - 1;
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        outBegIdx.value = startIdx;
        double prevMinusDM = 0.0;
        double prevPlusDM = 0.0;
        double prevTR = 0.0;
        int today = startIdx - lookbackTotal;
        double prevHigh = inHigh[today];
        double prevLow = inLow[today];
        double prevClose = inClose[today];

        double tempReal;
        double tempReal2;
        double diffP;
        double diffM;
        int var41;
        for (var41 = optInTimePeriod - 1;
        var41-- > 0;
        prevClose = inClose[today]) {
          ++today;
          tempReal = inHigh[today];
          diffP = tempReal - prevHigh;
          prevHigh = tempReal;
          tempReal = inLow[today];
          diffM = prevLow - tempReal;
          prevLow = tempReal;
          if (diffM > 0.0 && diffP < diffM) {
            prevMinusDM += diffM;
          } else if (diffP > 0.0 && diffP > diffM) {
            prevPlusDM += diffP;
          }

          tempReal = prevHigh - tempReal;
          tempReal2 = (prevHigh - prevClose).abs();
          if (tempReal2 > tempReal) {
            tempReal = tempReal2;
          }

          tempReal2 = (prevLow - prevClose).abs();
          if (tempReal2 > tempReal) {
            tempReal = tempReal2;
          }

          prevTR += tempReal;
        }

        double sumDX = 0.0;
        var41 = optInTimePeriod;

        while (true) {
          double minusDI;
          double plusDI;
          do {
            do {
              if (var41-- <= 0) {
                double prevADX = sumDX / optInTimePeriod;
                var41 = _unstablePeriod[FuncUnstId.Adx.index];

                while (true) {
                  do {
                    do {
                      if (var41-- <= 0) {
                        outReal[0] = prevADX;

                        int outIdx;
                        for (outIdx = 1;
                        today < endIdx;
                        outReal[outIdx++] = prevADX) {
                          ++today;
                          tempReal = inHigh[today];
                          diffP = tempReal - prevHigh;
                          prevHigh = tempReal;
                          tempReal = inLow[today];
                          diffM = prevLow - tempReal;
                          prevLow = tempReal;
                          prevMinusDM /= optInTimePeriod;
                          prevPlusDM /= optInTimePeriod;
                          if (diffM > 0.0 && diffP < diffM) {
                            prevMinusDM += diffM;
                          } else if (diffP > 0.0 && diffP > diffM) {
                            prevPlusDM += diffP;
                          }

                          tempReal = prevHigh - tempReal;
                          tempReal2 = (prevHigh - prevClose).abs();
                          if (tempReal2 > tempReal) {
                            tempReal = tempReal2;
                          }

                          tempReal2 = (prevLow - prevClose).abs();
                          if (tempReal2 > tempReal) {
                            tempReal = tempReal2;
                          }

                          prevTR = prevTR - prevTR / optInTimePeriod + tempReal;
                          prevClose = inClose[today];
                          if (!(-1.0E-8 < prevTR) || !(prevTR < 1.0E-8)) {
                            minusDI = 100.0 * (prevMinusDM / prevTR);
                            plusDI = 100.0 * (prevPlusDM / prevTR);
                            tempReal = minusDI + plusDI;
                            if (!(-1.0E-8 < tempReal) || !(tempReal < 1.0E-8)) {
                              tempReal =
                                  100.0 * ((minusDI - plusDI).abs() / tempReal);
                              prevADX =
                                  (prevADX * (optInTimePeriod - 1) + tempReal) /
                                      optInTimePeriod;
                            }
                          }
                        }

                        outNBElement.value = outIdx;
                        return RetCode.Success;
                      }

                      ++today;
                      tempReal = inHigh[today];
                      diffP = tempReal - prevHigh;
                      prevHigh = tempReal;
                      tempReal = inLow[today];
                      diffM = prevLow - tempReal;
                      prevLow = tempReal;
                      prevMinusDM /= optInTimePeriod;
                      prevPlusDM /= optInTimePeriod;
                      if (diffM > 0.0 && diffP < diffM) {
                        prevMinusDM += diffM;
                      } else if (diffP > 0.0 && diffP > diffM) {
                        prevPlusDM += diffP;
                      }

                      tempReal = prevHigh - tempReal;
                      tempReal2 = (prevHigh - prevClose).abs();
                      if (tempReal2 > tempReal) {
                        tempReal = tempReal2;
                      }

                      tempReal2 = (prevLow - prevClose).abs();
                      if (tempReal2 > tempReal) {
                        tempReal = tempReal2;
                      }

                      prevTR = prevTR - prevTR / optInTimePeriod + tempReal;
                      prevClose = inClose[today];
                    } while (-1.0E-8 < prevTR && prevTR < 1.0E-8);

                    minusDI = 100.0 * (prevMinusDM / prevTR);
                    plusDI = 100.0 * (prevPlusDM / prevTR);
                    tempReal = minusDI + plusDI;
                  } while (-1.0E-8 < tempReal && tempReal < 1.0E-8);

                  tempReal = 100.0 * ((minusDI - plusDI).abs() / tempReal);
                  prevADX = (prevADX * (optInTimePeriod - 1) + tempReal) /
                      optInTimePeriod;
                }
              }

              ++today;
              tempReal = inHigh[today];
              diffP = tempReal - prevHigh;
              prevHigh = tempReal;
              tempReal = inLow[today];
              diffM = prevLow - tempReal;
              prevLow = tempReal;
              prevMinusDM /= optInTimePeriod;
              prevPlusDM /= optInTimePeriod;
              if (diffM > 0.0 && diffP < diffM) {
                prevMinusDM += diffM;
              } else if (diffP > 0.0 && diffP > diffM) {
                prevPlusDM += diffP;
              }

              tempReal = prevHigh - tempReal;
              tempReal2 = (prevHigh - prevClose).abs();
              if (tempReal2 > tempReal) {
                tempReal = tempReal2;
              }

              tempReal2 = (prevLow - prevClose).abs();
              if (tempReal2 > tempReal) {
                tempReal = tempReal2;
              }

              prevTR = prevTR - prevTR / optInTimePeriod + tempReal;
              prevClose = inClose[today];
            } while (-1.0E-8 < prevTR && prevTR < 1.0E-8);

            minusDI = 100.0 * (prevMinusDM / prevTR);
            plusDI = 100.0 * (prevPlusDM / prevTR);
            tempReal = minusDI + plusDI;
          } while (-1.0E-8 < tempReal && tempReal < 1.0E-8);

          sumDX += 100.0 * ((minusDI - plusDI).abs() / tempReal);
        }
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int adxrLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    if (optInTimePeriod > 1) {
      return optInTimePeriod + adxLookback(optInTimePeriod) - 1;
    } else {
      return 3;
    }
  }

  RetCode adxr(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      int adxrLookback = this.adxrLookback(optInTimePeriod);
      if (startIdx < adxrLookback) {
        startIdx = adxrLookback;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        List<double> adx =
        List.filled(endIdx - startIdx + optInTimePeriod, double.nan);
        RetCode retCode = this.adx(
            startIdx - (optInTimePeriod - 1),
            endIdx,
            inHigh,
            inLow,
            inClose,
            optInTimePeriod,
            outBegIdx,
            outNBElement,
            adx);
        if (retCode != RetCode.Success) {
          return retCode;
        } else {
          int i = optInTimePeriod - 1;
          int j = 0;
          int outIdx = 0;
          int nbElement = endIdx - startIdx + 2;

          while (true) {
            --nbElement;
            if (nbElement == 0) {
              outBegIdx.value = startIdx;
              outNBElement.value = outIdx;
              return RetCode.Success;
            }

            outReal[outIdx++] = (adx[i++] + adx[j++]) / 2.0;
          }
        }
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int apoLookback(int optInFastPeriod, int optInSlowPeriod,
      MAType optInMAType) {
    if (optInFastPeriod < 2 || optInFastPeriod > 100000) {
      return -1;
    }

    if (optInSlowPeriod < 2 || optInSlowPeriod > 100000) {
      return -1;
    }

    return movingAverageLookback(
        optInSlowPeriod > optInFastPeriod ? optInSlowPeriod : optInFastPeriod,
        optInMAType);
  }

  RetCode apo(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInFastPeriod,
      int optInSlowPeriod,
      MAType optInMAType,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInFastPeriod < 2 || optInFastPeriod > 100000) {
        return RetCode.BadParam;
      }

      if (optInSlowPeriod < 2 || optInSlowPeriod > 100000) {
        return RetCode.BadParam;
      }

      List<double> tempBuffer = List.filled(endIdx - startIdx + 1, double.nan);
      RetCode retCode = _taIntPo(
          startIdx,
          endIdx,
          inReal,
          optInFastPeriod,
          optInSlowPeriod,
          optInMAType,
          outBegIdx,
          outNBElement,
          outReal,
          tempBuffer,
          0);
      return retCode;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  RetCode _taIntPo(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInFastPeriod,
      int optInSlowPeriod,
      MAType optInMethod_2,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal,
      List<double> tempBuffer,
      int doPercentageOutput) {
    MInteger outBegIdx1 = MInteger();
    MInteger outNbElement1 = MInteger();
    MInteger outBegIdx2 = MInteger();
    MInteger outNbElement2 = MInteger();
    int tempInteger;
    if (optInSlowPeriod < optInFastPeriod) {
      tempInteger = optInSlowPeriod;
      optInSlowPeriod = optInFastPeriod;
      optInFastPeriod = tempInteger;
    }

    RetCode retCode = movingAverage(
        startIdx,
        endIdx,
        inReal,
        optInFastPeriod,
        optInMethod_2,
        outBegIdx2,
        outNbElement2,
        tempBuffer);
    if (retCode == RetCode.Success) {
      retCode = movingAverage(
          startIdx,
          endIdx,
          inReal,
          optInSlowPeriod,
          optInMethod_2,
          outBegIdx1,
          outNbElement1,
          outReal);
      if (retCode == RetCode.Success) {
        tempInteger = outBegIdx1.value - outBegIdx2.value;
        int i;
        int j;
        if (doPercentageOutput == 0) {
          i = 0;

          for (j = tempInteger; i < outNbElement1.value; ++j) {
            outReal[i] = tempBuffer[j] - outReal[i];
            ++i;
          }
        } else {
          i = 0;

          for (j = tempInteger; i < outNbElement1.value; ++j) {
            double tempReal = outReal[i];
            if (-1.0E-8 < tempReal && tempReal < 1.0E-8) {
              outReal[i] = 0.0;
            } else {
              outReal[i] = (tempBuffer[j] - tempReal) / tempReal * 100.0;
            }

            ++i;
          }
        }

        outBegIdx.value = outBegIdx1.value;
        outNBElement.value = outNbElement1.value;
      }
    }

    if (retCode != RetCode.Success) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
    }

    return retCode;
  }

  int aroonLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod;
  }

  RetCode aroon(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outAroonDown,
      List<double> outAroonUp) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (startIdx < optInTimePeriod) {
        startIdx = optInTimePeriod;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        int outIdx = 0;
        int today = startIdx;
        int trailingIdx = startIdx - optInTimePeriod;
        int lowestIdx = -1;
        int highestIdx = -1;
        double lowest = 0.0;
        double highest = 0.0;

        for (double factor = 100.0 / optInTimePeriod;
        today <= endIdx;
        ++today) {
          double tmp = inLow[today];
          int i;
          if (lowestIdx < trailingIdx) {
            lowestIdx = trailingIdx;
            lowest = inLow[trailingIdx];
            i = trailingIdx;

            while (true) {
              ++i;
              if (i > today) {
                break;
              }

              tmp = inLow[i];
              if (tmp <= lowest) {
                lowestIdx = i;
                lowest = tmp;
              }
            }
          } else if (tmp <= lowest) {
            lowestIdx = today;
            lowest = tmp;
          }

          tmp = inHigh[today];
          if (highestIdx < trailingIdx) {
            highestIdx = trailingIdx;
            highest = inHigh[trailingIdx];
            i = trailingIdx;

            while (true) {
              ++i;
              if (i > today) {
                break;
              }

              tmp = inHigh[i];
              if (tmp >= highest) {
                highestIdx = i;
                highest = tmp;
              }
            }
          } else if (tmp >= highest) {
            highestIdx = today;
            highest = tmp;
          }

          outAroonUp[outIdx] =
              factor * (optInTimePeriod - (today - highestIdx));
          outAroonDown[outIdx] =
              factor * (optInTimePeriod - (today - lowestIdx));
          ++outIdx;
          ++trailingIdx;
        }

        outBegIdx.value = startIdx;
        outNBElement.value = outIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int aroonOscLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod;
  }

  RetCode aroonOsc(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (startIdx < optInTimePeriod) {
        startIdx = optInTimePeriod;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        int outIdx = 0;
        int today = startIdx;
        int trailingIdx = startIdx - optInTimePeriod;
        int lowestIdx = -1;
        int highestIdx = -1;
        double lowest = 0.0;
        double highest = 0.0;

        for (double factor = 100.0 / optInTimePeriod;
        today <= endIdx;
        ++today) {
          double tmp = inLow[today];
          int i;
          if (lowestIdx < trailingIdx) {
            lowestIdx = trailingIdx;
            lowest = inLow[trailingIdx];
            i = trailingIdx;

            while (true) {
              ++i;
              if (i > today) {
                break;
              }

              tmp = inLow[i];
              if (tmp <= lowest) {
                lowestIdx = i;
                lowest = tmp;
              }
            }
          } else if (tmp <= lowest) {
            lowestIdx = today;
            lowest = tmp;
          }

          tmp = inHigh[today];
          if (highestIdx < trailingIdx) {
            highestIdx = trailingIdx;
            highest = inHigh[trailingIdx];
            i = trailingIdx;

            while (true) {
              ++i;
              if (i > today) {
                break;
              }

              tmp = inHigh[i];
              if (tmp >= highest) {
                highestIdx = i;
                highest = tmp;
              }
            }
          } else if (tmp >= highest) {
            highestIdx = today;
            highest = tmp;
          }

          double aroon = factor * (highestIdx - lowestIdx);
          outReal[outIdx] = aroon;
          ++outIdx;
          ++trailingIdx;
        }

        outBegIdx.value = startIdx;
        outNBElement.value = outIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int asinLookback() {
    return 0;
  }

  RetCode asin(int startIdx, int endIdx, List<double> inReal,
      MInteger outBegIdx, MInteger outNBElement, List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int i = startIdx;

      int outIdx;
      for (outIdx = 0; i <= endIdx; ++outIdx) {
        outReal[outIdx] = math.asin(inReal[i]);
        ++i;
      }

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int atanLookback() {
    return 0;
  }

  RetCode atan(int startIdx, int endIdx, List<double> inReal,
      MInteger outBegIdx, MInteger outNBElement, List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int i = startIdx;

      int outIdx;
      for (outIdx = 0; i <= endIdx; ++outIdx) {
        outReal[outIdx] = math.atan(inReal[i]);
        ++i;
      }

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int atrLookback(int optInTimePeriod) {
    if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod + _unstablePeriod[FuncUnstId.Atr.index];
  }

  RetCode atr(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    MInteger outBegIdx1 = MInteger();
    MInteger outNbElement1 = MInteger();
    List<double> prevATRTemp = [double.nan];
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      outBegIdx.value = 0;
      outNBElement.value = 0;
      int lookbackTotal = atrLookback(optInTimePeriod);
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        return RetCode.Success;
      } else if (optInTimePeriod <= 1) {
        return trueRange(
            startIdx,
            endIdx,
            inHigh,
            inLow,
            inClose,
            outBegIdx,
            outNBElement,
            outReal);
      } else {
        List<double> tempBuffer =
        List.filled(lookbackTotal + (endIdx - startIdx) + 1, double.nan);
        RetCode retCode = trueRange(
            startIdx - lookbackTotal + 1,
            endIdx,
            inHigh,
            inLow,
            inClose,
            outBegIdx1,
            outNbElement1,
            tempBuffer);
        if (retCode != RetCode.Success) {
          return retCode;
        } else {
          retCode = _taIntSma(
              optInTimePeriod - 1,
              optInTimePeriod - 1,
              tempBuffer,
              optInTimePeriod,
              outBegIdx1,
              outNbElement1,
              prevATRTemp);
          if (retCode != RetCode.Success) {
            return retCode;
          } else {
            double prevATR = prevATRTemp[0];
            int today = optInTimePeriod;

            int outIdx;
            for (outIdx = _unstablePeriod[FuncUnstId.Atr.index];
            outIdx != 0;
            --outIdx) {
              prevATR *= (optInTimePeriod - 1);
              prevATR += tempBuffer[today++];
              prevATR /= optInTimePeriod;
            }

            outIdx = 1;
            outReal[0] = prevATR;
            int nbATR = endIdx - startIdx + 1;

            while (true) {
              --nbATR;
              if (nbATR == 0) {
                outBegIdx.value = startIdx;
                outNBElement.value = outIdx;
                return retCode;
              }

              prevATR *= (optInTimePeriod - 1);
              prevATR += tempBuffer[today++];
              prevATR /= optInTimePeriod;
              outReal[outIdx++] = prevATR;
            }
          }
        }
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int avgPriceLookback() {
    return 0;
  }

  RetCode avgPrice(int startIdx,
      int endIdx,
      List<double> inOpen,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int outIdx = 0;

      for (int i = startIdx; i <= endIdx; ++i) {
        outReal[outIdx++] =
            (inHigh[i] + inLow[i] + inClose[i] + inOpen[i]) / 4.0;
      }

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int bbandsLookback(int optInTimePeriod, double optInNbDevUp,
      double optInNbDevDn, MAType optInMAType) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    if (optInNbDevUp == -4.0E37) {
      optInNbDevUp = 2.0;
    } else if (optInNbDevUp < -3.0E37 || optInNbDevUp > 3.0E37) {
      return -1;
    }

    if (optInNbDevDn == -4.0E37) {
      optInNbDevDn = 2.0;
    } else if (optInNbDevDn < -3.0E37 || optInNbDevDn > 3.0E37) {
      return -1;
    }

    return movingAverageLookback(optInTimePeriod, optInMAType);
  }

  RetCode bbands(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      double optInNbDevUp,
      double optInNbDevDn,
      MAType optInMAType,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outRealUpperBand,
      List<double> outRealMiddleBand,
      List<double> outRealLowerBand) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (optInNbDevUp == -4.0E37) {
        optInNbDevUp = 2.0;
      } else if (optInNbDevUp < -3.0E37 || optInNbDevUp > 3.0E37) {
        return RetCode.BadParam;
      }

      if (optInNbDevDn == -4.0E37) {
        optInNbDevDn = 2.0;
      } else if (optInNbDevDn < -3.0E37 || optInNbDevDn > 3.0E37) {
        return RetCode.BadParam;
      }

      List<double> tempBuffer1;
      List<double> tempBuffer2;
      if (inReal == outRealUpperBand) {
        tempBuffer1 = outRealMiddleBand;
        tempBuffer2 = outRealLowerBand;
      } else if (inReal == outRealLowerBand) {
        tempBuffer1 = outRealMiddleBand;
        tempBuffer2 = outRealUpperBand;
      } else if (inReal == outRealMiddleBand) {
        tempBuffer1 = outRealLowerBand;
        tempBuffer2 = outRealUpperBand;
      } else {
        tempBuffer1 = outRealMiddleBand;
        tempBuffer2 = outRealUpperBand;
      }

      if (tempBuffer1 != inReal && tempBuffer2 != inReal) {
        RetCode retCode = movingAverage(
            startIdx,
            endIdx,
            inReal,
            optInTimePeriod,
            optInMAType,
            outBegIdx,
            outNBElement,
            tempBuffer1);
        if (retCode == RetCode.Success && outNBElement.value != 0) {
          if (optInMAType == MAType.Sma) {
            _taIntStddevUsingPrecalcMa(inReal, tempBuffer1, outBegIdx.value,
                outNBElement.value, optInTimePeriod, tempBuffer2);
          } else {
            retCode = stdDev(
                outBegIdx.value,
                endIdx,
                inReal,
                optInTimePeriod,
                1.0,
                outBegIdx,
                outNBElement,
                tempBuffer2);
            if (retCode != RetCode.Success) {
              outNBElement.value = 0;
              return retCode;
            }
          }

          if (tempBuffer1 != outRealMiddleBand) {
            List.copyRange(
                outRealMiddleBand, 0, tempBuffer1, 0, outNBElement.value - 1);
          }

          int i;
          double tempReal;
          double tempReal2;
          if (optInNbDevUp == optInNbDevDn) {
            if (optInNbDevUp == 1.0) {
              for (i = 0; i < outNBElement.value; ++i) {
                tempReal = tempBuffer2[i];
                tempReal2 = outRealMiddleBand[i];
                outRealUpperBand[i] = tempReal2 + tempReal;
                outRealLowerBand[i] = tempReal2 - tempReal;
              }
            } else {
              for (i = 0; i < outNBElement.value; ++i) {
                tempReal = tempBuffer2[i] * optInNbDevUp;
                tempReal2 = outRealMiddleBand[i];
                outRealUpperBand[i] = tempReal2 + tempReal;
                outRealLowerBand[i] = tempReal2 - tempReal;
              }
            }
          } else if (optInNbDevUp == 1.0) {
            for (i = 0; i < outNBElement.value; ++i) {
              tempReal = tempBuffer2[i];
              tempReal2 = outRealMiddleBand[i];
              outRealUpperBand[i] = tempReal2 + tempReal;
              outRealLowerBand[i] = tempReal2 - tempReal * optInNbDevDn;
            }
          } else if (optInNbDevDn == 1.0) {
            for (i = 0; i < outNBElement.value; ++i) {
              tempReal = tempBuffer2[i];
              tempReal2 = outRealMiddleBand[i];
              outRealLowerBand[i] = tempReal2 - tempReal;
              outRealUpperBand[i] = tempReal2 + tempReal * optInNbDevUp;
            }
          } else {
            for (i = 0; i < outNBElement.value; ++i) {
              tempReal = tempBuffer2[i];
              tempReal2 = outRealMiddleBand[i];
              outRealUpperBand[i] = tempReal2 + tempReal * optInNbDevUp;
              outRealLowerBand[i] = tempReal2 - tempReal * optInNbDevDn;
            }
          }

          return RetCode.Success;
        } else {
          outNBElement.value = 0;
          return retCode;
        }
      } else {
        return RetCode.BadParam;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int betaLookback(int optInTimePeriod) {
    if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod;
  }

  RetCode beta(int startIdx,
      int endIdx,
      List<double> inReal0,
      List<double> inReal1,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    double sXx = 0.0;
    double sXy = 0.0;
    double sX = 0.0;
    double sY = 0.0;
    double lastPriceX = 0.0;
    double lastPriceY = 0.0;
    double trailingLastPriceX = 0.0;
    double trailingLastPriceY = 0.0;
    double tmpReal = 0.0;
    double n = 0.0;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod == -2147483648) {
        optInTimePeriod = 5;
      } else if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (startIdx < optInTimePeriod) {
        startIdx = optInTimePeriod;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        int trailingIdx = startIdx - optInTimePeriod;
        lastPriceX = trailingLastPriceX = inReal0[trailingIdx];
        lastPriceY = trailingLastPriceY = inReal1[trailingIdx];
        ++trailingIdx;

        int i;
        double x;
        double y;
        for (i = trailingIdx; i < startIdx; sY += y) {
          tmpReal = inReal0[i];
          if (-1.0E-8 < lastPriceX && lastPriceX < 1.0E-8) {
            x = 0.0;
          } else {
            x = (tmpReal - lastPriceX) / lastPriceX;
          }

          lastPriceX = tmpReal;
          tmpReal = inReal1[i++];
          if (-1.0E-8 < lastPriceY && lastPriceY < 1.0E-8) {
            y = 0.0;
          } else {
            y = (tmpReal - lastPriceY) / lastPriceY;
          }

          lastPriceY = tmpReal;
          sXx += x * x;
          sXy += x * y;
          sX += x;
        }

        int outIdx = 0;
        n = optInTimePeriod as double;

        do {
          tmpReal = inReal0[i];
          if (-1.0E-8 < lastPriceX && lastPriceX < 1.0E-8) {
            x = 0.0;
          } else {
            x = (tmpReal - lastPriceX) / lastPriceX;
          }

          lastPriceX = tmpReal;
          tmpReal = inReal1[i++];
          if (-1.0E-8 < lastPriceY && lastPriceY < 1.0E-8) {
            y = 0.0;
          } else {
            y = (tmpReal - lastPriceY) / lastPriceY;
          }

          lastPriceY = tmpReal;
          sXx += x * x;
          sXy += x * y;
          sX += x;
          sY += y;
          tmpReal = inReal0[trailingIdx];
          if (-1.0E-8 < trailingLastPriceX && trailingLastPriceX < 1.0E-8) {
            x = 0.0;
          } else {
            x = (tmpReal - trailingLastPriceX) / trailingLastPriceX;
          }

          trailingLastPriceX = tmpReal;
          tmpReal = inReal1[trailingIdx++];
          if (-1.0E-8 < trailingLastPriceY && trailingLastPriceY < 1.0E-8) {
            y = 0.0;
          } else {
            y = (tmpReal - trailingLastPriceY) / trailingLastPriceY;
          }

          trailingLastPriceY = tmpReal;
          tmpReal = n * sXx - sX * sX;
          if (-1.0E-8 < tmpReal && tmpReal < 1.0E-8) {
            outReal[outIdx++] = 0.0;
          } else {
            outReal[outIdx++] = (n * sXy - sX * sY) / tmpReal;
          }

          sXx -= x * x;
          sXy -= x * y;
          sX -= x;
          sY -= y;
        } while (i <= endIdx);

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int bopLookback() {
    return 0;
  }

  RetCode bop(int startIdx,
      int endIdx,
      List<double> inOpen,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int outIdx = 0;

      for (int i = startIdx; i <= endIdx; ++i) {
        double tempReal = inHigh[i] - inLow[i];
        if (tempReal < 1.0E-8) {
          outReal[outIdx++] = 0.0;
        } else {
          outReal[outIdx++] = (inClose[i] - inOpen[i]) / tempReal;
        }
      }

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int cciLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod - 1;
  }

  RetCode cci(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int circBufferIdx = 0;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      int lookbackTotal = optInTimePeriod - 1;
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else if (optInTimePeriod <= 0) {
        return RetCode.AllocErr;
      } else {
        List<double> circBuffer = List.filled(optInTimePeriod, double.nan);
        int maxIdxCircBuffer = optInTimePeriod - 1;
        int i = startIdx - lookbackTotal;
        if (optInTimePeriod > 1) {
          while (i < startIdx) {
            circBuffer[circBufferIdx] =
                (inHigh[i] + inLow[i] + inClose[i]) / 3.0;
            ++i;
            ++circBufferIdx;
            if (circBufferIdx > maxIdxCircBuffer) {
              circBufferIdx = 0;
            }
          }
        }

        int outIdx = 0;

        do {
          double lastValue = (inHigh[i] + inLow[i] + inClose[i]) / 3.0;
          circBuffer[circBufferIdx] = lastValue;
          double theAverage = 0.0;

          int j;
          for (j = 0; j < optInTimePeriod; ++j) {
            theAverage += circBuffer[j];
          }

          theAverage /= optInTimePeriod;
          double tempReal2 = 0.0;

          for (j = 0; j < optInTimePeriod; ++j) {
            tempReal2 += (circBuffer[j] - theAverage).abs();
          }

          double tempReal = lastValue - theAverage;
          if (tempReal != 0.0 && tempReal2 != 0.0) {
            outReal[outIdx++] =
                tempReal / (0.015 * (tempReal2 / optInTimePeriod));
          } else {
            outReal[outIdx++] = 0.0;
          }

          ++circBufferIdx;
          if (circBufferIdx > maxIdxCircBuffer) {
            circBufferIdx = 0;
          }

          ++i;
        } while (i <= endIdx);

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int cdl2CrowsLookback() {
    return _candleSettings[CandleSettingType.BodyLong.index].avgPeriod + 2;
  }

  RetCode cdl2Crows(int startIdx, int endIdx, List<double> inOpen,
      List<double> inHigh, List<double> inLow, List<double> inClose,
      MInteger outBegIdx, MInteger outNBElement, List<int> outInteger) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int lookbackTotal = cdl2CrowsLookback();
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        double bodyLongPeriodTotal = 0.0;
        int bodyLongTrailingIdx = startIdx - 2 -
            _candleSettings[CandleSettingType.BodyLong.index].avgPeriod;

        int i;
        for (i = bodyLongTrailingIdx; i < startIdx - 2; ++i) {
          bodyLongPeriodTotal +=
          _candleSettings[CandleSettingType.BodyLong.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i] - inOpen[i]).abs()
              : (_candleSettings[CandleSettingType.BodyLong.index].rangeType ==
              RangeType.HighLow
              ? inHigh[i] - inLow[i]
              : (_candleSettings[CandleSettingType.BodyLong.index].rangeType ==
              RangeType.Shadows
              ? inHigh[i] - (inClose[i] >= inOpen[i] ? inClose[i] : inOpen[i]) +
              ((inClose[i] >= inOpen[i] ? inOpen[i] : inClose[i]) - inLow[i])
              : 0.0));
        }

        i = startIdx;
        int outIdx = 0;

        do {
          if ((inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) == 1 &&
              (inClose[i - 2] - inOpen[i - 2]).abs() >
                  _candleSettings[CandleSettingType.BodyLong.index].factor *
                      (_candleSettings[CandleSettingType.BodyLong.index]
                          .avgPeriod != 0.0 ? bodyLongPeriodTotal /
                          _candleSettings[CandleSettingType.BodyLong.index]
                              .avgPeriod : (_candleSettings[CandleSettingType
                          .BodyLong.index].rangeType == RangeType.RealBody
                          ? (inClose[i - 2] - inOpen[i - 2]).abs()
                          : (_candleSettings[CandleSettingType.BodyLong.index]
                          .rangeType == RangeType.HighLow ? inHigh[i - 2] -
                          inLow[i - 2] : (_candleSettings[CandleSettingType
                          .BodyLong.index].rangeType == RangeType.Shadows
                          ? inHigh[i - 2] - (inClose[i - 2] >= inOpen[i - 2]
                          ? inClose[i - 2]
                          : inOpen[i - 2]) + ((inClose[i - 2] >= inOpen[i - 2]
                          ? inOpen[i - 2]
                          : inClose[i - 2]) - inLow[i - 2])
                          : 0.0)))) /
                      (_candleSettings[CandleSettingType.BodyLong.index]
                          .rangeType == RangeType.Shadows ? 2.0 : 1.0) &&
              (inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) == -1 &&
              (inOpen[i - 1] < inClose[i - 1] ? inOpen[i - 1] : inClose[i -
                  1]) >
                  (inOpen[i - 2] > inClose[i - 2] ? inOpen[i - 2] : inClose[i -
                      2]) && (inClose[i] >= inOpen[i] ? 1 : -1) == -1 &&
              inOpen[i] < inOpen[i - 1] && inOpen[i] > inClose[i - 1] &&
              inClose[i] > inOpen[i - 2] && inClose[i] < inClose[i - 2]) {
            outInteger[outIdx++] = -100;
          } else {
            outInteger[outIdx++] = 0;
          }

          bodyLongPeriodTotal +=
              (_candleSettings[CandleSettingType.BodyLong.index].rangeType ==
                  RangeType.RealBody
                  ? (inClose[i - 2] - inOpen[i - 2]).abs()
                  : (_candleSettings[CandleSettingType.BodyLong.index]
                  .rangeType == RangeType.HighLow
                  ? inHigh[i - 2] - inLow[i - 2]
                  : (_candleSettings[CandleSettingType.BodyLong.index]
                  .rangeType == RangeType.Shadows ? inHigh[i - 2] -
                  (inClose[i - 2] >= inOpen[i - 2] ? inClose[i - 2] : inOpen[i -
                      2]) + ((inClose[i - 2] >= inOpen[i - 2]
                  ? inOpen[i - 2]
                  : inClose[i - 2]) - inLow[i - 2]) : 0.0))) -
                  (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.RealBody
                      ? (inClose[bodyLongTrailingIdx] -
                      inOpen[bodyLongTrailingIdx]).abs()
                      : (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.HighLow
                      ? inHigh[bodyLongTrailingIdx] - inLow[bodyLongTrailingIdx]
                      : (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.Shadows
                      ? inHigh[bodyLongTrailingIdx] -
                      (inClose[bodyLongTrailingIdx] >=
                          inOpen[bodyLongTrailingIdx]
                          ? inClose[bodyLongTrailingIdx]
                          : inOpen[bodyLongTrailingIdx]) +
                      ((inClose[bodyLongTrailingIdx] >=
                          inOpen[bodyLongTrailingIdx]
                          ? inOpen[bodyLongTrailingIdx]
                          : inClose[bodyLongTrailingIdx]) -
                          inLow[bodyLongTrailingIdx])
                      : 0.0)));
          ++i;
          ++bodyLongTrailingIdx;
        } while (i <= endIdx);

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int cdl3BlackCrowsLookback() {
    return _candleSettings[CandleSettingType.ShadowVeryShort.index].avgPeriod +
        3;
  }

  RetCode cdl3BlackCrows(int startIdx, int endIdx, List<double> inOpen,
      List<double> inHigh, List<double> inLow, List<double> inClose,
      MInteger outBegIdx, MInteger outNBElement, List<int> outInteger) {
    List<double> shadowVeryShortPeriodTotal = List.filled(3, double.nan);
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int lookbackTotal = cdl3BlackCrowsLookback();
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        shadowVeryShortPeriodTotal[2] = 0.0;
        shadowVeryShortPeriodTotal[1] = 0.0;
        shadowVeryShortPeriodTotal[0] = 0.0;
        int shadowVeryShortTrailingIdx = startIdx -
            _candleSettings[CandleSettingType.ShadowVeryShort.index].avgPeriod;

        int i;
        for (i = shadowVeryShortTrailingIdx; i < startIdx; ++i) {
          shadowVeryShortPeriodTotal[2] +=
          _candleSettings[CandleSettingType.ShadowVeryShort.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i - 2] - inOpen[i - 2]).abs()
              : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
              .rangeType == RangeType.HighLow
              ? inHigh[i - 2] - inLow[i - 2]
              : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
              .rangeType == RangeType.Shadows ? inHigh[i - 2] -
              (inClose[i - 2] >= inOpen[i - 2] ? inClose[i - 2] : inOpen[i -
                  2]) +
              ((inClose[i - 2] >= inOpen[i - 2] ? inOpen[i - 2] : inClose[i -
                  2]) - inLow[i - 2]) : 0.0));
          shadowVeryShortPeriodTotal[1] +=
          _candleSettings[CandleSettingType.ShadowVeryShort.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i - 1] - inOpen[i - 1]).abs()
              : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
              .rangeType == RangeType.HighLow
              ? inHigh[i - 1] - inLow[i - 1]
              : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
              .rangeType == RangeType.Shadows ? inHigh[i - 1] -
              (inClose[i - 1] >= inOpen[i - 1] ? inClose[i - 1] : inOpen[i -
                  1]) +
              ((inClose[i - 1] >= inOpen[i - 1] ? inOpen[i - 1] : inClose[i -
                  1]) - inLow[i - 1]) : 0.0));
          shadowVeryShortPeriodTotal[0] +=
          _candleSettings[CandleSettingType.ShadowVeryShort.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i] - inOpen[i]).abs()
              : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
              .rangeType == RangeType.HighLow
              ? inHigh[i] - inLow[i]
              : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
              .rangeType == RangeType.Shadows
              ? inHigh[i] - (inClose[i] >= inOpen[i] ? inClose[i] : inOpen[i]) +
              ((inClose[i] >= inOpen[i] ? inOpen[i] : inClose[i]) - inLow[i])
              : 0.0));
        }

        i = startIdx;
        int outIdx = 0;

        do {
          if ((inClose[i - 3] >= inOpen[i - 3] ? 1 : -1) == 1 &&
              (inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) == -1 &&
              (inClose[i - 2] >= inOpen[i - 2] ? inOpen[i - 2] : inClose[i -
                  2]) - inLow[i - 2] <
                  _candleSettings[CandleSettingType.ShadowVeryShort.index]
                      .factor *
                      (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                          .avgPeriod != 0.0
                          ? shadowVeryShortPeriodTotal[2] /
                          _candleSettings[CandleSettingType.ShadowVeryShort
                              .index].avgPeriod
                          : (_candleSettings[CandleSettingType.ShadowVeryShort
                          .index].rangeType == RangeType.RealBody
                          ? (inClose[i - 2] - inOpen[i - 2]).abs()
                          : (_candleSettings[CandleSettingType.ShadowVeryShort
                          .index].rangeType == RangeType.HighLow ? inHigh[i -
                          2] - inLow[i - 2] : (_candleSettings[CandleSettingType
                          .ShadowVeryShort.index].rangeType == RangeType.Shadows
                          ? inHigh[i - 2] - (inClose[i - 2] >= inOpen[i - 2]
                          ? inClose[i - 2]
                          : inOpen[i - 2]) + ((inClose[i - 2] >= inOpen[i - 2]
                          ? inOpen[i - 2]
                          : inClose[i - 2]) - inLow[i - 2])
                          : 0.0)))) /
                      (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                          .rangeType == RangeType.Shadows ? 2.0 : 1.0) &&
              (inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) == -1 &&
              (inClose[i - 1] >= inOpen[i - 1] ? inOpen[i - 1] : inClose[i -
                  1]) - inLow[i - 1] <
                  _candleSettings[CandleSettingType.ShadowVeryShort.index]
                      .factor *
                      (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                          .avgPeriod != 0.0
                          ? shadowVeryShortPeriodTotal[1] /
                          _candleSettings[CandleSettingType.ShadowVeryShort
                              .index].avgPeriod
                          : (_candleSettings[CandleSettingType.ShadowVeryShort
                          .index].rangeType == RangeType.RealBody
                          ? (inClose[i - 1] - inOpen[i - 1]).abs()
                          : (_candleSettings[CandleSettingType.ShadowVeryShort
                          .index].rangeType == RangeType.HighLow ? inHigh[i -
                          1] - inLow[i - 1] : (_candleSettings[CandleSettingType
                          .ShadowVeryShort.index].rangeType == RangeType.Shadows
                          ? inHigh[i - 1] - (inClose[i - 1] >= inOpen[i - 1]
                          ? inClose[i - 1]
                          : inOpen[i - 1]) + ((inClose[i - 1] >= inOpen[i - 1]
                          ? inOpen[i - 1]
                          : inClose[i - 1]) - inLow[i - 1])
                          : 0.0)))) /
                      (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                          .rangeType == RangeType.Shadows ? 2.0 : 1.0) &&
              (inClose[i] >= inOpen[i] ? 1 : -1) == -1 &&
              (inClose[i] >= inOpen[i] ? inOpen[i] : inClose[i]) - inLow[i] <
                  _candleSettings[CandleSettingType.ShadowVeryShort.index]
                      .factor *
                      (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                          .avgPeriod !=
                          0.0
                          ? shadowVeryShortPeriodTotal[0] /
                          _candleSettings[CandleSettingType.ShadowVeryShort
                              .index].avgPeriod
                          : (_candleSettings[CandleSettingType.ShadowVeryShort
                          .index].rangeType == RangeType.RealBody
                          ? (inClose[i] - inOpen[i]).abs()
                          : (_candleSettings[CandleSettingType.ShadowVeryShort
                          .index].rangeType == RangeType.HighLow ? inHigh[i] -
                          inLow[i] : (_candleSettings[CandleSettingType
                          .ShadowVeryShort.index].rangeType == RangeType.Shadows
                          ? inHigh[i] -
                          (inClose[i] >= inOpen[i] ? inClose[i] : inOpen[i]) +
                          ((inClose[i] >= inOpen[i] ? inOpen[i] : inClose[i]) -
                              inLow[i])
                          : 0.0)))) /
                      (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                          .rangeType == RangeType.Shadows ? 2.0 : 1.0) &&
              inOpen[i - 1] < inOpen[i - 2] && inOpen[i - 1] > inClose[i - 2] &&
              inOpen[i] < inOpen[i - 1] && inOpen[i] > inClose[i - 1] &&
              inHigh[i - 3] > inClose[i - 2] &&
              inClose[i - 2] > inClose[i - 1] && inClose[i - 1] > inClose[i]) {
            outInteger[outIdx++] = -100;
          } else {
            outInteger[outIdx++] = 0;
          }

          for (int totIdx = 2; totIdx >= 0; --totIdx) {
            shadowVeryShortPeriodTotal[totIdx] +=
                (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                    .rangeType == RangeType.RealBody
                    ? (inClose[i - totIdx] - inOpen[i - totIdx]).abs()
                    : (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                    .rangeType == RangeType.HighLow ? inHigh[i - totIdx] -
                    inLow[i - totIdx] : (_candleSettings[CandleSettingType
                    .ShadowVeryShort.index].rangeType == RangeType.Shadows
                    ? inHigh[i - totIdx] -
                    (inClose[i - totIdx] >= inOpen[i - totIdx] ? inClose[i -
                        totIdx] : inOpen[i - totIdx]) +
                    ((inClose[i - totIdx] >= inOpen[i - totIdx] ? inOpen[i -
                        totIdx] : inClose[i - totIdx]) - inLow[i - totIdx])
                    : 0.0))) -
                    (_candleSettings[CandleSettingType.ShadowVeryShort.index]
                        .rangeType == RangeType.RealBody
                        ? (inClose[shadowVeryShortTrailingIdx - totIdx] -
                        inOpen[shadowVeryShortTrailingIdx - totIdx]).abs()
                        : (_candleSettings[CandleSettingType.ShadowVeryShort
                        .index].rangeType == RangeType.HighLow
                        ? inHigh[shadowVeryShortTrailingIdx - totIdx] -
                        inLow[shadowVeryShortTrailingIdx - totIdx]
                        : (_candleSettings[CandleSettingType.ShadowVeryShort
                        .index].rangeType == RangeType.Shadows
                        ? inHigh[shadowVeryShortTrailingIdx - totIdx] -
                        (inClose[shadowVeryShortTrailingIdx - totIdx] >=
                            inOpen[shadowVeryShortTrailingIdx - totIdx]
                            ? inClose[shadowVeryShortTrailingIdx - totIdx]
                            : inOpen[shadowVeryShortTrailingIdx - totIdx]) +
                        ((inClose[shadowVeryShortTrailingIdx - totIdx] >=
                            inOpen[shadowVeryShortTrailingIdx - totIdx]
                            ? inOpen[shadowVeryShortTrailingIdx - totIdx]
                            : inClose[shadowVeryShortTrailingIdx - totIdx]) -
                            inLow[shadowVeryShortTrailingIdx - totIdx])
                        : 0.0)));
          }

          ++i;
          ++shadowVeryShortTrailingIdx;
        } while (i <= endIdx);

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int cdl3InsideLookback() {
    return (_candleSettings[CandleSettingType.BodyShort.index].avgPeriod >
        _candleSettings[CandleSettingType.BodyLong.index].avgPeriod
        ? _candleSettings[CandleSettingType.BodyShort.index].avgPeriod
        : _candleSettings[CandleSettingType.BodyLong.index].avgPeriod) + 2;
  }

  RetCode cdl3Inside(int startIdx, int endIdx, List<double> inOpen,
      List<double> inHigh, List<double> inLow, List<double> inClose,
      MInteger outBegIdx, MInteger outNBElement, List<int> outInteger) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int lookbackTotal = cdl3InsideLookback();
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        double bodyLongPeriodTotal = 0.0;
        double bodyShortPeriodTotal = 0.0;
        int bodyLongTrailingIdx = startIdx - 2 -
            _candleSettings[CandleSettingType.BodyLong.index].avgPeriod;
        int bodyShortTrailingIdx = startIdx - 1 -
            _candleSettings[CandleSettingType.BodyShort.index].avgPeriod;

        int i;
        for (i = bodyLongTrailingIdx; i < startIdx - 2; ++i) {
          bodyLongPeriodTotal +=
          _candleSettings[CandleSettingType.BodyLong.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i] - inOpen[i]).abs()
              : (_candleSettings[CandleSettingType.BodyLong.index].rangeType ==
              RangeType.HighLow
              ? inHigh[i] - inLow[i]
              : (_candleSettings[CandleSettingType.BodyLong.index].rangeType ==
              RangeType.Shadows
              ? inHigh[i] - (inClose[i] >= inOpen[i] ? inClose[i] : inOpen[i]) +
              ((inClose[i] >= inOpen[i] ? inOpen[i] : inClose[i]) - inLow[i])
              : 0.0));
        }

        for (i = bodyShortTrailingIdx; i < startIdx - 1; ++i) {
          bodyShortPeriodTotal +=
          _candleSettings[CandleSettingType.BodyShort.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i] - inOpen[i]).abs()
              : (_candleSettings[CandleSettingType.BodyShort.index].rangeType ==
              RangeType.HighLow
              ? inHigh[i] - inLow[i]
              : (_candleSettings[CandleSettingType.BodyShort.index].rangeType ==
              RangeType.Shadows
              ? inHigh[i] - (inClose[i] >= inOpen[i] ? inClose[i] : inOpen[i]) +
              ((inClose[i] >= inOpen[i] ? inOpen[i] : inClose[i]) - inLow[i])
              : 0.0));
        }

        i = startIdx;
        int outIdx = 0;

        do {
          if (!((inClose[i - 2] - inOpen[i - 2]).abs() >
              _candleSettings[CandleSettingType.BodyLong.index].factor *
                  (_candleSettings[CandleSettingType.BodyLong.index]
                      .avgPeriod != 0.0 ? bodyLongPeriodTotal /
                      _candleSettings[CandleSettingType.BodyLong.index]
                          .avgPeriod : (_candleSettings[CandleSettingType
                      .BodyLong.index].rangeType == RangeType.RealBody
                      ? (inClose[i - 2] - inOpen[i - 2]).abs()
                      : (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.HighLow ? inHigh[i - 2] -
                      inLow[i - 2] : (_candleSettings[CandleSettingType.BodyLong
                      .index].rangeType == RangeType.Shadows ? inHigh[i - 2] -
                      (inClose[i - 2] >= inOpen[i - 2]
                          ? inClose[i - 2]
                          : inOpen[i - 2]) + ((inClose[i - 2] >= inOpen[i - 2]
                      ? inOpen[i - 2]
                      : inClose[i - 2]) - inLow[i - 2]) : 0.0)))) /
                  (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.Shadows ? 2.0 : 1.0)) ||
              !((inClose[i - 1] - inOpen[i - 1]).abs() <=
                  _candleSettings[CandleSettingType.BodyShort.index].factor *
                      (_candleSettings[CandleSettingType.BodyShort.index]
                          .avgPeriod != 0.0 ? bodyShortPeriodTotal /
                          _candleSettings[CandleSettingType.BodyShort.index]
                              .avgPeriod : (_candleSettings[CandleSettingType
                          .BodyShort.index].rangeType == RangeType.RealBody
                          ? (inClose[i - 1] - inOpen[i - 1]).abs()
                          : (_candleSettings[CandleSettingType.BodyShort.index]
                          .rangeType == RangeType.HighLow ? inHigh[i - 1] -
                          inLow[i - 1] : (_candleSettings[CandleSettingType
                          .BodyShort.index].rangeType == RangeType.Shadows
                          ? inHigh[i - 1] - (inClose[i - 1] >= inOpen[i - 1]
                          ? inClose[i - 1]
                          : inOpen[i - 1]) + ((inClose[i - 1] >= inOpen[i - 1]
                          ? inOpen[i - 1]
                          : inClose[i - 1]) - inLow[i - 1])
                          : 0.0)))) /
                      (_candleSettings[CandleSettingType.BodyShort.index]
                          .rangeType == RangeType.Shadows ? 2.0 : 1.0)) ||
              !((inClose[i - 1] > inOpen[i - 1] ? inClose[i - 1] : inOpen[i -
                  1]) <
                  (inClose[i - 2] > inOpen[i - 2] ? inClose[i - 2] : inOpen[i -
                      2])) ||
              !((inClose[i - 1] < inOpen[i - 1] ? inClose[i - 1] : inOpen[i -
                  1]) >
                  (inClose[i - 2] < inOpen[i - 2] ? inClose[i - 2] : inOpen[i -
                      2])) ||
              ((inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) != 1 ||
                  (inClose[i] >= inOpen[i] ? 1 : -1) != -1 ||
                  !(inClose[i] < inOpen[i - 2])) &&
                  ((inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) != -1 ||
                      (inClose[i] >= inOpen[i] ? 1 : -1) != 1 ||
                      !(inClose[i] > inOpen[i - 2]))) {
            outInteger[outIdx++] = 0;
          } else {
            outInteger[outIdx++] =
                -(inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) * 100;
          }

          bodyLongPeriodTotal +=
              (_candleSettings[CandleSettingType.BodyLong.index].rangeType ==
                  RangeType.RealBody
                  ? (inClose[i - 2] - inOpen[i - 2]).abs()
                  : (_candleSettings[CandleSettingType.BodyLong.index]
                  .rangeType == RangeType.HighLow
                  ? inHigh[i - 2] - inLow[i - 2]
                  : (_candleSettings[CandleSettingType.BodyLong.index]
                  .rangeType == RangeType.Shadows ? inHigh[i - 2] -
                  (inClose[i - 2] >= inOpen[i - 2] ? inClose[i - 2] : inOpen[i -
                      2]) + ((inClose[i - 2] >= inOpen[i - 2]
                  ? inOpen[i - 2]
                  : inClose[i - 2]) - inLow[i - 2]) : 0.0))) -
                  (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.RealBody
                      ? (inClose[bodyLongTrailingIdx] -
                      inOpen[bodyLongTrailingIdx]).abs()
                      : (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.HighLow
                      ? inHigh[bodyLongTrailingIdx] - inLow[bodyLongTrailingIdx]
                      : (_candleSettings[CandleSettingType.BodyLong.index]
                      .rangeType == RangeType.Shadows
                      ? inHigh[bodyLongTrailingIdx] -
                      (inClose[bodyLongTrailingIdx] >=
                          inOpen[bodyLongTrailingIdx]
                          ? inClose[bodyLongTrailingIdx]
                          : inOpen[bodyLongTrailingIdx]) +
                      ((inClose[bodyLongTrailingIdx] >=
                          inOpen[bodyLongTrailingIdx]
                          ? inOpen[bodyLongTrailingIdx]
                          : inClose[bodyLongTrailingIdx]) -
                          inLow[bodyLongTrailingIdx])
                      : 0.0)));
          bodyShortPeriodTotal +=
              (_candleSettings[CandleSettingType.BodyShort.index].rangeType ==
                  RangeType.RealBody
                  ? (inClose[i - 1] - inOpen[i - 1]).abs()
                  : (_candleSettings[CandleSettingType.BodyShort.index]
                  .rangeType == RangeType.HighLow
                  ? inHigh[i - 1] - inLow[i - 1]
                  : (_candleSettings[CandleSettingType.BodyShort.index]
                  .rangeType == RangeType.Shadows ? inHigh[i - 1] -
                  (inClose[i - 1] >= inOpen[i - 1] ? inClose[i - 1] : inOpen[i -
                      1]) + ((inClose[i - 1] >= inOpen[i - 1]
                  ? inOpen[i - 1]
                  : inClose[i - 1]) - inLow[i - 1]) : 0.0))) -
                  (_candleSettings[CandleSettingType.BodyShort.index]
                      .rangeType == RangeType.RealBody
                      ? (inClose[bodyShortTrailingIdx] -
                      inOpen[bodyShortTrailingIdx]).abs()
                      : (_candleSettings[CandleSettingType.BodyShort.index]
                      .rangeType == RangeType.HighLow
                      ? inHigh[bodyShortTrailingIdx] -
                      inLow[bodyShortTrailingIdx]
                      : (_candleSettings[CandleSettingType.BodyShort.index]
                      .rangeType == RangeType.Shadows
                      ? inHigh[bodyShortTrailingIdx] -
                      (inClose[bodyShortTrailingIdx] >=
                          inOpen[bodyShortTrailingIdx]
                          ? inClose[bodyShortTrailingIdx]
                          : inOpen[bodyShortTrailingIdx]) +
                      ((inClose[bodyShortTrailingIdx] >=
                          inOpen[bodyShortTrailingIdx]
                          ? inOpen[bodyShortTrailingIdx]
                          : inClose[bodyShortTrailingIdx]) -
                          inLow[bodyShortTrailingIdx])
                      : 0.0)));
          ++i;
          ++bodyLongTrailingIdx;
          ++bodyShortTrailingIdx;
        } while (i <= endIdx);

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int cdl3LineStrikeLookback() {
    return _candleSettings[CandleSettingType.Near.index].avgPeriod + 3;
  }

  RetCode cdl3LineStrike(int startIdx, int endIdx, List<double> inOpen,
      List<double> inHigh, List<double> inLow, List<double> inClose,
      MInteger outBegIdx, MInteger outNBElement, List<int> outInteger) {
    List<double> nearPeriodTotal = List.filled(4, double.nan);
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      int lookbackTotal = cdl3LineStrikeLookback();
      if (startIdx < lookbackTotal) {
        startIdx = lookbackTotal;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        nearPeriodTotal[3] = 0.0;
        nearPeriodTotal[2] = 0.0;
        int nearTrailingIdx = startIdx -
            _candleSettings[CandleSettingType.Near.index].avgPeriod;

        int i;
        for (i = nearTrailingIdx; i < startIdx; ++i) {
          nearPeriodTotal[3] +=
          _candleSettings[CandleSettingType.Near.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i - 3] - inOpen[i - 3]).abs()
              : (_candleSettings[CandleSettingType.Near.index].rangeType ==
              RangeType.HighLow
              ? inHigh[i - 3] - inLow[i - 3]
              : (_candleSettings[CandleSettingType.Near.index].rangeType ==
              RangeType.Shadows ? inHigh[i - 3] -
              (inClose[i - 3] >= inOpen[i - 3] ? inClose[i - 3] : inOpen[i -
                  3]) +
              ((inClose[i - 3] >= inOpen[i - 3] ? inOpen[i - 3] : inClose[i -
                  3]) - inLow[i - 3]) : 0.0));
          nearPeriodTotal[2] +=
          _candleSettings[CandleSettingType.Near.index].rangeType ==
              RangeType.RealBody
              ? (inClose[i - 2] - inOpen[i - 2]).abs()
              : (_candleSettings[CandleSettingType.Near.index].rangeType ==
              RangeType.HighLow
              ? inHigh[i - 2] - inLow[i - 2]
              : (_candleSettings[CandleSettingType.Near.index].rangeType ==
              RangeType.Shadows ? inHigh[i - 2] -
              (inClose[i - 2] >= inOpen[i - 2] ? inClose[i - 2] : inOpen[i -
                  2]) +
              ((inClose[i - 2] >= inOpen[i - 2] ? inOpen[i - 2] : inClose[i -
                  2]) - inLow[i - 2]) : 0.0));
        }

        i = startIdx;
        int outIdx = 0;

        do {
          if ((inClose[i - 3] >= inOpen[i - 3] ? 1 : -1) !=
              (inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) ||
              (inClose[i - 2] >= inOpen[i - 2] ? 1 : -1) !=
                  (inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) ||
              (inClose[i] >= inOpen[i] ? 1 : -1) !=
                  -(inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) ||
              !(inOpen[i - 2] >=
                  (inOpen[i - 3] < inClose[i - 3] ? inOpen[i - 3] : inClose[i -
                      3]) -
                      _candleSettings[CandleSettingType.Near.index].factor *
                          (_candleSettings[CandleSettingType.Near.index]
                              .avgPeriod != 0.0
                              ? nearPeriodTotal[3] /
                              _candleSettings[CandleSettingType.Near.index]
                                  .avgPeriod
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.RealBody
                              ? (inClose[i - 3] - inOpen[i - 3]).abs()
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.HighLow ? inHigh[i - 3] -
                              inLow[i - 3] : (_candleSettings[CandleSettingType
                              .Near.index].rangeType == RangeType.Shadows
                              ? inHigh[i - 3] - (inClose[i - 3] >= inOpen[i - 3]
                              ? inClose[i - 3]
                              : inOpen[i - 3]) +
                              ((inClose[i - 3] >= inOpen[i - 3]
                                  ? inOpen[i - 3]
                                  : inClose[i - 3]) - inLow[i - 3])
                              : 0.0)))) /
                          (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.Shadows ? 2.0 : 1.0)) ||
              !(inOpen[i - 2] <=
                  (inOpen[i - 3] > inClose[i - 3] ? inOpen[i - 3] : inClose[i -
                      3]) +
                      _candleSettings[CandleSettingType.Near.index].factor *
                          (_candleSettings[CandleSettingType.Near.index]
                              .avgPeriod != 0.0
                              ? nearPeriodTotal[3] /
                              _candleSettings[CandleSettingType.Near.index]
                                  .avgPeriod
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.RealBody
                              ? (inClose[i - 3] - inOpen[i - 3]).abs()
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.HighLow ? inHigh[i - 3] -
                              inLow[i - 3] : (_candleSettings[CandleSettingType
                              .Near.index].rangeType == RangeType.Shadows
                              ? inHigh[i - 3] - (inClose[i - 3] >= inOpen[i - 3]
                              ? inClose[i - 3]
                              : inOpen[i - 3]) +
                              ((inClose[i - 3] >= inOpen[i - 3]
                                  ? inOpen[i - 3]
                                  : inClose[i - 3]) - inLow[i - 3])
                              : 0.0)))) /
                          (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.Shadows ? 2.0 : 1.0)) ||
              !(inOpen[i - 1] >=
                  (inOpen[i - 2] < inClose[i - 2] ? inOpen[i - 2] : inClose[i -
                      2]) -
                      _candleSettings[CandleSettingType.Near.index].factor *
                          (_candleSettings[CandleSettingType.Near.index]
                              .avgPeriod != 0.0
                              ? nearPeriodTotal[2] /
                              _candleSettings[CandleSettingType.Near.index]
                                  .avgPeriod
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.RealBody
                              ? (inClose[i - 2] - inOpen[i - 2]).abs()
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.HighLow ? inHigh[i - 2] -
                              inLow[i - 2] : (_candleSettings[CandleSettingType
                              .Near.index].rangeType == RangeType.Shadows
                              ? inHigh[i - 2] - (inClose[i - 2] >= inOpen[i - 2]
                              ? inClose[i - 2]
                              : inOpen[i - 2]) +
                              ((inClose[i - 2] >= inOpen[i - 2]
                                  ? inOpen[i - 2]
                                  : inClose[i - 2]) - inLow[i - 2])
                              : 0.0)))) /
                          (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.Shadows ? 2.0 : 1.0)) ||
              !(inOpen[i - 1] <=
                  (inOpen[i - 2] > inClose[i - 2] ? inOpen[i - 2] : inClose[i -
                      2]) +
                      _candleSettings[CandleSettingType.Near.index].factor *
                          (_candleSettings[CandleSettingType.Near.index]
                              .avgPeriod != 0.0
                              ? nearPeriodTotal[2] /
                              _candleSettings[CandleSettingType.Near.index]
                                  .avgPeriod
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.RealBody
                              ? (inClose[i - 2] - inOpen[i - 2]).abs()
                              : (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.HighLow ? inHigh[i - 2] -
                              inLow[i - 2] : (_candleSettings[CandleSettingType
                              .Near.index].rangeType == RangeType.Shadows
                              ? inHigh[i - 2] - (inClose[i - 2] >= inOpen[i - 2]
                              ? inClose[i - 2]
                              : inOpen[i - 2]) +
                              ((inClose[i - 2] >= inOpen[i - 2]
                                  ? inOpen[i - 2]
                                  : inClose[i - 2]) - inLow[i - 2])
                              : 0.0)))) /
                          (_candleSettings[CandleSettingType.Near.index]
                              .rangeType == RangeType.Shadows ? 2.0 : 1.0)) ||
              ((inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) != 1 ||
                  !(inClose[i - 1] > inClose[i - 2]) ||
                  !(inClose[i - 2] > inClose[i - 3]) ||
                  !(inOpen[i] > inClose[i - 1]) ||
                  !(inClose[i] < inOpen[i - 3])) &&
                  ((inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) != -1 ||
                      !(inClose[i - 1] < inClose[i - 2]) ||
                      !(inClose[i - 2] < inClose[i - 3]) ||
                      !(inOpen[i] < inClose[i - 1]) ||
                      !(inClose[i] > inOpen[i - 3]))) {
            outInteger[outIdx++] = 0;
          } else {
            outInteger[outIdx++] =
                (inClose[i - 1] >= inOpen[i - 1] ? 1 : -1) * 100;
          }

          for (int totIdx = 3; totIdx >= 2; --totIdx) {
            nearPeriodTotal[totIdx] +=
                (_candleSettings[CandleSettingType.Near.index].rangeType ==
                    RangeType.RealBody
                    ? (inClose[i - totIdx] - inOpen[i - totIdx]).abs()
                    : (_candleSettings[CandleSettingType.Near.index]
                    .rangeType == RangeType.HighLow ? inHigh[i - totIdx] -
                    inLow[i - totIdx] : (_candleSettings[CandleSettingType.Near
                    .index].rangeType == RangeType.Shadows
                    ? inHigh[i - totIdx] -
                    (inClose[i - totIdx] >= inOpen[i - totIdx] ? inClose[i -
                        totIdx] : inOpen[i - totIdx]) +
                    ((inClose[i - totIdx] >= inOpen[i - totIdx] ? inOpen[i -
                        totIdx] : inClose[i - totIdx]) - inLow[i - totIdx])
                    : 0.0))) -
                    (_candleSettings[CandleSettingType.Near.index].rangeType ==
                        RangeType.RealBody
                        ? (inClose[nearTrailingIdx - totIdx] -
                        inOpen[nearTrailingIdx - totIdx]).abs()
                        : (_candleSettings[CandleSettingType.Near.index]
                        .rangeType == RangeType.HighLow
                        ? inHigh[nearTrailingIdx - totIdx] -
                        inLow[nearTrailingIdx - totIdx]
                        : (_candleSettings[CandleSettingType.Near.index]
                        .rangeType == RangeType.Shadows
                        ? inHigh[nearTrailingIdx - totIdx] -
                        (inClose[nearTrailingIdx - totIdx] >=
                            inOpen[nearTrailingIdx - totIdx]
                            ? inClose[nearTrailingIdx - totIdx]
                            : inOpen[nearTrailingIdx - totIdx]) +
                        ((inClose[nearTrailingIdx - totIdx] >=
                            inOpen[nearTrailingIdx - totIdx]
                            ? inOpen[nearTrailingIdx - totIdx]
                            : inClose[nearTrailingIdx - totIdx]) -
                            inLow[nearTrailingIdx - totIdx])
                        : 0.0)));
          }

          ++i;
          ++nearTrailingIdx;
        } while (i <= endIdx);

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }


  int emaLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod - 1 + _unstablePeriod[FuncUnstId.Ema.index];
  }

  RetCode ema(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      return _taIntEma(
          startIdx,
          endIdx,
          inReal,
          optInTimePeriod,
          2.0 / (optInTimePeriod + 1),
          outBegIdx,
          outNBElement,
          outReal);
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  RetCode _taIntEma(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      double optInK_1,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int lookbackTotal = emaLookback(optInTimePeriod);
    if (startIdx < lookbackTotal) {
      startIdx = lookbackTotal;
    }

    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    } else {
      outBegIdx.value = startIdx;
      double prevMA;
      int today;
      if (_compatibility == Compatibility.Default) {
        today = startIdx - lookbackTotal;
        int i = optInTimePeriod;

        double tempReal;
        for (tempReal = 0.0; i-- > 0; tempReal += inReal[today++]) {}

        prevMA = tempReal / optInTimePeriod;
      } else {
        prevMA = inReal[0];
        today = 1;
      }

      while (today <= startIdx) {
        prevMA += (inReal[today++] - prevMA) * optInK_1;
      }

      outReal[0] = prevMA;

      int outIdx;
      for (outIdx = 1; today <= endIdx; outReal[outIdx++] = prevMA) {
        prevMA += (inReal[today++] - prevMA) * optInK_1;
      }

      outNBElement.value = outIdx;
      return RetCode.Success;
    }
  }

  int movingAverageLookback(int optInTimePeriod, MAType optInMAType) {
    if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
      return -1;
    }

    if (optInTimePeriod <= 1) {
      return 0;
    } else {
      int retValue;
      switch (optInMAType) {
        case MAType.Sma:
          retValue = smaLookback(optInTimePeriod);
          break;
        case MAType.Ema:
          retValue = emaLookback(optInTimePeriod);
          break;
      /*case MAType.Wma:
          retValue = wmaLookback(optInTimePeriod);
          break;
        case MAType.Dema:
          retValue = demaLookback(optInTimePeriod);
          break;
        case MAType.Tema:
          retValue = temaLookback(optInTimePeriod);
          break;
        case MAType.Trima:
          retValue = trimaLookback(optInTimePeriod);
          break;
        case MAType.Jama:
          retValue = kamaLookback(optInTimePeriod);
          break;
        case MAType.Mama:
          retValue = mamaLookback(0.5, 0.05);
          break;
        case MAType.T3:
          retValue = t3Lookback(optInTimePeriod, 0.7);
          break;*/
        default:
          retValue = 0;
      }

      return retValue;
    }
  }

  RetCode movingAverage(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MAType optInMAType,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (optInTimePeriod != 1) {
        RetCode retCode;
        switch (optInMAType) {
          case MAType.Sma:
            retCode = sma(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
          case MAType.Ema:
            retCode = ema(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
        /*case MAType.Wma:
            retCode = wma(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
          case MAType.Dema:
            retCode = dema(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
          case MAType.Tema:
            retCode = tema(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
          case MAType.Trima:
            retCode = trima(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
          case MAType.Kama:
            retCode = kama(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                outBegIdx,
                outNBElement,
                outReal);
            break;
          case MAType.Mama:
            List<double> dummyBuffer = List.filled(endIdx - startIdx + 1, double.nan);
            retCode = mama(
                startIdx,
                endIdx,
                inReal,
                0.5, 0.05, outBegIdx, outNBElement, outReal, dummyBuffer);
            break;
          case MAType.T3:
            retCode = t3(
                startIdx,
                endIdx,
                inReal,
                optInTimePeriod,
                0.7, outBegIdx, outNBElement, outReal);
            break;*/
          default:
            retCode = RetCode.BadParam;
        }

        return retCode;
      } else {
        int nbElement = endIdx - startIdx + 1;
        outNBElement.value = nbElement;
        int todayIdx = startIdx;

        for (int outIdx = 0; outIdx < nbElement; ++todayIdx) {
          outReal[outIdx] = inReal[todayIdx];
          ++outIdx;
        }

        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int smaLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod - 1;
  }

  RetCode sma(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }
      return _taIntSma(
          startIdx,
          endIdx,
          inReal,
          optInTimePeriod,
          outBegIdx,
          outNBElement,
          outReal);
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  RetCode _taIntSma(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int lookbackTotal = optInTimePeriod - 1;
    if (startIdx < lookbackTotal) {
      startIdx = lookbackTotal;
    }

    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    } else {
      double periodTotal = 0.0;
      int trailingIdx = startIdx - lookbackTotal;
      int i = trailingIdx;
      if (optInTimePeriod > 1) {
        while (i < startIdx) {
          periodTotal += inReal[i++];
        }
      }

      int outIdx = 0;

      do {
        periodTotal += inReal[i++];
        double tempReal = periodTotal;
        periodTotal -= inReal[trailingIdx++];
        outReal[outIdx++] = tempReal / optInTimePeriod;
      } while (i <= endIdx);

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    }
  }

  int stdDevLookback(int optInTimePeriod, double optInNbDev) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    if (optInNbDev == -4.0E37) {
      optInNbDev = 1.0;
    } else if (optInNbDev < -3.0E37 || optInNbDev > 3.0E37) {
      return -1;
    }

    return varianceLookback(optInTimePeriod, optInNbDev);
  }

  RetCode stdDev(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      double optInNbDev,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod == -2147483648) {
        optInTimePeriod = 5;
      } else if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (optInNbDev == -4.0E37) {
        optInNbDev = 1.0;
      } else if (optInNbDev < -3.0E37 || optInNbDev > 3.0E37) {
        return RetCode.BadParam;
      }

      RetCode retCode = _taIntVar(
          startIdx,
          endIdx,
          inReal,
          optInTimePeriod,
          outBegIdx,
          outNBElement,
          outReal);
      if (retCode != RetCode.Success) {
        return retCode;
      } else {
        int i;
        double tempReal;
        if (optInNbDev != 1.0) {
          for (i = 0; i < outNBElement.value; ++i) {
            tempReal = outReal[i];
            if (!(tempReal < 1.0E-8)) {
              outReal[i] = math.sqrt(tempReal) * optInNbDev;
            } else {
              outReal[i] = 0.0;
            }
          }
        } else {
          for (i = 0; i < outNBElement.value; ++i) {
            tempReal = outReal[i];
            if (!(tempReal < 1.0E-8)) {
              outReal[i] = math.sqrt(tempReal);
            } else {
              outReal[i] = 0.0;
            }
          }
        }

        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  void _taIntStddevUsingPrecalcMa(List<double> inReal,
      List<double> inMovAvg,
      int inMovAvgBegIdx,
      int inMovAvgNbElement,
      int timePeriod,
      List<double> output) {
    int startSum = 1 + inMovAvgBegIdx - timePeriod;
    int endSum = inMovAvgBegIdx;
    double periodTotal2 = 0.0;

    double tempReal;
    int outIdx;
    for (outIdx = startSum; outIdx < endSum; ++outIdx) {
      tempReal = inReal[outIdx];
      tempReal *= tempReal;
      periodTotal2 += tempReal;
    }

    for (outIdx = 0; outIdx < inMovAvgNbElement; ++endSum) {
      tempReal = inReal[endSum];
      tempReal *= tempReal;
      periodTotal2 += tempReal;
      double meanValue2 = periodTotal2 / timePeriod;
      tempReal = inReal[startSum];
      tempReal *= tempReal;
      periodTotal2 -= tempReal;
      tempReal = inMovAvg[outIdx];
      tempReal *= tempReal;
      meanValue2 -= tempReal;
      if (!(meanValue2 < 1.0E-8)) {
        output[outIdx] = math.sqrt(meanValue2);
      } else {
        output[outIdx] = 0.0;
      }

      ++outIdx;
      ++startSum;
    }
  }

  int trueRangeLookback() {
    return 1;
  }

  RetCode trueRange(int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (startIdx < 1) {
        startIdx = 1;
      }

      if (startIdx > endIdx) {
        outBegIdx.value = 0;
        outNBElement.value = 0;
        return RetCode.Success;
      } else {
        int outIdx = 0;

        for (int today = startIdx; today <= endIdx; ++today) {
          double tempLT = inLow[today];
          double tempHT = inHigh[today];
          double tempCY = inClose[today - 1];
          double greatest = tempHT - tempLT;
          double val2 = (tempCY - tempHT).abs();
          if (val2 > greatest) {
            greatest = val2;
          }

          double val3 = (tempCY - tempLT).abs();
          if (val3 > greatest) {
            greatest = val3;
          }

          outReal[outIdx++] = greatest;
        }

        outNBElement.value = outIdx;
        outBegIdx.value = startIdx;
        return RetCode.Success;
      }
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  int varianceLookback(int optInTimePeriod, double optInNbDev) {
    if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
      return -1;
    }

    if (optInNbDev == -4.0E37) {
      optInNbDev = 1.0;
    } else if (optInNbDev < -3.0E37 || optInNbDev > 3.0E37) {
      return -1;
    }

    return optInTimePeriod - 1;
  }

  RetCode variance(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      double optInNbDev,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod == -2147483648) {
        optInTimePeriod = 5;
      } else if (optInTimePeriod < 1 || optInTimePeriod > 100000) {
        return RetCode.BadParam;
      }

      if (optInNbDev == -4.0E37) {
        optInNbDev = 1.0;
      } else if (optInNbDev < -3.0E37 || optInNbDev > 3.0E37) {
        return RetCode.BadParam;
      }

      return _taIntVar(
          startIdx,
          endIdx,
          inReal,
          optInTimePeriod,
          outBegIdx,
          outNBElement,
          outReal);
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  RetCode _taIntVar(int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int nbInitialElementNeeded = optInTimePeriod - 1;
    if (startIdx < nbInitialElementNeeded) {
      startIdx = nbInitialElementNeeded;
    }

    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    } else {
      double periodTotal1 = 0.0;
      double periodTotal2 = 0.0;
      int trailingIdx = startIdx - nbInitialElementNeeded;
      int i = trailingIdx;
      double tempReal;
      if (optInTimePeriod > 1) {
        while (i < startIdx) {
          tempReal = inReal[i++];
          periodTotal1 += tempReal;
          tempReal *= tempReal;
          periodTotal2 += tempReal;
        }
      }

      int outIdx = 0;

      do {
        tempReal = inReal[i++];
        periodTotal1 += tempReal;
        tempReal *= tempReal;
        periodTotal2 += tempReal;
        double meanValue1 = periodTotal1 / optInTimePeriod;
        double meanValue2 = periodTotal2 / optInTimePeriod;
        tempReal = inReal[trailingIdx++];
        periodTotal1 -= tempReal;
        tempReal *= tempReal;
        periodTotal2 -= tempReal;
        outReal[outIdx++] = meanValue2 - meanValue1 * meanValue1;
      } while (i <= endIdx);

      outNBElement.value = outIdx;
      outBegIdx.value = startIdx;
      return RetCode.Success;
    }
  }
}
