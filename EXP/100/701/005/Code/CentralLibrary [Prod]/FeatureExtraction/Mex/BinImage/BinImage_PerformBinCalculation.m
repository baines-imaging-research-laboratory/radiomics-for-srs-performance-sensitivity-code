function dBinnedValue = BinImage_PerformBinCalculation(dRawValue, dFirstBinEdge, dBinSize, dNumberOfBins)

dBinnedValue = ceil( ( dRawValue - dFirstBinEdge + 1) ./ dBinSize);

dBinnedValue = min(dBinnedValue, dNumberOfBins);
dBinnedValue = max(dBinnedValue, 1);

end

