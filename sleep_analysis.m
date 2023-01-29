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
