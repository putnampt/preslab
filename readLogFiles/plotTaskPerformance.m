clear all
clc
load('parsedMovieLogData.mat');

uniqueItems = unique(itemFile);

[s,v] = listdlg('PromptString','Select a item file:',...
    'SelectionMode','single',...
    'ListString',uniqueItems);

if v
    desiredItemFile = uniqueItems{s};
else
    return
end
%itemFile(end) = []; %why did i put this here?
thisItemIdx = find(not(cellfun('isempty',  strfind(itemFile, desiredItemFile))));

completedTrialsIdx = union( find(not(cellfun('isempty',  strfind(resp, 'Right')))),  find(not(cellfun('isempty',  strfind(resp, 'Left')))));

selectionIdx = intersect(thisItemIdx, completedTrialsIdx);


plotOnlyCertainValues = 1;
valuePair2Plot = [3 8];

thisItm_itemFile = itemFile(selectionIdx);
thisItm_cndFile = cndFile(selectionIdx);
thisItm_date = date(selectionIdx);
thisItm_time = time(selectionIdx);
thisItm_leftVal = leftVal(selectionIdx);
thisItm_rightVal = rightVal(selectionIdx);
thisItm_resp = resp(selectionIdx);
thisItm_correct = correct(selectionIdx);
thisItm_netJuice = netJuice(selectionIdx);

%plotNetJuiceTest = true;

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

continousNetJuice = [];
tc = 0;

xIdx = 0;

figure(1), hold on;
subplot(3,3,1:3);

for d = 1:size(thisItm_uniqueDays,2)
    subplot(3,3,1:3);
    hold on
    ylim([0 1])
    ylabel('Percent correct choices');
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
        thisDayNetJuiceBlockMeans(b) = mean(thisBlock_netJuice);
        
        [hPos(b),pVals(b)] = ttest(thisDayNetJuice{b});
        blockMeanNetJuice(b) = mean(thisDayNetJuice{b});
        
        
        for t =  1 : size(thisBlock_netJuice,2)
            tc = tc +1;
            continousNetJuice(tc) = thisBlock_netJuice(t);
        end
        
        fprintf('\n');
    end
    
    plot(thisDayPerformanceX, thisDayPerformanceY, 'color', plotColors(d, :));
    
    b1 = thisDayPerformanceX'\thisDayPerformanceY';
    X = [ones(length(thisDayPerformanceX'),1) thisDayPerformanceX'];
    b = X\thisDayPerformanceY';
    yCalc2 = X*b;
    yCalc1 = b1*thisDayPerformanceX;
    hold on;
    plot(thisDayPerformanceX,yCalc2,'--')
    
    
    subplot(3,3,4:6);
    %yyaxis left
    hold on
    plotPvals = 1 - pVals;
    
    plot(thisDayPerformanceX, plotPvals, 'color', plotColors(d, :));
    
    criticalVal = 0.05 / size(thisDay_uniqueBlocks,2);
    
    sigBlocks =  thisDayPerformanceX(find( pVals <= criticalVal));
    
    scatter(sigBlocks, (ones(1, numel(sigBlocks))), 'g*');
    
    ylim([0 1])
    ylabel('Explained Variance');
    
    
    subplot(3,3,7:9);
    hold on
    plot(thisDayPerformanceX, blockMeanNetJuice, 'color', plotColors(d, :));
    njb1 = thisDayPerformanceX'\blockMeanNetJuice';
    njX = [ones(length(thisDayPerformanceX'),1) thisDayPerformanceX'];
    njb = njX\blockMeanNetJuice';
    njyCalc2 = njX*njb;
    njyCalc1 = njb1*thisDayPerformanceX;
    hold on;
    plot(thisDayPerformanceX,njyCalc2,'--')
    ylabel('Mean Net Juice');
    
    
    clear thisDayPerformanceY thisDayPerformanceX pVals hPos blockMeanNetJuice
end

subplot(3,3,1:3);
hline(.5);
subplot(3,3,7:9);
hline(0);
