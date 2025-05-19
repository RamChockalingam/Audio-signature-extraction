function hashlist = pairs2Hash(peaksIndx, dF, dT, fanout)

numPeaks = size(peaksIndx, 1);
hashlist = [];

figure;
hold on;
title('Peak Pairs Visualization');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
grid on;

for i = 1:numPeaks
    f1 = peaksIndx(i, 1); % Frequency index of first peak
    t1 = peaksIndx(i, 2); % Time index of first peak
    
    for j = i+1:min(i+fanout, numPeaks)
        f2 = peaksIndx(j, 1);
        t2 = peaksIndx(j, 2);

        % Only form pairs within time/frequency bounds
        if abs(f2 - f1) <= dF && abs(t2 - t1) <= dT
            % Store peak pair (used for hashing)
            hashlist = [hashlist; t1, t2, f1, f2];

            % 🔵 **Plot Peak Pairs as Connecting Lines**
            plot([t1, t2], [f1, f2], 'b-', 'LineWidth', 1.2);
            plot(t1, f1, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); % Red dot for peak 1
            plot(t2, f2, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b'); % Blue dot for peak 2
        end
    end
end

hold off;
