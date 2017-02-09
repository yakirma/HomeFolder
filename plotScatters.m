global idx;
idx = 1;
for i =  idx
rng(1);
addpath(genpath('./tSNE_matlab'));

if i == 0
    codeWordsFile = 'CodeWords.h5';
    figTitle = 'test';
elseif i == 1
    codeWordsFile = '../serverFolder\testResults\results_Wed_Feb__8_04_07_21_IST_2017_run_for_4_hierarchies_for_20_epochs\results\objects\Hand\CodeWords.h5';
    figTitle = 'Handcrafted';
end
metaData;
codeWords = h5read(codeWordsFile, '/data');
% clustergram(codeWords', 'RowLabels', cifar100Fine)

visType = 'tsne';

switch visType
    case 'pca'
        [~, scores, latent] = pca(codeWords');
        codeWordsPca = scores(:, 1:2);
        
        numCalsses = 5;
        tmp = superClassesTypes(randperm(length(superClassesTypes)));
        types = tmp(numCalsses); %{'fish', 'flowers', 'trees'};
        for i = 1:length(types)
            idx = find(cellfun(@(x) strcmp(x, types{i}), superClassesTypes));
            colors = cifar100CoarseColors(cifar100CoarseIdx, :);
            scatter(codeWordsPca(cifar100CoarseIdx == idx,1), codeWordsPca(cifar100CoarseIdx == idx,2), [], colors(cifar100CoarseIdx == idx, :));
            hold on;
        end
        legend(superClassesTypes)
    case 'tsne'
        codeWords = codeWords';
        
        numCalsses = 20;
        tmp = superClassesTypes(randperm(length(superClassesTypes)));
        types = tmp(1:numCalsses);
        
        codeWordsTsne = [];
        colors = cifar100CoarseColors(cifar100CoarseIdx, :);
        colorsTsne = [];
        for i = 1:length(types)
            typeIdxs(i) = find(cellfun(@(x) strcmp(x, types{i}), superClassesTypes));
            codeWordsTsne = [codeWordsTsne; codeWords(cifar100CoarseIdx == typeIdxs(i), :)];
            idxLow = size(colorsTsne, 1) + 1;
            colorsTsne = [colorsTsne; colors(cifar100CoarseIdx == typeIdxs(i), :)];
            idxHigh = size(colorsTsne, 1);
            idxs{i} = idxLow:idxHigh;
        end
        
        markers = {'o', '*', '.', 'x', '+'};
        evalc('codeWordsTsne = tsne(codeWordsTsne, [], 2, 5)');
        figure;
        for i = 1:length(types)
            scatter(codeWordsTsne(idxs{i},1), codeWordsTsne(idxs{i},2), [], colorsTsne(idxs{i}, :), markers{mod(i,5)+1});
            set(gca, 'XTickLabel', '', 'YTickLabel', '');
            hold on;
        end
        hold off;
        legend(superClassesTypes(typeIdxs), 'Location', 'eastoutside');
        title(figTitle);
%         print([figTitle, '.png'], '-dpng');
    otherwise
        % do nothing
end

end





