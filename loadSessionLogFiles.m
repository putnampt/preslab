function [ sessionLogs ] = batchMovieLogFiles( logPath )
%logPath = 'D:\dat\pl2\MittensINOTMovieChoiceNeurophys\Mittens_062916\Mittens_062916_Logs';
    minTrials = 3;

    logDir = dir(logPath);

    tc = 0;

    for d = 1:size(logDir,1)

        findLogText = regexp(logDir(d).name, '_log');

        if ~logDir(d).isdir && ~isempty(findLogText)
            logFilePath = fullfile(logPath, logDir(d).name);
            try
                [ this_itmFile, this_cndFile, this_dateAndTime, this_trial, this_block, this_lVal, this_rVal, this_lName, this_rName, this_resp, this_start, this_stop, this_correct, this_date, this_time, this_magics] = readMovieLogFileInternal( logFilePath );
                if size(this_trial,2) > minTrials


                    try
                        for i = 1 : size(this_trial,2)

                            tc = tc+1;

                            itemFile{tc} = strtrim(this_itmFile{i});
                            cndFile{tc} = strtrim(this_cndFile{i});
                            date{tc} = this_date{i};
                            time{tc} = this_time{i};
                            leftVal(tc) = this_lVal(i);
                            rightVal(tc) = this_rVal(i);
                            leftName{tc} = this_lName{i};
                            rightName{tc} = this_rName{i};
                            resp{tc} = this_resp{i};
                            correct(tc) = this_correct(i);
                            magic{tc} = this_magics{i};

                            fprintf('%s\t%s\t%s\t%s\t%s vs %s\tchoose: %s\n', date{tc}, time{tc}, itemFile{tc}, cndFile{tc}, leftName{tc}, rightName{tc}, resp{tc});

                            if strcmp(resp{tc}, 'Right')
                                netJuice(tc) = rightVal(tc)-leftVal(tc);
                            elseif strcmp(resp{tc}, 'Left')
                                netJuice(tc) = leftVal(tc)-rightVal(tc);
                            else
                                netJuice(tc) = 0;
                            end


                        end
                    catch err
                    end
                end
            catch err
            end
            clear this_itmFile this_cndFile this_dateAndTime this_trial this_block this_lVal this_rVal this_resp this_start this_stop this_correct this_date this_time this_lName this_rName
        end

    end

    for lc = 1:tc
        sessionLogs{lc, 1} = itemFile{lc};
        sessionLogs{lc,2} = cndFile{lc};
        sessionLogs{lc,3} = date{lc};
        sessionLogs{lc,4} = time{lc};
        sessionLogs{lc,5} = leftVal(lc);
        sessionLogs{lc,6} = rightVal(lc);
        sessionLogs{lc,7} = leftName{lc};
        sessionLogs{lc,8} = rightName{lc};
        sessionLogs{lc,9} = resp{lc};
        sessionLogs{lc,10} = correct(lc);
        sessionLogs{lc,11} = netJuice(lc);
        sessionLogs{lc,12} = magic(lc);
        
    end
end

function [ itmFile, cndFile, dateAndTime, trial, block, lVal, rVal, lName, rName, resp, start, stop, correct, date, time, magics] = readMovieLogFileInternal( logFilePath )
%READLOGFILE Summary of this function goes here
%   Detailed explanation goes here

% clear all
% clc
% logFilePath ='D:\dev\preslab\readLogFiles\Logs\05-19-2016_12-18-40_log.txt';


[PATHSTR,NAME,EXT] = fileparts(logFilePath);

% Read in the file
fid = fopen(logFilePath);
readLine = fgets(fid);
linesRead = 1;
while ischar(readLine)
    %disp(readLine);
    lines{linesRead} = readLine;
    readLine = fgets(fid);
    linesRead = linesRead+1;
end

fclose(fid);

% Search for the parameter file
try
    parameterLine = validatestring('PARM:',lines);
    [a,b]= regexp(parameterLine, 'PARM:\t');
    parameterFile = parameterLine(b:end);
catch err
    parameterFile = [];
end

% Search for the item file
try
    itemLine = validatestring('ITEM:',lines);
    [a,b]= regexp(itemLine, 'ITEM:\t');
    itemFile = itemLine(b:end);
catch err
    itemFile = [];
end

% Search for the magic numbers file
try
    magicLine = validatestring('MagicNumbers:',lines);
    [a,b]= regexp(magicLine, 'MagicNumbers:\t');
    magicNumbersLine = magicLine(b:end);
    magicNumbers = sscanf(magicNumbersLine, ['%d\t']);
catch err
    magicNumbers = [];
end


% Search for the condition file
try
    condLine = validatestring('COND:',lines);
    [a,b]= regexp(condLine, 'COND:\t');
    condFile = condLine(b:end);
catch err
    condFile = [];
end

% Search for the date file
try
    dateLine = validatestring('DATE:',lines);
    [a,b]= regexp(dateLine, 'DATE:\t');
    dateStr = dateLine(b:end);
catch err
    dateStr = [];
end


trialLineIdxs = find(not(cellfun('isempty',  strfind(lines, 'Trl'))));

tc = 1;

for t = trialLineIdxs
    thisLine = lines{t};
     try
        
        
        [a,b] = regexp(thisLine, 'Trl:\t');
        [c,d] = regexp(thisLine, 'Blk:\t');
        [e,f] = regexp(thisLine, 'Cnd:\t');
        [g,h] = regexp(thisLine, 'LVal:\t');
        [i,j] = regexp(thisLine, 'RVal:\t');
        [k,l] = regexp(thisLine, 'LName:\t');
        [m,n] = regexp(thisLine, 'RName:\t');
        [o,p]= regexp(thisLine, 'Rsp:\t');
        [q,r] = regexp(thisLine, 'Start:\t');
        [s,u] = regexp(thisLine, 'End:\t');
        [v,w] = regexp(thisLine, 'END');
        
        %itemFile = strtrim(itemFile);
        %cndFile = strtrim(cndFile);
         
        itmFile{tc} = itemFile;
        cndFile{tc} = condFile;
        dateAndTime{tc} = dateStr;
        date{tc} = dateStr(1:11);
        time{tc} = dateStr(12:end);
        magics{tc} = magicNumbers;
        
        trial(tc) = str2num(thisLine(b:c-1));
        block(tc) = str2num(thisLine(d:e-1));
        cond(tc) = str2num(thisLine(f:g-1));
        lVal(tc) = str2num(thisLine(h:i-1));
        rVal(tc) = str2num(thisLine(j:k-1));
        lName{tc} = thisLine(l:m-1);
        rName{tc} = thisLine(n:o-1);
        resp{tc} = thisLine(p+1:q-2);
        start(tc) = str2num(thisLine(r:s-1));
        stop(tc) = str2num(thisLine(u:v-1));
        
        
        if lVal(tc) < rVal(tc) && strcmp('Right', resp{tc})
            correct(tc) = 1;
        elseif lVal(tc) > rVal(tc) && strcmp('Right', resp{tc})
            correct(tc) = 0;
        elseif lVal(tc) < rVal(tc) && strcmp('Left', resp{tc})
            correct(tc) = 0;
        elseif lVal(tc) > rVal(tc) && strcmp('Left', resp{tc})
            correct(tc) = 1;
        else
            correct(tc) = -1;
        end
        
        
        
        tc = tc+1;
        
    catch err
       % pause
        fprintf('Error on line: %d of %s\n', t, NAME);
    end
    
    clear a b c d e f g h i j k l m n o p q r s u v w
end

end



