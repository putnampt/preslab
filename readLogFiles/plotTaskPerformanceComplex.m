clear all
clc
load('parsedMovieLogData.mat');

uniqueItems = unique(itemFile);

desiredItemFile = uniqueItems{1};
itemFile(end) = [];
thisItm_Idx = find(not(cellfun('isempty',  strfind(itemFile, desiredItemFile))));

plotOnlyCertainValues = 0;
valuePair2Plot = [0 8];

thisItm_itemFile = itemFile(thisItm_Idx);
thisItm_cndFile = cndFile(thisItm_Idx);
thisItm_date = date(thisItm_Idx);
thisItm_time = time(thisItm_Idx);
thisItm_leftVal = leftVal(thisItm_Idx);
thisItm_rightVal = rightVal(thisItm_Idx);
thisItm_resp = resp(thisItm_Idx);
thisItm_correct = correct(thisItm_Idx);
thisItm_netJuice = netJuice(thisItm_Idx);

plotNetJuiceTest = true;

if plotOnlyCertainValues
   
    theseValuesIdx = intersect(union(find(thisItm_leftVal == valuePair2Plot(1)), find(thisItm_leftVal == valuePair2Plot(2))), union(find(thisItm_rightVal == valuePair2Plot(1)), find(thisItm_rightVal == valuePair2Plot(2))));
    
    thisItm_itemFile = thisItm_itemFile(theseValuesIdx);
    thisItm_cndFile = thisItm_cndFile(theseValuesIdx);
    thisItm_date = thisItm_date(theseValuesIdx);
    thisItm_time = thisItm_time(theseValuesIdx);
    thisItm_leftVal = thisItm_leftVal(theseValuesIdx);
    thisItm_rightVal = thisItm_rightVal(theseValuesIdx);
    thisItm_resp = thisItm_resp(theseValuesIdx);
    thisItm_correct = thisItm_correct(theseValuesIdx);
    thisItm_netJuice = thisItm_netJuice(theseValuesIdx);
    
end

thisItm_uniqueDays = unique(thisItm_date);

plotColors = lines(size(thisItm_uniqueDays,2));

xIdx = 0;

figure(1), hold on;


for d = 1:size(thisItm_uniqueDays,2)
    
    fprintf('%3d\tDate: %s', d, thisItm_date{1});
   
    thisDay_Idx = find(not(cellfun('isempty',  strfind(thisItm_date, thisItm_uniqueDays{d}))));
    
     thisDay_itemFile = thisItm_itemFile(thisDay_Idx);
     thisDay_cndFile = thisItm_cndFile(thisDay_Idx);
     thisDay_date = thisItm_date(thisDay_Idx);
     thisDay_time = thisItm_time(thisDay_Idx);
     thisDay_leftVal = thisItm_leftVal(thisDay_Idx);
     thisDay_rightVal = thisItm_rightVal(thisDay_Idx);
     thisDay_resp = thisItm_resp(thisDay_Idx);
     thisDay_correct = thisItm_correct(thisDay_Idx);
     thisDay_netJuice = thisItm_netJuice(thisDay_Idx);
     
     thisDay_uniqueBlocks = unique(thisDay_time);
     
     fprintf('\n');
     
     for b = 1:size(thisDay_uniqueBlocks,2)
          fprintf('\t%d Block', b);
         
         
         
         %fsdf?????????????
         thisBlock_Idx = find(not(cellfun('isempty',  strfind(thisDay_time, thisDay_uniqueBlocks{b}))));
         
         thisBlock_itemFile = thisItm_itemFile(thisBlock_Idx);
         thisBlock_cndFile = thisItm_cndFile(thisBlock_Idx);
         thisBlock_date = thisItm_date(thisBlock_Idx);
         thisBlock_time = thisItm_time(thisBlock_Idx);
         thisBlock_leftVal = thisItm_leftVal(thisBlock_Idx);
         thisBlock_rightVal = thisItm_rightVal(thisBlock_Idx);
         thisBlock_resp = thisItm_resp(thisBlock_Idx);
         thisBlock_correct = thisItm_correct(thisBlock_Idx);
         thisBlock_netJuice = thisItm_netJuice(thisBlock_Idx);
         xIdx = xIdx+1;
         
         thisDayPerformanceY(b) = mean(thisBlock_correct);
         thisDayPerformanceX(b) = xIdx;
         thisDayNetJuice{b} = thisBlock_netJuice;
         
         fprintf('\n');
     end
     
     plot(thisDayPerformanceX, thisDayPerformanceY, 'color', plotColors(d, :));
     
     if plotNetJuiceTest == true
        
         for b = 1:size(thisDay_uniqueBlocks,2) 
             [hPos(b),pVals(b)] = ttest(thisDayNetJuice{b});
         end
         
         figure(2)
         clf
         hold on
        %plotyy(thisDayPerformanceX, thisDayPerformanceY, thisDayPerformanceX, pVals); 
        plotPvals = 1 - pVals;
        
        
        
        
        plot(thisDayPerformanceX, plotPvals);
         criticalVal = 0.05 / size(thisDay_uniqueBlocks,2);
         
        sigBlocks =  find( pVals <= criticalVal);
        
        scatter(sigBlocks, (ones(1, numel(sigBlocks))), 'g*');
         
        % hline(criticalVal);
        % pause
         
         figure(1)
     end
         
         
     

    clear thisDayPerformanceY thisDayPerformanceX pVals hPos
end

hline(.5);
ylim([0 1])
ylabel('Percent correct choices');