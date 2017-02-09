codeWordsFile = 'CodeWords_old.h5';
metaData;

codeWords = h5read(codeWordsFile, '/data');
% CGObj = clustergram(codeWords', 'RowLabels', cifar100Fine);

codeWordsCoarse = zeros(length(unique(cifar100CoarseIdx)), size(codeWords, 1));
for i = 1:length(unique(cifar100CoarseIdx))
    sample = find(cifar100CoarseIdx == i);
    codeWordsCoarse(i,:) = codeWords(:, sample(1))';
end
codeWordsCoarse = codeWordsCoarse';

treeDepth = 6;
treeVecMat = zeros(size(codeWordsCoarse,2), treeDepth);
for i = 1:size(codeWordsCoarse,2)
    codeWord = sign(rand(1,6)-0.5);
    zeroNum = min(geornd(0.5),treeDepth-1);
    if zeroNum > 0
        codeWord(end-zeroNum+1:end) = 0;
    end
    treeVecMat(i,:) = codeWord;
end

treeVecMatCoarse = treeVecMat;
treeVecMat = zeros(size(codeWords,2), size(treeVecMat,2));
for i = 1:size(treeVecMat, 1)
%     treeVecMat(i,:) = treeVecMatCoarse(cifar100CoarseIdx(i), :);
codeWord = sign(rand(1,6)-0.5);
    zeroNum = min(geornd(0.5),treeDepth-1);
    if zeroNum > 0
        codeWord(end-zeroNum+1:end) = 0;
    end
    treeVecMat(i,:) = codeWord;
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

if ~exist('neighboursMatRand.h5', 'file')
    %     f = H5F.create('neighboursMat.h5');
    h5create('neighboursMatRand.h5', '/data', size(neighboursMat))
    h5write('neighboursMatRand.h5', '/data', neighboursMat);
    %     fclose(f);
end

if ~exist('treeVecMatRand.h5', 'file')
    %     f = H5F.create('treeVecMat.h5');
    h5create('./treeVecMatRand.h5', '/data', size(treeVecMat))
    h5write('treeVecMatRand.h5', '/data', treeVecMat);
    %     fclose(f);
end