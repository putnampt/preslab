
clear all

cndFileName = 'test_cnd.txt';

shuffleCnds = 1;



groupA = [1:4];
groupB = [5:12];
groupC = [13:16];
groupD = [17:20];
groupE = [21:24];
groupF = [25:26];
groupG = [27:20];

groups = {groupA groupB groupC groupD};



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