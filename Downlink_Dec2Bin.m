clc;

scale = 1e4; % Precision scale
[nRows, nCols] = size(downlink);

% Auto-determine required bit widths per column (unsigned magnitude)
bitWidths = zeros(1, nCols);
for j = 1:nCols
    maxVal = max(abs(downlink(:, j)));
    maxInt = floor(maxVal * scale);
    bitWidths(j) = ceil(log2(maxInt + 1));  % +1 to cover the full range
end

% Preallocate binary output array
binaryOut = strings(nRows, nCols);

% Encode with sign bit only for lat/lon
for i = 1:nRows
    for j = 1:nCols
        val = downlink(i, j);
        useSign = j <= 2;
        signBit = '';
        if useSign
            signBit = '0';
            if val < 0
                signBit = '1';
                val = -val;
            end
        end
        valInt = floor(val * scale);
        binMag = dec2bin(valInt, bitWidths(j));
        binaryOut(i, j) = cat(2, signBit, binMag);  % Concatenate
    end
end

%% Decode
decoded = zeros(nRows, nCols);
for i = 1:nRows
    for j = 1:nCols
        binStr = binaryOut(i, j);
        useSign = j <= 2;
        if useSign
            signBit = binStr(1);
            magPart = extractAfter(binStr, 1);
            valInt = bin2dec(magPart);
            val = valInt / scale;
            if signBit == "1"
                val = -val;
            end
        else
            val = bin2dec(binStr) / scale;
        end
        decoded(i, j) = val;
    end
end

%% Accuracy Verification
diffs = abs(abs(decoded) - abs(downlink)) ./ abs(downlink) * 100;
maxPercentDiff = max(diffs, [], 'all', 'omitnan');
disp(" Max percent difference: " + maxPercentDiff + " %")
