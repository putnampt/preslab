%function [ itmFile, cndFile, dateAndTime, trial, block, lVal, rVal, resp, start, stop, correct, date, time] = readLogFile( logFilePath )
%READLOGFILE Summary of this function goes here
%   Detailed explanation goes here


clear all
clc

logFilePath ='D:\dev\preslab\readLogFiles\Logs\05-27-2016_12-24-00_log.txt';


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
%     try
        
        
        [a,b] = regexp(thisLine, 'Trl:\t');
        [c,d] = regexp(thisLine, 'Blk:\t');
        [e,f] = regexp(thisLine, 'Cnd:\t');
        [g,h] = regexp(thisLine, 'LVal:\t');
        [i,j] = regexp(thisLine, 'RVal:\t');
        [k,l] = regexp(thisLine, 'Rsp:\t');
        [m,n] = regexp(thisLine, 'Start:\t');
        [o,p] = regexp(thisLine, 'End:\t');
        [q,r] = regexp(thisLine, 'END');
         
        itmFile{tc} = itemFile;
        cndFile{tc} = condFile;
        dateAndTime{tc} = dateStr;
        date{tc} = dateStr(1:11);
        time{tc} = dateStr(12:end);
        trial(tc) = str2num(thisLine(b:c-1));
        block(tc) = str2num(thisLine(d:e-1));
        cond(tc) = str2num(thisLine(f:g-1));
        lVal(tc) = str2num(thisLine(h:i-1));
        rVal(tc) = str2num(thisLine(j:k-1));
        resp{tc} = thisLine(l+1:m-2);
        start(tc) = str2num(thisLine(n:o-1));
        stop(tc) = str2num(thisLine(p:q-1));
        
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
    
    clear a b c d e f g h i j k l m n o p q r
end


%end

