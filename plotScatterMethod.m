function plotScatterMethod(codeWords, cifar100CoarseIdx, superClassesTypes, classTypes, colors, markers, figTitle, printLegend)
if nargin < 8
    printLegend = 0;
end

codeWordsTsne = [];
colorsTsne = [];
for i = 1:length(classTypes)
    typeIdxs(i) = find(cellfun(@(x) strcmp(x, classTypes{i}), superClassesTypes));
    codeWordsTsne = [codeWordsTsne; codeWords(cifar100CoarseIdx == typeIdxs(i), :)];
    idxLow = size(colorsTsne, 1) + 1;
    colorsTsne = [colorsTsne; colors(cifar100CoarseIdx == typeIdxs(i), :)];
    idxHigh = size(colorsTsne, 1);
    idxs{i} = idxLow:idxHigh;
end
pcaSize = min(size(codeWordsTsne,1), 5);
evalc('codeWordsTsne = tsne(codeWordsTsne, [], 2, pcaSize)');

for i = 1:length(classTypes)
    scatter(codeWordsTsne(idxs{i},1), codeWordsTsne(idxs{i},2), [], colorsTsne(idxs{i}, :), markers{mod(i,5)+1});
    set(gca, 'XTickLabel', '', 'YTickLabel', '');
    hold on;
end
hold off;
if printLegend
    legend(superClassesTypes(typeIdxs), 'Location', 'eastoutside');
end
title(figTitle);
% print([figTitle, '.png'], '-dpng');
end
