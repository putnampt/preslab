clear all
clc

allItemsDir = 'C:\Users\Bread\Desktop\movieChoice4';
allItemsDirStruct = dir(allItemsDir);
fileTypeExt = '.avi';
totalValidItems = 0;
validItemsLogical = zeros(1, size(allItemsDirStruct,1));
maxLength = 0;

for i = 1:size(allItemsDirStruct,1)
    
    [dirObjPathStr,dirObjName,dirObjExt] = fileparts(allItemsDirStruct(i).name);
    
    if strcmpi(dirObjExt, fileTypeExt)
        totalValidItems = totalValidItems +1;
        validItemsLogical(i) = 1;
    end
    
    if length(allItemsDirStruct(i).name) > maxLength
       maxLength =  length(allItemsDirStruct(i).name);
    end
end

maxLength = maxLength +2;

itmNumIdxStr = 'item#';
rwdIdxStr = '|reward';
totalItmsIdxStr = strcat('|totalitems=', num2str(totalValidItems));

movieNameIdxStr = '|moviename';
movieNameHeader = blanks(maxLength);
movieNameHeader(1:length(movieNameIdxStr)) = movieNameIdxStr;

itemNumberTemplate = blanks(length(itmNumIdxStr));
fileNameTemplate = blanks(maxLength);
rewardTemplate = blanks(length(rwdIdxStr));

fileNameTemplate(1) = '|';
rewardTemplate(1) = '|';


fID = fopen('movieChoice4.txt','at');

fprintf(fID,'%s\t%s\t%s\t%s\n',itmNumIdxStr, movieNameHeader, rwdIdxStr, totalItmsIdxStr);

lineWriteCount = 0;

for i = 1:size(allItemsDirStruct,1)
   
    if validItemsLogical(i)
        lineWriteCount = lineWriteCount+1;
        
        
        thisItemNumber = sprintf('%02d',lineWriteCount);
        thisItemNumberStr = itemNumberTemplate;
        thisItemNumberStr(1:length(thisItemNumber)) = thisItemNumber;
         
        thisFileName = allItemsDirStruct(i).name;
        thisFileNameStr = fileNameTemplate;
        thisFileNameStr(2:length(thisFileName)+1) = thisFileName;
        
        thisReward = sprintf('%02d',0);
        thisRewardStr = rewardTemplate;
        thisRewardStr(2:length(thisItemNumber)+1) = thisReward;
        
        fprintf(fID,'%s\t%s\t%s\n',thisItemNumberStr, thisFileNameStr, thisRewardStr);
        
        
        clear thisFileNameStr thisFileNameStr thisRewardStr thisItemNumber thisFileName thisReward
    end
    
end



fclose(fID);