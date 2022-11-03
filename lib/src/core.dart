import 'candle_setting.dart';
import 'candle_setting_type.dart';
import 'compatibility.dart';
import 'func_unst_id.dart';
import 'm_integer.dart';
import 'money_flow.dart';
import 'range_type.dart';
import 'ret_code.dart';

class Core {
  late List<int> _unstablePeriod;

  late List<CandleSetting> _candleSettings;

  late Compatibility _compatibility;

  final List<CandleSetting> _taCandleDefaultSettings = [
    CandleSetting(CandleSettingType.BodyLong, RangeType.RealBody, 10, 1.0),
    CandleSetting(CandleSettingType.BodyVeryLong, RangeType.RealBody, 10, 3.0),
    CandleSetting(CandleSettingType.BodyShort, RangeType.RealBody, 10, 1.0),
    CandleSetting(CandleSettingType.BodyDoji, RangeType.HighLow, 10, 0.1),
    CandleSetting(CandleSettingType.ShadowLong, RangeType.RealBody, 0, 1.0),
    CandleSetting(CandleSettingType.ShadowVeryLong, RangeType.RealBody, 0, 2.0),
    CandleSetting(CandleSettingType.ShadowShort, RangeType.Shadows, 10, 1.0),
    CandleSetting(
        CandleSettingType.ShadowVeryShort, RangeType.HighLow, 10, 0.1),
    CandleSetting(CandleSettingType.Near, RangeType.HighLow, 5, 0.2),
    CandleSetting(CandleSettingType.Far, RangeType.HighLow, 5, 0.6),
    CandleSetting(CandleSettingType.Equal, RangeType.HighLow, 5, 0.05)
  ];

  Core() {
    _unstablePeriod = List.filled(FuncUnstId.All.index, 0);
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

  ///****************************

  int adxLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return -1;
    }
    return (2 * optInTimePeriod) + (_unstablePeriod[FuncUnstId.Adx.index]) - 1;
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
    int today, lookbackTotal, outIdx;
    double prevHigh, prevLow, prevClose;
    double prevMinusDM, prevPlusDM, prevTR;
    double tempReal, tempReal2, diffP, diffM;
    double minusDI, plusDI, sumDX, prevADX;
    int i;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    lookbackTotal =
        (2 * optInTimePeriod) + (_unstablePeriod[FuncUnstId.Adx.index]) - 1;
    if (startIdx < lookbackTotal) {
      startIdx = lookbackTotal;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outIdx = 0;
    outBegIdx.value = today = startIdx;
    prevMinusDM = 0.0;
    prevPlusDM = 0.0;
    prevTR = 0.0;
    today = startIdx - lookbackTotal;
    prevHigh = inHigh[today];
    prevLow = inLow[today];
    prevClose = inClose[today];
    i = optInTimePeriod - 1;
    while (i-- > 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM += diffM;
      } else if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM += diffP;
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR += tempReal;
      prevClose = inClose[today];
    }
    sumDX = 0.0;
    i = optInTimePeriod;
    while (i-- > 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      prevMinusDM -= prevMinusDM / optInTimePeriod;
      prevPlusDM -= prevPlusDM / optInTimePeriod;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM += diffM;
      } else if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM += diffP;
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
      if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
        minusDI = (100.0 * (prevMinusDM / prevTR));
        plusDI = (100.0 * (prevPlusDM / prevTR));
        tempReal = minusDI + plusDI;
        if (!(((-0.00000001) < tempReal) && (tempReal < 0.00000001))) {
          sumDX += (100.0 * ((minusDI - plusDI).abs() / tempReal));
        }
      }
    }
    prevADX = (sumDX / optInTimePeriod);
    i = (_unstablePeriod[FuncUnstId.Adx.index]);
    while (i-- > 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      prevMinusDM -= prevMinusDM / optInTimePeriod;
      prevPlusDM -= prevPlusDM / optInTimePeriod;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM += diffM;
      } else if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM += diffP;
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
      if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
        minusDI = (100.0 * (prevMinusDM / prevTR));
        plusDI = (100.0 * (prevPlusDM / prevTR));
        tempReal = minusDI + plusDI;
        if (!(((-0.00000001) < tempReal) && (tempReal < 0.00000001))) {
          tempReal = (100.0 * ((minusDI - plusDI).abs() / tempReal));
          prevADX = (((prevADX * (optInTimePeriod - 1)) + tempReal) /
              optInTimePeriod);
        }
      }
    }
    outReal[0] = prevADX;
    outIdx = 1;
    while (today < endIdx) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      prevMinusDM -= prevMinusDM / optInTimePeriod;
      prevPlusDM -= prevPlusDM / optInTimePeriod;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM += diffM;
      } else if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM += diffP;
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
      if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
        minusDI = (100.0 * (prevMinusDM / prevTR));
        plusDI = (100.0 * (prevPlusDM / prevTR));
        tempReal = minusDI + plusDI;
        if (!(((-0.00000001) < tempReal) && (tempReal < 0.00000001))) {
          tempReal = (100.0 * ((minusDI - plusDI).abs() / tempReal));
          prevADX = (((prevADX * (optInTimePeriod - 1)) + tempReal) /
              optInTimePeriod);
        }
      }
      outReal[outIdx++] = prevADX;
    }
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int adxrLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
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
    List<double> adx;
    int adxrLookback, i, j, outIdx, nbElement;
    RetCode retCode;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    adxrLookback = this.adxrLookback(optInTimePeriod);
    if (startIdx < adxrLookback) {
      startIdx = adxrLookback;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    adx = List.filled(endIdx - startIdx + optInTimePeriod, double.nan);
    retCode = this.adx(startIdx - (optInTimePeriod - 1), endIdx, inHigh, inLow,
        inClose, optInTimePeriod, outBegIdx, outNBElement, adx);
    if (retCode != RetCode.Success) {
      return retCode;
    }
    i = optInTimePeriod - 1;
    j = 0;
    outIdx = 0;
    nbElement = endIdx - startIdx + 2;
    while (--nbElement != 0) {
      outReal[outIdx++] = ((adx[i++] + adx[j++]) / 2.0);
    }
    outBegIdx.value = startIdx;
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int emaLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return -1;
    }
    return optInTimePeriod - 1 + (_unstablePeriod[FuncUnstId.Ema.index]);
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
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    return _taIntEma(startIdx, endIdx, inReal, optInTimePeriod,
        (2.0 / (optInTimePeriod + 1)), outBegIdx, outNBElement, outReal);
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
    double tempReal, prevMA;
    int i, today, outIdx, lookbackTotal;
    lookbackTotal = emaLookback(optInTimePeriod);
    if (startIdx < lookbackTotal) startIdx = lookbackTotal;
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outBegIdx.value = startIdx;
    if ((_compatibility) == Compatibility.Default) {
      today = startIdx - lookbackTotal;
      i = optInTimePeriod;
      tempReal = 0.0;
      while (i-- > 0) {
        tempReal += inReal[today++];
      }
      prevMA = tempReal / optInTimePeriod;
    } else {
      prevMA = inReal[0];
      today = 1;
    }
    while (today <= startIdx) {
      prevMA = ((inReal[today++] - prevMA) * optInK_1) + prevMA;
    }
    outReal[0] = prevMA;
    outIdx = 1;
    while (today <= endIdx) {
      prevMA = ((inReal[today++] - prevMA) * optInK_1) + prevMA;
      outReal[outIdx++] = prevMA;
    }
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int mfiLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return -1;
    }
    return optInTimePeriod + (_unstablePeriod[FuncUnstId.Mfi.index]);
  }

  RetCode mfi(
      int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      List<double> inVolume,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    double posSumMF, negSumMF, prevValue;
    double tempValue1, tempValue2;
    int lookbackTotal, outIdx, i, today;
    int mflowIdx = 0;
    List<MoneyFlow> mflow;
    int maxIdxmflow = (50 - 1);
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    {
      if (optInTimePeriod <= 0) {
        return RetCode.AllocErr;
      }
      mflow = List.generate(optInTimePeriod, (index) => MoneyFlow(),
          growable: false);
      maxIdxmflow = (optInTimePeriod - 1);
    }
    outBegIdx.value = 0;
    outNBElement.value = 0;
    lookbackTotal = optInTimePeriod + (_unstablePeriod[FuncUnstId.Mfi.index]);
    if (startIdx < lookbackTotal) startIdx = lookbackTotal;
    if (startIdx > endIdx) {
      return RetCode.Success;
    }
    outIdx = 0;
    today = startIdx - lookbackTotal;
    prevValue = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
    posSumMF = 0.0;
    negSumMF = 0.0;
    today++;
    for (i = optInTimePeriod; i > 0; i--) {
      tempValue1 = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
      tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      tempValue1 *= inVolume[today++];
      if (tempValue2 < 0) {
        (mflow[mflowIdx]).negative = tempValue1;
        negSumMF += tempValue1;
        (mflow[mflowIdx]).positive = 0.0;
      } else if (tempValue2 > 0) {
        (mflow[mflowIdx]).positive = tempValue1;
        posSumMF += tempValue1;
        (mflow[mflowIdx]).negative = 0.0;
      } else {
        (mflow[mflowIdx]).positive = 0.0;
        (mflow[mflowIdx]).negative = 0.0;
      }
      {
        mflowIdx++;
        if (mflowIdx > maxIdxmflow) mflowIdx = 0;
      }
    }
    if (today > startIdx) {
      tempValue1 = posSumMF + negSumMF;
      if (tempValue1 < 1.0) {
        outReal[outIdx++] = 0.0;
      } else {
        outReal[outIdx++] = 100.0 * (posSumMF / tempValue1);
      }
    } else {
      while (today < startIdx) {
        posSumMF -= (mflow[mflowIdx]).positive;
        negSumMF -= (mflow[mflowIdx]).negative;
        tempValue1 = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;
        tempValue1 *= inVolume[today++];
        if (tempValue2 < 0) {
          (mflow[mflowIdx]).negative = tempValue1;
          negSumMF += tempValue1;
          (mflow[mflowIdx]).positive = 0.0;
        } else if (tempValue2 > 0) {
          (mflow[mflowIdx]).positive = tempValue1;
          posSumMF += tempValue1;
          (mflow[mflowIdx]).negative = 0.0;
        } else {
          (mflow[mflowIdx]).positive = 0.0;
          (mflow[mflowIdx]).negative = 0.0;
        }
        {
          mflowIdx++;
          if (mflowIdx > maxIdxmflow) mflowIdx = 0;
        }
      }
    }
    while (today <= endIdx) {
      posSumMF -= (mflow[mflowIdx]).positive;
      negSumMF -= (mflow[mflowIdx]).negative;
      tempValue1 = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
      tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      tempValue1 *= inVolume[today++];
      if (tempValue2 < 0) {
        (mflow[mflowIdx]).negative = tempValue1;
        negSumMF += tempValue1;
        (mflow[mflowIdx]).positive = 0.0;
      } else if (tempValue2 > 0) {
        (mflow[mflowIdx]).positive = tempValue1;
        posSumMF += tempValue1;
        (mflow[mflowIdx]).negative = 0.0;
      } else {
        (mflow[mflowIdx]).positive = 0.0;
        (mflow[mflowIdx]).negative = 0.0;
      }
      tempValue1 = posSumMF + negSumMF;
      if (tempValue1 < 1.0) {
        outReal[outIdx++] = 0.0;
      } else {
        outReal[outIdx++] = 100.0 * (posSumMF / tempValue1);
      }
      {
        mflowIdx++;
        if (mflowIdx > maxIdxmflow) mflowIdx = 0;
      }
    }
    outBegIdx.value = startIdx;
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int minMaxLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return -1;
    }
    return (optInTimePeriod - 1);
  }

  RetCode minMax(
      int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outMin,
      List<double> outMax) {
    double highest, lowest, tmpHigh, tmpLow;
    int outIdx, nbInitialElementNeeded;
    int trailingIdx, today, i, highestIdx, lowestIdx;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    nbInitialElementNeeded = (optInTimePeriod - 1);
    if (startIdx < nbInitialElementNeeded) {
      startIdx = nbInitialElementNeeded;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outIdx = 0;
    today = startIdx;
    trailingIdx = startIdx - nbInitialElementNeeded;
    highestIdx = -1;
    highest = 0.0;
    lowestIdx = -1;
    lowest = 0.0;
    while (today <= endIdx) {
      tmpLow = tmpHigh = inReal[today];
      if (highestIdx < trailingIdx) {
        highestIdx = trailingIdx;
        highest = inReal[highestIdx];
        i = highestIdx;
        while (++i <= today) {
          tmpHigh = inReal[i];
          if (tmpHigh > highest) {
            highestIdx = i;
            highest = tmpHigh;
          }
        }
      } else if (tmpHigh >= highest) {
        highestIdx = today;
        highest = tmpHigh;
      }
      if (lowestIdx < trailingIdx) {
        lowestIdx = trailingIdx;
        lowest = inReal[lowestIdx];
        i = lowestIdx;
        while (++i <= today) {
          tmpLow = inReal[i];
          if (tmpLow < lowest) {
            lowestIdx = i;
            lowest = tmpLow;
          }
        }
      } else if (tmpLow <= lowest) {
        lowestIdx = today;
        lowest = tmpLow;
      }
      outMax[outIdx] = highest;
      outMin[outIdx] = lowest;
      outIdx++;
      trailingIdx++;
      today++;
    }
    outBegIdx.value = startIdx;
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int minusDILookback(int optInTimePeriod) {
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return -1;
    }
    if (optInTimePeriod > 1) {
      return optInTimePeriod + (_unstablePeriod[FuncUnstId.MinusDI.index]);
    } else {
      return 1;
    }
  }

  RetCode minusDI(
      int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int today, lookbackTotal, outIdx;
    double prevHigh, prevLow, prevClose;
    double prevMinusDM, prevTR;
    double tempReal, tempReal2, diffP, diffM;
    int i;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    if (optInTimePeriod > 1) {
      lookbackTotal =
          optInTimePeriod + (_unstablePeriod[FuncUnstId.MinusDI.index]);
    } else {
      lookbackTotal = 1;
    }
    if (startIdx < lookbackTotal) {
      startIdx = lookbackTotal;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outIdx = 0;
    if (optInTimePeriod <= 1) {
      outBegIdx.value = startIdx;
      today = startIdx - 1;
      prevHigh = inHigh[today];
      prevLow = inLow[today];
      prevClose = inClose[today];
      while (today < endIdx) {
        today++;
        tempReal = inHigh[today];
        diffP = tempReal - prevHigh;
        prevHigh = tempReal;
        tempReal = inLow[today];
        diffM = prevLow - tempReal;
        prevLow = tempReal;
        if ((diffM > 0) && (diffP < diffM)) {
          {
            tempReal = prevHigh - prevLow;
            tempReal2 = (prevHigh - prevClose).abs();
            if (tempReal2 > tempReal) tempReal = tempReal2;
            tempReal2 = (prevLow - prevClose).abs();
            if (tempReal2 > tempReal) tempReal = tempReal2;
          }
          if ((((-0.00000001) < tempReal) && (tempReal < 0.00000001))) {
            outReal[outIdx++] = 0.0;
          } else {
            outReal[outIdx++] = diffM / tempReal;
          }
        } else {
          outReal[outIdx++] = 0.0;
        }
        prevClose = inClose[today];
      }
      outNBElement.value = outIdx;
      return RetCode.Success;
    }
    outBegIdx.value = today = startIdx;
    prevMinusDM = 0.0;
    prevTR = 0.0;
    today = startIdx - lookbackTotal;
    prevHigh = inHigh[today];
    prevLow = inLow[today];
    prevClose = inClose[today];
    i = optInTimePeriod - 1;
    while (i-- > 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM += diffM;
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR += tempReal;
      prevClose = inClose[today];
    }
    i = (_unstablePeriod[FuncUnstId.MinusDI.index]) + 1;
    while (i-- != 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM = prevMinusDM - (prevMinusDM / optInTimePeriod) + diffM;
      } else {
        prevMinusDM = prevMinusDM - (prevMinusDM / optInTimePeriod);
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
    }
    if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
      outReal[0] = (100.0 * (prevMinusDM / prevTR));
    } else {
      outReal[0] = 0.0;
    }
    outIdx = 1;
    while (today < endIdx) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffM > 0) && (diffP < diffM)) {
        prevMinusDM = prevMinusDM - (prevMinusDM / optInTimePeriod) + diffM;
      } else {
        prevMinusDM = prevMinusDM - (prevMinusDM / optInTimePeriod);
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
      if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
        outReal[outIdx++] = (100.0 * (prevMinusDM / prevTR));
      } else {
        outReal[outIdx++] = 0.0;
      }
    }
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int plusDILookback(int optInTimePeriod) {
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return -1;
    }
    if (optInTimePeriod > 1) {
      return optInTimePeriod + (_unstablePeriod[FuncUnstId.PlusDI.index]);
    } else {
      return 1;
    }
  }

  RetCode plusDI(
      int startIdx,
      int endIdx,
      List<double> inHigh,
      List<double> inLow,
      List<double> inClose,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int today, lookbackTotal, outIdx;
    double prevHigh, prevLow, prevClose;
    double prevPlusDM, prevTR;
    double tempReal, tempReal2, diffP, diffM;
    int i;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    if (optInTimePeriod > 1) {
      lookbackTotal =
          optInTimePeriod + (_unstablePeriod[FuncUnstId.PlusDI.index]);
    } else {
      lookbackTotal = 1;
    }
    if (startIdx < lookbackTotal) {
      startIdx = lookbackTotal;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outIdx = 0;
    if (optInTimePeriod <= 1) {
      outBegIdx.value = startIdx;
      today = startIdx - 1;
      prevHigh = inHigh[today];
      prevLow = inLow[today];
      prevClose = inClose[today];
      while (today < endIdx) {
        today++;
        tempReal = inHigh[today];
        diffP = tempReal - prevHigh;
        prevHigh = tempReal;
        tempReal = inLow[today];
        diffM = prevLow - tempReal;
        prevLow = tempReal;
        if ((diffP > 0) && (diffP > diffM)) {
          {
            tempReal = prevHigh - prevLow;
            tempReal2 = (prevHigh - prevClose).abs();
            if (tempReal2 > tempReal) tempReal = tempReal2;
            tempReal2 = (prevLow - prevClose).abs();
            if (tempReal2 > tempReal) tempReal = tempReal2;
          }
          if ((((-0.00000001) < tempReal) && (tempReal < 0.00000001))) {
            outReal[outIdx++] = 0.0;
          } else {
            outReal[outIdx++] = diffP / tempReal;
          }
        } else {
          outReal[outIdx++] = 0.0;
        }
        prevClose = inClose[today];
      }
      outNBElement.value = outIdx;
      return RetCode.Success;
    }
    outBegIdx.value = today = startIdx;
    prevPlusDM = 0.0;
    prevTR = 0.0;
    today = startIdx - lookbackTotal;
    prevHigh = inHigh[today];
    prevLow = inLow[today];
    prevClose = inClose[today];
    i = optInTimePeriod - 1;
    while (i-- > 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM += diffP;
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR += tempReal;
      prevClose = inClose[today];
    }
    i = (_unstablePeriod[FuncUnstId.PlusDI.index]) + 1;
    while (i-- != 0) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod) + diffP;
      } else {
        prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod);
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
    }
    if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
      outReal[0] = (100.0 * (prevPlusDM / prevTR));
    } else {
      outReal[0] = 0.0;
    }
    outIdx = 1;
    while (today < endIdx) {
      today++;
      tempReal = inHigh[today];
      diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow[today];
      diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffP > 0) && (diffP > diffM)) {
        prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod) + diffP;
      } else {
        prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod);
      }
      {
        tempReal = prevHigh - prevLow;
        tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) tempReal = tempReal2;
      }
      prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
      prevClose = inClose[today];
      if (!(((-0.00000001) < prevTR) && (prevTR < 0.00000001))) {
        outReal[outIdx++] = (100.0 * (prevPlusDM / prevTR));
      } else {
        outReal[outIdx++] = 0.0;
      }
    }
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int rocLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return -1;
    }
    return optInTimePeriod;
  }

  RetCode roc(
      int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int inIdx, outIdx, trailingIdx;
    double tempReal;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    if (startIdx < optInTimePeriod) {
      startIdx = optInTimePeriod;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outIdx = 0;
    inIdx = startIdx;
    trailingIdx = startIdx - optInTimePeriod;
    while (inIdx <= endIdx) {
      tempReal = inReal[trailingIdx++];
      if (tempReal != 0.0) {
        outReal[outIdx++] = ((inReal[inIdx] / tempReal) - 1.0) * 100.0;
      } else {
        outReal[outIdx++] = 0.0;
      }
      inIdx++;
    }
    outNBElement.value = outIdx;
    outBegIdx.value = startIdx;
    return RetCode.Success;
  }

  int rocRLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return -1;
    }
    return optInTimePeriod;
  }

  RetCode rocR(
      int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int inIdx, outIdx, trailingIdx;
    double tempReal;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    if (startIdx < optInTimePeriod) {
      startIdx = optInTimePeriod;
    }
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    outIdx = 0;
    inIdx = startIdx;
    trailingIdx = startIdx - optInTimePeriod;
    while (inIdx <= endIdx) {
      tempReal = inReal[trailingIdx++];
      if (tempReal != 0.0) {
        outReal[outIdx++] = (inReal[inIdx] / tempReal);
      } else {
        outReal[outIdx++] = 0.0;
      }
      inIdx++;
    }
    outNBElement.value = outIdx;
    outBegIdx.value = startIdx;
    return RetCode.Success;
  }

  int rsiLookback(int optInTimePeriod) {
    int retValue;
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return -1;
    }
    retValue = optInTimePeriod + (_unstablePeriod[FuncUnstId.Rsi.index]);
    if ((_compatibility) == Compatibility.Metastock) {
      retValue--;
    }
    return retValue;
  }

  RetCode rsi(
      int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    int outIdx;
    int today, lookbackTotal, unstablePeriod, i;
    double prevGain, prevLoss, prevValue, savePrevValue;
    double tempValue1, tempValue2;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    outBegIdx.value = 0;
    outNBElement.value = 0;
    lookbackTotal = rsiLookback(optInTimePeriod);
    if (startIdx < lookbackTotal) {
      startIdx = lookbackTotal;
    }
    if (startIdx > endIdx) {
      return RetCode.Success;
    }
    outIdx = 0;
    if (optInTimePeriod == 1) {
      outBegIdx.value = startIdx;
      i = (endIdx - startIdx) + 1;
      outNBElement.value = i;
      List.copyRange(outReal, 0, inReal, startIdx, startIdx + i);
      return RetCode.Success;
    }
    today = startIdx - lookbackTotal;
    prevValue = inReal[today];
    unstablePeriod = (_unstablePeriod[FuncUnstId.Rsi.index]);
    if ((unstablePeriod == 0) &&
        ((_compatibility) == Compatibility.Metastock)) {
      savePrevValue = prevValue;
      prevGain = 0.0;
      prevLoss = 0.0;
      for (i = optInTimePeriod; i > 0; i--) {
        tempValue1 = inReal[today++];
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;
        if (tempValue2 < 0) {
          prevLoss -= tempValue2;
        } else {
          prevGain += tempValue2;
        }
      }
      tempValue1 = prevLoss / optInTimePeriod;
      tempValue2 = prevGain / optInTimePeriod;
      tempValue1 = tempValue2 + tempValue1;
      if (!(((-0.00000001) < tempValue1) && (tempValue1 < 0.00000001))) {
        outReal[outIdx++] = 100 * (tempValue2 / tempValue1);
      } else {
        outReal[outIdx++] = 0.0;
      }
      if (today > endIdx) {
        outBegIdx.value = startIdx;
        outNBElement.value = outIdx;
        return RetCode.Success;
      }
      today -= optInTimePeriod;
      prevValue = savePrevValue;
    }
    prevGain = 0.0;
    prevLoss = 0.0;
    today++;
    for (i = optInTimePeriod; i > 0; i--) {
      tempValue1 = inReal[today++];
      tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      if (tempValue2 < 0) {
        prevLoss -= tempValue2;
      } else {
        prevGain += tempValue2;
      }
    }
    prevLoss /= optInTimePeriod;
    prevGain /= optInTimePeriod;
    if (today > startIdx) {
      tempValue1 = prevGain + prevLoss;
      if (!(((-0.00000001) < tempValue1) && (tempValue1 < 0.00000001))) {
        outReal[outIdx++] = 100.0 * (prevGain / tempValue1);
      } else {
        outReal[outIdx++] = 0.0;
      }
    } else {
      while (today < startIdx) {
        tempValue1 = inReal[today];
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;
        prevLoss *= (optInTimePeriod - 1);
        prevGain *= (optInTimePeriod - 1);
        if (tempValue2 < 0) {
          prevLoss -= tempValue2;
        } else {
          prevGain += tempValue2;
        }
        prevLoss /= optInTimePeriod;
        prevGain /= optInTimePeriod;
        today++;
      }
    }
    while (today <= endIdx) {
      tempValue1 = inReal[today++];
      tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      prevLoss *= (optInTimePeriod - 1);
      prevGain *= (optInTimePeriod - 1);
      if (tempValue2 < 0) {
        prevLoss -= tempValue2;
      } else {
        prevGain += tempValue2;
      }
      prevLoss /= optInTimePeriod;
      prevGain /= optInTimePeriod;
      tempValue1 = prevGain + prevLoss;
      if (!(((-0.00000001) < tempValue1) && (tempValue1 < 0.00000001))) {
        outReal[outIdx++] = 100.0 * (prevGain / tempValue1);
      } else {
        outReal[outIdx++] = 0.0;
      }
    }
    outBegIdx.value = startIdx;
    outNBElement.value = outIdx;
    return RetCode.Success;
  }

  int smaLookback(int optInTimePeriod) {
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
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
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 2) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    return _taIntSma(startIdx, endIdx, inReal, optInTimePeriod, outBegIdx,
        outNBElement, outReal);
  }

  RetCode _taIntSma(
      int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    double periodTotal, tempReal;
    int i, outIdx, trailingIdx, lookbackTotal;
    lookbackTotal = (optInTimePeriod - 1);
    if (startIdx < lookbackTotal) startIdx = lookbackTotal;
    if (startIdx > endIdx) {
      outBegIdx.value = 0;
      outNBElement.value = 0;
      return RetCode.Success;
    }
    periodTotal = 0;
    trailingIdx = startIdx - lookbackTotal;
    i = trailingIdx;
    if (optInTimePeriod > 1) {
      while (i < startIdx) {
        periodTotal += inReal[i++];
      }
    }
    outIdx = 0;
    do {
      periodTotal += inReal[i++];
      tempReal = periodTotal;
      periodTotal -= inReal[trailingIdx++];
      outReal[outIdx++] = tempReal / optInTimePeriod;
    } while (i <= endIdx);
    outNBElement.value = outIdx;
    outBegIdx.value = startIdx;
    return RetCode.Success;
  }

  int trixLookback(int optInTimePeriod) {
    int emaLookback;
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return -1;
    }
    emaLookback = this.emaLookback(optInTimePeriod);
    return (emaLookback * 3) + rocRLookback(1);
  }

  RetCode trix(
      int startIdx,
      int endIdx,
      List<double> inReal,
      int optInTimePeriod,
      MInteger outBegIdx,
      MInteger outNBElement,
      List<double> outReal) {
    double k;
    List<double> tempBuffer;
    MInteger nbElement = MInteger();
    MInteger begIdx = MInteger();
    int totalLookback;
    int emaLookback, rocLookback;
    RetCode retCode;
    int nbElementToOutput;
    if (startIdx < 0) {
      return RetCode.OutOfRangeStartIndex;
    }
    if ((endIdx < 0) || (endIdx < startIdx)) {
      return RetCode.OutOfRangeEndIndex;
    }
    if ((optInTimePeriod < 1) || (optInTimePeriod > 100000)) {
      return RetCode.BadParam;
    }
    emaLookback = this.emaLookback(optInTimePeriod);
    rocLookback = rocRLookback(1);
    totalLookback = (emaLookback * 3) + rocLookback;
    if (startIdx < totalLookback) {
      startIdx = totalLookback;
    }
    if (startIdx > endIdx) {
      outNBElement.value = 0;
      outBegIdx.value = 0;
      return RetCode.Success;
    }
    outBegIdx.value = startIdx;
    nbElementToOutput = (endIdx - startIdx) + 1 + totalLookback;
    tempBuffer = List.filled(nbElementToOutput, double.nan);
    k = (2.0 / ((optInTimePeriod + 1)));
    retCode = _taIntEma((startIdx - totalLookback), endIdx, inReal,
        optInTimePeriod, k, begIdx, nbElement, tempBuffer);
    if ((retCode != RetCode.Success) || (nbElement.value == 0)) {
      outNBElement.value = 0;
      outBegIdx.value = 0;
      return retCode;
    }
    nbElementToOutput--;
    nbElementToOutput -= emaLookback;
    retCode = _taIntEma(0, nbElementToOutput, tempBuffer, optInTimePeriod, k,
        begIdx, nbElement, tempBuffer);
    if ((retCode != RetCode.Success) || (nbElement.value == 0)) {
      outNBElement.value = 0;
      outBegIdx.value = 0;
      return retCode;
    }
    nbElementToOutput -= emaLookback;
    retCode = _taIntEma(0, nbElementToOutput, tempBuffer, optInTimePeriod, k,
        begIdx, nbElement, tempBuffer);
    if ((retCode != RetCode.Success) || (nbElement.value == 0)) {
      outNBElement.value = 0;
      outBegIdx.value = 0;
      return retCode;
    }
    nbElementToOutput -= emaLookback;
    retCode =
        roc(0, nbElementToOutput, tempBuffer, 1, begIdx, outNBElement, outReal);
    if ((retCode != RetCode.Success) || (outNBElement.value == 0)) {
      outNBElement.value = 0;
      outBegIdx.value = 0;
      return retCode;
    }
    return RetCode.Success;
  }
}
