% Load the Sleep-EDF data into MATLAB
[signal, header] = readedf('Sleep-EDF.edf');

% Extract the EEG signals and the corresponding sleep stage annotations
eeg = signal(1,:); % Assuming the EEG signal is in the first channel
sleepStages = signal(end,:); % Assuming the sleep stage annotations are in the last channel

% Define the sample rate of the EEG signals
sampleRate = header.frequency(1);

% Filter the EEG signals to remove high-frequency noise
lowPassCutoff = 30; % in Hz
[b,a] = butter(2, lowPassCutoff/(sampleRate/2), 'low');
eegFiltered = filtfilt(b,a, eeg);

% Divide the filtered EEG signals into 30-second segments
segmentLength = sampleRate*30; % 30 seconds
numSegments = floor(length(eegFiltered)/segmentLength);
eegSegmented = reshape(eegFiltered(1:numSegments*segmentLength), segmentLength, numSegments);

% Calculate the variability of the EEG signals for each segment
variability = std(eegSegmented, [], 1);

% Plot the variability of the EEG signals against the corresponding sleep stages
scatter(sleepStages(1:numSegments*segmentLength), variability);
xlabel('Sleep Stage');
ylabel('EEG Variability (\muV)');

% Perform statistical tests to demonstrate the relationship between EEG signal variability and sleep stage

% Split sleep stages into stages 1, 2, 3, 4, and REM
sleepStagesBinary = zeros(size(sleepStages));
sleepStagesBinary(sleepStages == 1) = 1;
sleepStagesBinary(sleepStages == 2) = 2;
sleepStagesBinary(sleepStages == 3) = 3;
sleepStagesBinary(sleepStages == 4) = 4;
sleepStagesBinary(sleepStages == 5) = 5;

% Group variability values by sleep stage
groupedVariability = cell(5,1);
for i = 1:5
groupedVariability{i} = variability(sleepStagesBinary(1:numSegments*segmentLength) == i);
end

% Perform a one-way ANOVA test to compare the variability across all sleep stages
[p,~,stats] = anova1(cell2mat(groupedVariability), sleepStagesBinary(1:numSegments*segmentLength), 'off');

% Perform multiple comparisons using the Tukey-Kramer method
c = multcompare(stats,'CType','bonferroni','Display','off');

% Find the sleep stages with significantly different variability
significantStages = unique(c(c(:,end)<0.05,1:2));

% Plot the mean variability of each sleep stage and mark the significant stages
meanVariability = zeros(5,1);
stdVariability = zeros(5,1);
for i = 1:5
meanVariability(i) = mean(groupedVariability{i});
stdVariability(i) = std(groupedVariability{i});
end

bar(meanVariability);
hold on;
errorbar(1:5, meanVariability, stdVariability, '.');
xticks(1:5);
xticklabels({'Stage 1', 'Stage 2', 'Stage 3', 'Stage 4', 'REM'});
xlabel('Sleep Stage');
ylabel('EEG Variability (\muV)');

for i = 1:size(significantStages,1)
line([significantStages(i,1), significantStages(i,1)], [0, max(meanVariability)], 'Color', 'red');
line([significantStages(i,2), significantStages(i,2)], [0, max(meanVariability)], 'Color', 'red');
line([significantStages(i,1), significantStages(i,2)], [max(meanVariability), max(meanVariability)], 'Color', 'red');
end