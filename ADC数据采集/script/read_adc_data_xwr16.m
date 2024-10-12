%%% This script is used to read the binary file produced by the DCA1000
%%% and Mmwave Studio
%%% Command to run in Matlab GUI -
% readDCA1000('<ADC capture bin file>')
function [retVal] = read_adc_data_xwr16(fileName)
    %% global variables
    % change based on sensor config
    numADCSamples = 256;    % number of ADC samples per chirp
    numADCBits = 16;        % number of ADC bits per sample
    numRX = 4;              % number of receivers
    numLanes = 2;           % do not change. number of lanes is always 2
    isReal = 0;             % set to 1 if real only data, 0 if complex data0
    
    %% read file
    fid = fopen(fileName,'r');      % read .bin file
    adcData = fread(fid, 'int16');  % 实部和虚部都是有符号的16位
    % if 12 or 14 bits ADC per sample compensate for sign extension
    if numADCBits ~= 16
        l_max = 2^(numADCBits-1)-1;
        adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
    end
    fclose(fid);
    fileSize = size(adcData, 1);
    % real data reshape, filesize = numADCSamples*numChirps 
    if isReal
        numChirps = fileSize/numADCSamples/numRX;
        LVDS = zeros(1, fileSize);
        %create column for each chirp
        LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
        %each row is data from one chirp
        LVDS = LVDS.';
    else
        % for complex data
        % filesize = 2 * numADCSamples*numChirps
        numChirps = fileSize/2/numADCSamples/numRX;%不是指一帧的chirp数，而是发的所有帧加在一起的chirp数
        LVDS = zeros(1, fileSize/2); % 将I和Q合并成complex
        %combine real and imaginary part into complex data
        %read in file: 2I is followed by 2Q
        counter = 1;
        for i=1:4:fileSize-1
            LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2);
            LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3);
            counter = counter + 2;
        end
        % create column for each chirp
        LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
        %each row is data from one chirp
        LVDS = LVDS.';
    end

    %organize data per RX
    adcData = zeros(numRX,numChirps*numADCSamples);
    for row = 1:numRX
        for i = 1: numChirps
            adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
        end
    end
    % return receiver data
    retVal = adcData;
end