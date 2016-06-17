
clear all

cndFileName = 'movieChoice2_cnd.txt';

shuffleCnds = 1;



groupA = [1:6];
groupB = [7:12];
groupC = [13:18];

groupF = [19:24];
groupG = [25:30];
groupH = [31:36];


groups1 = {groupA groupB groupC };
groups2 = {groupF groupG groupH };


count = 0;

for i = 1:size(groups1,2)
    
    leftGroup = groups1{i};
    
    for j = 1:size(leftGroup,2)
        
        leftItem = leftGroup(j);

        otherGroups = groups1;
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

for i = 1:size(groups2,2)
    
    leftGroup = groups2{i};
    
    for j = 1:size(leftGroup,2)
        
        leftItem = leftGroup(j);

        otherGroups = groups2;
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