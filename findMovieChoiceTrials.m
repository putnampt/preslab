clear all
clc

dataPath = 'D:\dat\pl2\MittensINOTMovieChoiceNeurophys\Mittens_062916\Mittens_062916_MovieChoice5_Vial5.pl2';
logPath = 'D:\dat\pl2\MittensINOTMovieChoiceNeurophys\Mittens_062916\Mittens_062916_Logs';
itemFilePath = 'D:\dat\pl2\MittensINOTMovieChoiceNeurophys\Mittens_062916\movieChoice5_itm.txt';

try
    [ sessionLogs ] = loadSessionLogFiles( logPath );
catch logFileErr
    
end

try
   [ itemNumber, item, associatedReward ] = loadMovieChoiceItemFile( itemFilePath );
catch itemFileErr
    
end

lookAhead = 3;
expectedFrames = [1001:1150];

% ------------------ Load Data file -----------------
pl2 = PL2GetFileIndex(dataPath);

[strobed] = PL2EventTs(dataPath, 'Strobed');

vals = strobed.Strobed;

times = strobed.Ts;
% ---------------------------------------------------

% ------------- Task Encode Definitions -------------
trialStartCode		= 11;				% Code for start of trial
trialEndCode		= 21;				% Code for end of trial
startCueOnCode 		= 12;				% Code for start cue on
startCueHitCode 	= 22;				% Code for monkey missing start cue
startCueMissCode 	= 23;				% Code for monkey hitting start cue
startCueIgnoreCode 	= 24;				% Code for monkey ignoring start cue
stimulusOnCode		= 15;				% Code for stimulus onset
stimulusOffCode		= 25;				% Code for stimulus offset
earlyTouchCode		= 14;				% Code for monkey making an early touch
touchAvailableCode 	= 26;				% Code for availability of choice
leftChoiceCode 		= 16;				% Code for left option chosen
rightChoiceCode 	= 17;				% Code for right option chosen
ignoreChoiceCode 	= 18;				% Code for ignored stimulus
missChoiceCode 		= 19;				% Code for missed choice
ITIStartCode		= 20;				% Code for start of ITI
ITIEndCode			= 30;				% Code for end of ITI
rewardGivenCode 	= 3;				% Code for reward delivered
taskStartCode 		= 1;				% Code for start of task (presentation start)
taskEndCode 		= 2;				% Code for end of task (presentation exit)
leftItmNumIDCode 	= 6;				% Code precending left item number
rightItmNumIDCode 	= 7;				% Code precending right item number
cndNumIDCode 		= 5;				% Code precending condition number
magicNumberCode		= 9;				% Code precending magic numbers
conditionOffsetValue= 100;              % Offset of condition values
frameOffsetValue	= 1000;             % Offset of frame indicies
itemOffsetValue 	= 200;              % Offset of item values
% ---------------------------------------------------


% ---------------- Find magic numbers ---------------
magicCodeIdx = find(vals == magicNumberCode);


[taskStartIdx] = find(vals == taskStartCode);

magicClusterIdxs = kmeans(times(magicCodeIdx),numel(taskStartIdx),'dist','sqeuclidean');

uniqueClusterIDs = unique(magicClusterIdxs);

for mc = 1:numel(uniqueClusterIDs)
    thisClusterID = uniqueClusterIDs(mc);
    
    thisClusterIdxs = magicCodeIdx( find(magicClusterIdxs == thisClusterID) );
    
    thisClusterMagicVals = vals(thisClusterIdxs+1);
    
    fprintf('Cluster ID%2d\t1st Index%5d\tVal:%3d\n',thisClusterID, thisClusterIdxs(1), thisClusterMagicVals(1));
    
    magicVals{mc}= thisClusterMagicVals;
    magicIdxs{mc} = thisClusterIdxs+1;
    magicStartIdx(mc) = thisClusterIdxs(1)+1;
    
end

[orderedMagicStartIdx,magicSortIdx] = sort(magicStartIdx);

orderedMagicVals = magicVals(magicSortIdx);
orderedMagicIdxs = magicIdxs(magicSortIdx);

juiceIdx =find(vals == rewardGivenCode);

codeAssociatedMagicCluster = zeros(size(vals));

for c = 1:length(orderedMagicStartIdx)-1
    
    orderedMagicStartIdx(c);
    
    codeAssociatedMagicCluster(orderedMagicStartIdx(c):orderedMagicStartIdx(c+1)) = c;
    
end
c = c+1;

codeAssociatedMagicCluster(orderedMagicStartIdx(c):end) = c;


tc = 0;
for f = 1 : size(expectedFrames,2)
    
    frameIdx{f} = find( vals == expectedFrames(f) );
    framesFound(f) = numel( frameIdx{f});
    
    allFramesIdx( (tc+1) : (tc +numel(frameIdx{f}) ) ) = frameIdx{f};
    
    tc = tc+numel(frameIdx{f});
    
end


allFramesIdxTrialNumber = zeros(size(allFramesIdx));

allFramesIdx = sort(allFramesIdx);

ec = 1; % encode count
sc = 0; % Stim count
bc = 0; % block count
tc = 0; % trial count

wbtc = 0; % within block trial count

while ec <= size(vals,1)-lookAhead
    
    if vals(ec) == taskStartCode
        bc = bc + 1;
        wbtc = 0;
    end
    
    if vals(ec) == trialStartCode
        tc = tc + 1;
        wbtc = wbtc + 1;
    end
    
    
    if vals(ec) == stimulusOnCode || ~isempty(intersect(expectedFrames(1:lookAhead), vals(ec)))
        
        sc = sc + 1;
        
        potential(sc).condition = 0;
        potential(sc).leftItem = 0;
        potential(sc).rightItem = 0;
        
        potential(sc).magicNumbers = orderedMagicVals{codeAssociatedMagicCluster(ec)};
         
        try
            trialInfoCodes = vals( (ec-8) : ec);
            
            try 
                cndNumIDCodeIdx = find(trialInfoCodes == cndNumIDCode);   
                if trialInfoCodes(cndNumIDCodeIdx+1) > conditionOffsetValue
                    potential(sc).condition = (trialInfoCodes(cndNumIDCodeIdx+1))-conditionOffsetValue;
                    
                   
                end
            catch err1
                
            end
            
            try 
                 leftItmNumIDCodeIdx = find(trialInfoCodes == leftItmNumIDCode);
                
                if trialInfoCodes(leftItmNumIDCodeIdx+1) > itemOffsetValue
                    potential(sc).leftItem =(trialInfoCodes(leftItmNumIDCodeIdx+1))-itemOffsetValue;
                    
                     if exist('item', 'var')
                         potential(sc).leftFileName = item(  find(itemNumber == potential(sc).leftItem) );
                         
                         potential(sc).leftAssociatedReward = associatedReward(  find(itemNumber == potential(sc).leftItem) );
                    end
                end
            catch err2
                
            end
            
             try 
                 rightItmNumIDCodeIdx = find(trialInfoCodes == rightItmNumIDCode);
                
                if trialInfoCodes(rightItmNumIDCodeIdx+1) > itemOffsetValue
                    potential(sc).rightItem =(trialInfoCodes(rightItmNumIDCodeIdx+1))-itemOffsetValue;
                    
                     if exist('item', 'var')
                         potential(sc).rightFileName = item(  find(itemNumber == potential(sc).rightItem) );
                         
                         potential(sc).rightAssociatedReward = associatedReward(  find(itemNumber == potential(sc).rightItem) );
                    end
                end
            catch err3
                
            end

        catch err0
            
        end

        if vals(ec) == stimulusOnCode
            
            potential(sc).stimOnIdx = ec;
            potential(sc).stimOnS = times(ec);
            
            fprintf('Stimulus %3d (Stimulus on)\t@ %5d / %6.2fs\t', sc, ec, times(ec));
            
        end
        
        
        
        ec = ec + 1;
        
        potential(sc).frameIdxs = zeros(size(expectedFrames));
        potential(sc).frameS = zeros(size(expectedFrames));
        potential(sc).frameVals = expectedFrames;
        potential(sc).responseStr = 'IGNORE';
        potential(sc).responseS = 0;
        potential(sc).block = bc;
        potential(sc).trial = tc;
        potential(sc).responseAvailableS = 0;
        
        foundFrames = zeros(size(expectedFrames));
        
        while ~isempty(intersect(expectedFrames, vals(ec:ec+lookAhead)))
            
            if ~isempty(intersect(expectedFrames, vals(ec)))
                
                foundFrames(find(vals(ec) == expectedFrames)) = 1;
                potential(sc).frameIdxs(find(vals(ec) == expectedFrames)) = ec;
                potential(sc).frameS(find(vals(ec) == expectedFrames)) = times(ec);
                allFramesIdxTrialNumber(find(allFramesIdx == ec)) = sc;
                
            elseif vals(ec) == leftChoiceCode
                potential(sc).responseStr = 'LEFT';
                potential(sc).responseS = times(ec);
            elseif vals(ec) == rightChoiceCode
                potential(sc).responseStr = 'RIGHT';
                potential(sc).responseS = times(ec);
            elseif vals(ec) == missChoiceCode
                potential(sc).responseStr = 'MISS';
                potential(sc).responseS = times(ec);
            elseif vals(ec) == touchAvailableCode || vals(ec) == 1075
                potential(sc).responseAvailableS =  times(ec);
            end
            
            ec = ec + 1;
        end
        
        if vals(ec) == earlyTouchCode
            potential(sc).responseStr = 'EARLY';
            potential(sc).responseS = times(ec);
        end
        
        if vals(ec) == stimulusOffCode
            
             potential(sc).juiceDropsRecieved = 0;
            
             ec = ec + 1;
   
             if vals(ec) == rewardGivenCode 
                 while vals(ec) == rewardGivenCode
                     potential(sc).juiceDropsRecieved =  potential(sc).juiceDropsRecieved +1;
                     ec = ec + 1;
                 end
             end
        end
        
        fprintf('%7s (%6.2fs)\t', potential(sc).responseStr, potential(sc).responseS);
        fprintf('%3d/%3d frames found\t', sum(foundFrames), numel(expectedFrames));
        fprintf('Block: %2d Trial: %3d (%3d)\t',  potential(sc).block, potential(sc).trial, wbtc);
        fprintf('\n');
        
    else
        ec = ec + 1;
    end
    
    
end

tc = 0; % trial count 

if exist('sessionLogs', 'var')
   
    
else
    
end

% framesClust(:, 1) = times(allFramesIdx);
% framesClust(:, 2) = allFramesIdx;
% framesClust(:, 3) = allFramesIdxTrialNumber;
% c = clusterdata(framesClust,'linkage','ward','savememory','on','maxclust',max(framesFound));

%hist(framesFound);

