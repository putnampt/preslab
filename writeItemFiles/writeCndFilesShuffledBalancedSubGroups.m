
clear all

cndFileName = 'movieChoice4_cnd.txt';

groupA = [1:6];
groupB = [7:12];
groupC = [13:18];

groupX = [19:24];
groupY = [25:30];
groupZ = [31:36];


groups1 = {groupA groupB groupC };
groups2 = {groupX groupY groupZ };

group1Names = {'A', 'B', 'C'};
group2Names = {'X', 'Y', 'Z'};

count = 0;

for i = 1:size(groups1,2)
    
    leftGroup = groups1{i};
    leftGroupName = group1Names{i};
    
    for j = 1:size(leftGroup,2)
        
        leftItem = leftGroup(j);

        otherGroups = groups1;
        otherGroups{1,i} = [];
        otherGroups(~cellfun('isempty',otherGroups));
        
        otherGroupNames = group1Names;
        otherGroupNames{1,i} = [];
        otherGroupNames(~cellfun('isempty',otherGroupNames));
         
        for k = 1:size(otherGroups,2)
            
            rightGroup = otherGroups{k};
            rightGroupName = otherGroupNames{k};
            
             for l = 1:size(rightGroup,2)
                 
                 rightItem = rightGroup(l);
                 count = count+1;
                 
                 leftCnds(count) = leftItem;
                 
                 rightCnds(count) = rightItem;
                 
                 pairing{count} = [ leftGroupName, ' ', rightGroupName ];
                 
                 

             end         
        end 
    end
end



for i = 1:size(groups2,2)
    
    leftGroup = groups2{i};
    leftGroupName = group2Names{i};
    
    for j = 1:size(leftGroup,2)
        
        leftItem = leftGroup(j);

        otherGroups = groups2;
        otherGroups{1,i} = [];
        otherGroups(~cellfun('isempty',otherGroups));
        
        otherGroupNames = group2Names;
        otherGroupNames{1,i} = [];
        otherGroupNames(~cellfun('isempty',otherGroupNames));
         
        for k = 1:size(otherGroups,2)
            
            rightGroup = otherGroups{k};
            rightGroupName = otherGroupNames{k};
            
             for l = 1:size(rightGroup,2)
                 rightItem = rightGroup(l);
                 count = count+1;
                 
                 leftCnds(count) = leftItem;
                 
                 rightCnds(count) = rightItem;
                 
                 pairing{count} = [ leftGroupName, ' ', rightGroupName ];
                 
             end         
        end 
    end
end


uniquePairings = unique(pairing);

for p = 1 : size(uniquePairings,2)
    
    pairingIdxs{p} = find(not(cellfun('isempty', strfind(pairing, uniquePairings{p}))));
    
end


used = 0;

pairingLengths = mean(cellfun('length',pairingIdxs)); % if this fails, it's on purpose b/c something went wrong earlier famfam

if std(cellfun('length',pairingIdxs)) ~= 0
   error('Error! (number of pairings is not equal across pairing types)'); 
end

remainingPairingIdxs = pairingIdxs;

for p = 1 : pairingLengths
    
    pairingOrder = randperm(size(uniquePairings,2));
    
    for o = pairingOrder
        
        thisPairingElements = remainingPairingIdxs{o};
        
        selectedPairingElementIdx =randi(length(thisPairingElements));
        
        selectedPairingElement = thisPairingElements(selectedPairingElementIdx);
        
        remainingPairingIdxs{o}(selectedPairingElementIdx) = [];
        
        used = used+1;
        
        cndOrder(used) = selectedPairingElement;
        
    end
    
end

if count ~= used
   error('Error shuffling conditions! (total count does not equal number of elements used)'); 
end

% if shuffleCnds
%     cndOrder = randperm(count);
% else
%     cndOrder = 1:count;
% end

if exist(cndFileName, 'file')
    delete(cndFileName)
end

fileID = fopen(cndFileName,'at');

fprintf(fileID,'cnd#\t|left\t|right\t|test1\t|test2\t\ttotalconditions=%03d', count);

for x = 1:count
    fprintf(fileID,'\n%03d\t|%03d\t|%03d\t|\t|', x, leftCnds(cndOrder(x)), rightCnds(cndOrder(x)));
end

fclose(fileID);