close all;
clc;
addpath(genpath('./tSNE_matlab'));
hiers = {'Hand', 'Visual', 'Imgnt', 'Rand'};
numHiers = length(hiers);
for hierNum = 1%:numHiers
    % prepare data
    hier = hiers{hierNum};
    rng(1);    
    codeWordsFile = ['../serverFolder\testResults\results_Wed_Feb__8_04_07_21_IST_2017_run_for_4_hierarchies_for_20_epochs\results\objects\', hier, '\CodeWords.h5'];
    metaData;
    classTypes = superClassesTypes(randperm(length(superClassesTypes)));
    codeWords = h5read(codeWordsFile, '/data')';
    markers = {'o', '*', '.', 'x', '+'};
    
    % plot main tnse
    figure(1);
    figTitle = hier;
    colors = cifar100CoarseColors(cifar100CoarseIdx, :);
    printLegend = 1;
    plotScatterMethod(codeWords, cifar100CoarseIdx, superClassesTypes, classTypes, colors, markers, figTitle, printLegend)
    
    % plot splited tsne subplots from 2 to maxDepth splits
    clusterIdxs = kmeans(codeWords, 2);
    figTitleOrig = hier;
    depth = 2;
    maxDepth = 5;
    plotBaseNum = 0;
    exploreScattersRecurs(codeWords, cifar100CoarseIdx, clusterIdxs, cifar100CoarseColors, superClassesTypes, classTypes, markers, hier, hierNum, figTitleOrig, depth, maxDepth, plotBaseNum)
end