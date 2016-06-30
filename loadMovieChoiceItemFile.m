function [ itemNumber, item, associatedReward ] = loadMovieChoiceItemFile( itemFilePath )
%LOADMOVIECHOICEITEMFILE Summary of this function goes here
%   Detailed explanation goes here

    %itemFilePath = 'D:\dat\pl2\MittensINOTMovieChoiceNeurophys\Mittens_062916\movieChoice5_itm.txt';
    
    fID = fopen(itemFilePath,'r');

    headerText = textscan(fID,'%s\t%s\t%s\t%s', 1);
    bodyText = textscan(fID,'%s\t%s\t%s');
    
    fclose(fID);
    
    itemNumbers = bodyText{1};
    fileNames = bodyText{2};
    rewardValues = bodyText{3};
    
    for  i = 1:numel(fileNames)
        
        itemNumber(i) =str2num(itemNumbers{i});
        item{i} = fileNames{i}(2:end);
        associatedReward(i) = str2num(rewardValues{i}(2:end));
    end
end

