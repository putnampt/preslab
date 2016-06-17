
clear all

cndFileName = 'HumansAndMonkeys_cnd.txt';

shuffleCnds = 1;

% groupA = [1:10];
% groupB = [11:20];
% groupC = [21:30];
% groupD = [31:40];

groupA = [1:2];
groupB = [3:4];
groupC = [5:6];
groupD = [7:8];
groupE = [9:10];
groupF = [11:12];
groupG = [13:14];
groupH = [15:16];

% groupA = [1:3];
% groupB = [11:13];
% groupC = [21:23];
% groupD = [31:33];

groups = {groupA groupB groupC groupD groupE groupF groupG groupH};



count = 0;

for i = 1:size(groups,2)
    
    leftGroup = groups{i};
    
    for j = 1:size(leftGroup,2)
        
        leftItem = leftGroup(j);

        otherGroups = groups;
        otherGroups{1,i} = [];
        otherGroups(~cellfun('isempty',otherGroups));
         
        for k = 1:size(otherGroups,2)
            
            rightGroup = otherGroups{k};
            
             for l = 1:size(rightGroup,2)
                 rightItem = rightGroup(l);
                 count = count+1;
                 
                 leftCnds(count) = leftItem;
                 
                 rightCnds(count) = rightItem;

             end         
        end 
    end
end

if shuffleCnds
    cndOrder = randperm(count);
else
    cndOrder = 1:count;
end

if exist(cndFileName, 'file')
    delete(cndFileName)
end

fileID = fopen(cndFileName,'at');

fprintf(fileID,'cnd#\t|left\t|right\t|test1\t|test2\t\ttotalconditions=%03d', count);

for x = 1:count
    fprintf(fileID,'\n%03d\t|%03d\t|%03d\t|\t|', x, leftCnds(cndOrder(x)), rightCnds(cndOrder(x)));
end

fclose(fileID);