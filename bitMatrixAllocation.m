% Convert satelliteBinaryData into single-line strings per satellite
bitStreamPerSatellite = strings(nSats, 1);  % 66x1 string array

for s = 1:nSats
    binRows = satelliteBinaryData{s};  % Cell array of binary strings
    if isempty(binRows)
        bitStreamPerSatellite(s) = "";  % Empty if no data
    else
        bitStreamPerSatellite(s) = join(binRows, "");  % Flatten rows
    end
end

function bits = selectBitstream(satID)

persistent bitStreams
if isempty(bitStreams)
    bitStreams = evalin('base', 'bitStreamPerSatellite');  % 66x1 cell
end
satID = min(max(1, satID), 66);  % Bound check
strBits = bitStreams{satID};
bits = double(strBits == '1');   % Convert string to 0s and 1s
end

% Input: 66x1 string array of bitstreams (each string is '010101...')
% Output: 66xN double array, where N is max bitstream length

nSats = numel(bitStreamPerSatellite);
bitLens = strlength(bitStreamPerSatellite);  % lengths of each row
maxLen = max(bitLens);  % max bitstream length

% Preallocate matrix with zeros
bitMatrix = zeros(nSats, maxLen);

for s = 1:nSats
    bits = char(bitStreamPerSatellite(s));
    if isempty(bits), continue; end
    % Convert to logical then double (bit == '1')
    bitVals = double(bits == '1');
    bitMatrix(s, 1:numel(bitVals)) = bitVals;
end





