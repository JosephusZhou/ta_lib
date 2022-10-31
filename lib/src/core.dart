import 'package:ta_lib/src/m_integer.dart';

import 'ret_code.dart';

class Core {

  int smaLookback(int optInTimePeriod) {
    if (optInTimePeriod == -2147483648) {
      optInTimePeriod = 30;
    } else if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
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
      return RetCode.outOfRangeStartIndex;
    } else if (endIdx >= 0 && endIdx >= startIdx) {
      if (optInTimePeriod == -2147483648) {
        optInTimePeriod = 30;
      } else if (optInTimePeriod < 2 || optInTimePeriod > 100000) {
        return RetCode.badParam;
      }
      return _taIntSma(startIdx, endIdx, inReal, optInTimePeriod, outBegIdx,
          outNBElement, outReal);
    } else {
      return RetCode.outOfRangeEndIndex;
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
      return RetCode.success;
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
      return RetCode.success;
    }
  }
}
