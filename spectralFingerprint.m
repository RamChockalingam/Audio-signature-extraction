function [ peakMags, peaksIndx, F, T ] = spectralFingerprint(dataS, fs, tRes, noverlap, gridSize)
%SPECTRALFINGERPRINT - Computes the spectrogram and detects peaks

% 🎵 **Step 1: Compute the Spectrogram**
segment = tRes * fs; 
[S, F, T] = spectrogram(dataS, blackman(segment), noverlap, [], fs);  
magS = abs(S)';

% 🎨 **Step 2: Display the Spectrogram**
figure;  
imagesc(T, F, mag2db(magS')); % Convert magnitude to decibels
axis xy;
colormap jet;
colorbar;
title('Spectrogram of Input Audio');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');

% 🔍 **Step 3: Continue with Peak Detection (Your Original Code)**
tempS = zeros(size(magS,1) + 2*gridSize(end), size(magS,2) + 2*gridSize(end)) * -inf;
tempS((max(gridSize)+1):size(magS,1)+max(gridSize), (max(gridSize)+1):size(magS,2)+max(gridSize)) = mag2db(magS);

peaks = ones(size(magS,1) + 2*gridSize(end), size(magS,2) + 2*gridSize(end));
Tpeaks = ones(size(magS,1) + 2*gridSize(end), size(magS,2) + 2*gridSize(end));    

for horShift = -gridSize:gridSize
    for vertShift = -gridSize:gridSize
        if (vertShift ~= 0 || horShift ~= 0)
            gridWin = circshift(tempS, [horShift, vertShift]);
            peaks = (tempS > gridWin);
            Tpeaks = Tpeaks .* peaks;
        end
    end
end

peaksIndx = Tpeaks(max(gridSize)+1:size(magS,1)+max(gridSize), max(gridSize)+1:size(magS,2)+max(gridSize));         
peakMags = peaksIndx .* magS;

end
