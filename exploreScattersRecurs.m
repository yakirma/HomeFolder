function exploreScattersRecurs(codeWordsOrig, cifar100CoarseIdxOrig, clusterIdxs, cifar100CoarseColors, superClassesTypes, classTypes, markers, hier, hierNum, figTitleOrig, depth, maxDepth, plotBaseNum)
for c = 1:2
    codeWords1 = codeWordsOrig(clusterIdxs == c, :);
    cifar100CoarseIdx1 = cifar100CoarseIdxOrig(clusterIdxs == c);
    
    codeWords = codeWords1;
    cifar100CoarseIdx = cifar100CoarseIdx1;
    
    figure((hierNum-1)*maxDepth + depth);
    figTitle = [figTitleOrig, '-', num2str(c)];
    colors = cifar100CoarseColors(cifar100CoarseIdx, :);
    numFigs = 2^(depth-1);
    plotNum = 2*plotBaseNum + c;
    if numFigs == 2
        subplot(1,2,plotNum);
    else
        plotsDim = ceil(sqrt(numFigs));
        subplot(plotsDim,plotsDim,plotNum);
    end
    
    plotScatterMethod(codeWords, cifar100CoarseIdx, superClassesTypes, classTypes, colors, markers, figTitle)
    
    if depth < maxDepth && size(codeWords1,1) >= 2
        clusterIdxs2 = kmeans(codeWords1, 2);
        plotBase2 = plotNum-1;
        exploreScattersRecurs(codeWords1, cifar100CoarseIdx1, clusterIdxs2, cifar100CoarseColors, superClassesTypes, classTypes, markers, hier, hierNum, figTitle, depth + 1, maxDepth, plotBase2);
    end
end
    


