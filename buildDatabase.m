% reads all MP3 files in 'dir' and adds them to a database.
% Implements spectral fingerprinting and hash index pipeline algorithm.
% Produces two .mat files: "HASHTABLE" and "SONGID" which are used as a song
% identification database references.

%% Parameters for spectral processing
newSampleRate = 8e3; % Downsample sampling value [Hz]
tRes = 0.064; % Time resolution / size of each time segment [sec]
overlapSize = 50; % Percentage of overlap between segments [%]
gridSize = 4; % Maximal grid distance for peak search [pixel]

% Peak-pairs window size parameters
Fband = 200; % [Hz] 
Tlen = 1; % [sec]
fanout = 3; % Number of maximal peaks pairs in window

save('settings.mat','newSampleRate','tRes','overlapSize','gridSize','Fband','Tlen','fanout');    

%% Songs database creation process

dir = 'songs'; % Folder name which has the audio files
songs = getMp3List(dir);

% Initialize global hashtable with a predefined size
global hashtable;
hashTableSize = 100000; % Define an appropriate size based on your application
hashtable = cell(hashTableSize, 2);

% Load existing song database if available
if ~exist('songid', 'var')
    if exist('SONGID.mat', 'file')
        load('SONGID.mat');
        load('HASHTABLE.mat');
        fprintf('[DEBUG] Loaded existing song database with %d songs.\n', length(songid));
    else  
        songid = cell(0);
        hashtable = cell(hashTableSize, 2);
        fprintf('[DEBUG] No existing song database found. Starting fresh.\n');
    end
end

songIndex = length(songid);
NewSongs = 0; % Flag to track if new songs were added

% Adding songs to database
for i = 1:length(songs)
    songFound = 0;
    
    % Check if song is already in the database
    for m = 1:length(songid)
        if strcmp(songs{i}, songid{m})
            songFound = 1;
            fprintf('[DEBUG] Skipping existing song: %s (ID: %d)\n', songs{i}, m);
            break;
        end
    end
    
    % If song is new, process and add to the database
    if ~songFound
        NewSongs = 1;
        songIndex = songIndex + 1;
        filename = strcat(dir, filesep, songs{i});
        
        fprintf('[DEBUG] Processing new song: %s (ID: %d)\n', songs{i}, songIndex);
        
        [dataS, fs] = mp3SongRead(filename, newSampleRate); % Read audio file
        fprintf('[DEBUG] Loaded song: %s | Sample rate: %d Hz | Data length: %d\n', songs{i}, fs, length(dataS));

        [peakMags, peaksIndx, F, T] = spectralFingerprint(dataS, fs, tRes, 100/overlapSize, gridSize);
        fprintf('[DEBUG] Extracted %d peaks from song: %s\n', length(peaksIndx), songs{i});
        
        [dF, dT] = size2pixel(F, T, Fband, Tlen);
        [hashlist] = pairs2Hash(peaksIndx, dF, dT, fanout);
        fprintf('[DEBUG] Generated %d hashes for song: %s\n', length(hashlist), songs{i});
        
        addHashTable(hashlist, songIndex);
        fprintf('[DEBUG] Added song hashes to hashtable.\n');
        
        songid{songIndex, 1} = songs{i}; % Store song in database
    end
end

global numSongs;
numSongs = songIndex;

% Save updated database if new songs were added
if NewSongs
    save('SONGID.mat', 'songid');
    save('HASHTABLE.mat', 'hashtable');
    fprintf('[DEBUG] Updated database saved with %d songs.\n', numSongs);
else
    fprintf('[DEBUG] No new songs added. Database remains unchanged.\n');
end
