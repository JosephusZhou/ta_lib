import 'dart:math' as math;

import 'm_integer.dart';
import 'candle_setting.dart';
import 'candle_setting_type.dart';
import 'compatibility.dart';
import 'func_unst_id.dart';
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

  RetCode ad(
      int startIdx,
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

  RetCode add(
      int startIdx,
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

  RetCode adOsc(
      int startIdx,
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

  RetCode adx(
      int startIdx,
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

  RetCode adxr(
      int startIdx,
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

  int apoLookback(
      int optInFastPeriod, int optInSlowPeriod, MAType optInMAType) {
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

  RetCode apo(
      int startIdx,
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

  RetCode _taIntPo(
      int startIdx,
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

    RetCode retCode = movingAverage(startIdx, endIdx, inReal, optInFastPeriod,
        optInMethod_2, outBegIdx2, outNbElement2, tempBuffer);
    if (retCode == RetCode.Success) {
      retCode = movingAverage(startIdx, endIdx, inReal, optInSlowPeriod,
          optInMethod_2, outBegIdx1, outNbElement1, outReal);
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

  RetCode aroon(
      int startIdx,
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

  RetCode aroonOsc(
      int startIdx,
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

  RetCode atr(
      int startIdx,
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
        return trueRange(startIdx, endIdx, inHigh, inLow, inClose, outBegIdx,
            outNBElement, outReal);
      } else {
        List<double> tempBuffer =
            List.filled(lookbackTotal + (endIdx - startIdx) + 1, double.nan);
        RetCode retCode = trueRange(startIdx - lookbackTotal + 1, endIdx,
            inHigh, inLow, inClose, outBegIdx1, outNbElement1, tempBuffer);
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

  RetCode avgPrice(
      int startIdx,
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

  int emaLookback(int optInTimePeriod) {
    if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
      return -1;
    }

    return optInTimePeriod - 1 + _unstablePeriod[FuncUnstId.Ema.index];
  }

  RetCode ema(
      int startIdx,
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

      return _taIntEma(startIdx, endIdx, inReal, optInTimePeriod,
          2.0 / (optInTimePeriod + 1), outBegIdx, outNBElement, outReal);
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  RetCode _taIntEma(
      int startIdx,
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

  RetCode movingAverage(
      int startIdx,
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
            retCode = sma(startIdx, endIdx, inReal, optInTimePeriod, outBegIdx,
                outNBElement, outReal);
            break;
          case MAType.Ema:
            retCode = ema(startIdx, endIdx, inReal, optInTimePeriod, outBegIdx,
                outNBElement, outReal);
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

  RetCode sma(
      int startIdx,
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
      return _taIntSma(startIdx, endIdx, inReal, optInTimePeriod, outBegIdx,
          outNBElement, outReal);
    } else {
      return RetCode.OutOfRangeEndIndex;
    }
  }

  RetCode _taIntSma(
      int startIdx,
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

  int trueRangeLookback() {
    return 1;
  }

  RetCode trueRange(
      int startIdx,
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
}
