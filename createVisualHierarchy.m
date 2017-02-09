close all;
codeWordsFile = 'h5/CodeWords_old.h5';
metaData;

hier = 'Visual';
codeWords = h5read(codeWordsFile, '/data');
% CGObj = clustergram(codeWords', 'RowLabels', cifar100Fine);

codeWordsCoarse = zeros(length(unique(cifar100CoarseIdx)), size(codeWords, 1));
for i = 1:length(unique(cifar100CoarseIdx))
    sample = find(cifar100CoarseIdx == i);
    codeWordsCoarse(i,:) = mean(codeWords(:, sample),2)';
end
codeWordsCoarse = codeWordsCoarse';

dists = pdist(codeWordsCoarse');
heir = linkage(dists, 'average');
%PATCH
heir(end-1:end, 1:2) = [18 37
    34 38];
                  
% clustergram(codeWordsCoarse');
% find(heir(:,1) == 28 .* )
figure;
for j = 1:length(superClassesTypes)
    shortNames{j} = superClassesTypes{j}(1:min(8,end));
end
dendrogram(heir,size(codeWordsCoarse,2), 'Labels', shortNames)

treeVecs = cell(1,size(codeWordsCoarse,2));
for i = 1:size(codeWordsCoarse,2)
    clust = i;
    treeVecs{i} = []; 
    while ~isempty(clust)
        [clust,dir] = find(heir == clust);
        clust = clust + size(codeWordsCoarse,2);
        treeVecs{i} = [dir, treeVecs{i}];
    end
end

depths = cellfun(@(x) length(x), treeVecs);
treeDepth = max(depths);
treeVecMat = zeros(size(codeWordsCoarse,2), treeDepth);
for i = 1:size(codeWordsCoarse,2)
    treeVecMat(i,1:depths(i)) = treeVecs{i};
end
treeVecMat(treeVecMat == 2) = -1;

treeVecMatCoarse = treeVecMat;
treeVecMat = zeros(size(codeWords,2), size(treeVecMat,2));
for i = 1:size(treeVecMat, 1)
    treeVecMat(i,:) = treeVecMatCoarse(cifar100CoarseIdx(i), :);
end

for i = 1:length(superClasses)
   superClasses{i}{end} = treeVecMatCoarse(i, :); 
end

neighboursNum = 100;
for i = 1:length(superClasses)
    neighbours = {};
    neighboursIdx = [];
    exploredGroups = [];
    neighboursChoosen = 0;
    while neighboursChoosen < neighboursNum
        k = chooseClosestGroupIdx(i, exploredGroups, superClasses);
        exploredGroups = [exploredGroups, k];
        for j = 2:length(superClasses{k})-1
            neighbours = [neighbours, {superClasses{k}{j}}];
            neighboursIdx = [neighboursIdx, find(strcmp(cifar100Fine, superClasses{k}{j}))];
            neighboursChoosen = neighboursChoosen + 1;
        end
    end
    
    neighboursVec{i} = neighbours;
    neighboursIdxVec{i} = neighboursIdx;
end

neighboursMat = zeros(length(cifar100Fine), neighboursNum);
for i = 1:length(cifar100Fine)
    superIdx = -1;
    for j = 1:length(superClasses)
       if sum(strcmp(superClasses{j}, cifar100Fine{i})) 
          superIdx =  j;
          break;
       end
    end
    
    neighboursMat(i,:) = neighboursIdxVec{j};
end

if ~exist('neighboursMatVis.h5', 'file')
%     f = H5F.create('neighboursMat.h5');
    h5create('neighboursMatVis.h5', '/data', size(neighboursMat))
    h5write('neighboursMatVis.h5', '/data', neighboursMat);
%     fclose(f);
end

if ~exist('treeVecMatVis.h5', 'file')
%     f = H5F.create('treeVecMat.h5');
    h5create('./treeVecMatVis.h5', '/data', size(treeVecMat))
    h5write('treeVecMatVis.h5', '/data', treeVecMat);
%     fclose(f);
end