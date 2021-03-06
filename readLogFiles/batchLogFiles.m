clear all
clc

minTrials = 5;

logPath = [pwd, '\', 'logs'];
logDir = dir(logPath);

tc = 0;

for d = 1:size(logDir,1)
    
    findLogText = regexp(logDir(d).name, '_log');
    
    if ~logDir(d).isdir && ~isempty(findLogText)
        logFilePath = fullfile(logPath, logDir(d).name);
        try
            [ this_itmFile, this_cndFile, this_dateAndTime, this_trial, this_block, this_lVal, this_rVal, this_resp, this_start, this_stop, this_correct, this_date, this_time] = readLogFile( logFilePath );
            if size(this_trial,2) > minTrials
                try
                    for i = 1 : size(this_trial,2)
                        
                        tc = tc+1;
                        itemFile{tc} = this_itmFile{i};
                        cndFile{tc} = this_cndFile{i};
                        date{tc} = this_date{i};
                        time{tc} = this_time{i};
                        leftVal(tc) = this_lVal(i);
                        rightVal(tc) = this_rVal(i);
                        resp{tc} = this_resp{i};
                        correct(tc) = this_correct(i);
                        
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
        clear this_itmFile this_cndFile this_dateAndTime this_trial this_block this_lVal this_rVal this_resp this_start this_stop this_correct this_date this_time
    end
    
end

save('parsedLogData.mat');
