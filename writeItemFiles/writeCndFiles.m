fileID = fopen('myfile3.txt','at');

% groupA = [1:10];
% groupB = [11:20];
% groupC = [21:30];
% groupD = [31:40];


groupA = [1:5];
groupB = [11:15];
groupC = [21:25];
groupD = [31:35];

groups = {groupA groupB groupC groupD};

% fid = fopen('simpleFirstFiveCompare_cnd.txt');
% 
% tline = fgets(fid);
% while ischar(tline)
%     disp(tline)
%     tline = fgets(fid);
%     
% end
% 
% fclose(fid);


fprintf(fileID,'cnd#\t|left\t|right\t|test1\t|test2\t\ttotalconditions=000\n')

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
                 fprintf(fileID,'\n%03d\t|%03d\t|%03d\t|\t|', count, leftItem, rightItem);
             end
            
        end
       
        
    end
    
    
   
    
    
    
end






fclose(fileID);