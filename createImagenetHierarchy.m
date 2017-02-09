codeWordsFile = 'CodeWords_old.h5';
metaData;

superClasses = ...
{{'aquatic mammals', 'beaver', 'dolphin', 'otter', 'seal', 'whale', [1 -1 -1 -1 1 -1 1]}, ...
{'fish', 'aquarium_fish', 'flatfish', 'ray', 'shark', 'trout' [1 -1 -1 -1 -1]}, ...
{'flowers', 'orchids', 'poppies', 'roses', 'sunflowers', 'tulips' [1 1 -1 -1]}, ...
{'food containers', 'bottles', 'bowls', 'cans', 'cups', 'plates' [-1 1 -1 -1 -1]}, ...
{'fruit and vegetables', 'apples', 'mushrooms', 'oranges', 'pears', 'sweet_peppers' [1 1 1]}, ...
{'household electrical devices', 'clock', 'keyboard', 'lamp', 'telephone', 'television' [-1 1 1 -1]}, ...
{'household furniture', 'bed', 'chair', 'couch', 'table', 'wardrobe' [-1 1 -1 -1 1]}, ...
{'insects', 'bee', 'beetle', 'butterfly', 'caterpillar', 'cockroach' [1 -1 1 -1]}, ...
{'large carnivores', 'bear', 'leopard', 'lion', 'tiger', 'wolf' [1 -1 -1 1 -1]}, ...
{'large man-made outdoor things', 'bridge', 'castle', 'house', 'road', 'skyscraper' [-1 1 1 1]}, ...
{'large natural outdoor scenes', 'cloud', 'forest', 'mountain', 'plain', 'sea' [-1 -1 1]}, ...
{'large omnivores and herbivores', 'camel', 'cattle', 'chimpanzee', 'elephant', 'kangaroo' [1 -1 -1 1 1]}, ...
{'medium-sized mammals', 'fox', 'porcupine', 'possum', 'raccoon', 'skunk' [1 -1 -1 -1 1 -1 -1 1]}, ...
{'non-insect invertebrates', 'crab', 'lobster', 'snail', 'spider', 'worm' [1 -1 1 1]}, ...
{'people', 'baby', 'boy', 'girl', 'man', 'woman' [-1 -1 -1]}, ...
{'reptiles', 'crocodile', 'dinosaur', 'lizard', 'snake', 'turtle' [1 -1 -1 -1 1 1]}, ...
{'small mammals', 'hamster', 'mouse', 'rabbit', 'shrew', 'squirrel' [1 -1 -1 -1 1 -1 -1 -1]}, ...
{'trees', 'maple_tree', 'oak_tree', 'palm_tree', 'pine_tree', 'willow_tree' [1 1 -1 1]}, ...
{'vehicles 1', 'bicycle', 'bus', 'motorcycle', 'pickup_truck', 'train' [-1 1 -1 -1]}, ...
{'vehicles 2', 'lawn_mower', 'rocket', 'streetcar', 'tank', 'tractor' [-1 1 -1 1]}};

maxVecLen = 0;
for i = 1:length(superClasses)
    maxVecLen = max(length(superClasses{i}{end}), maxVecLen); 
end

for i = 1:length(superClasses)
    tmpVec = superClasses{i}{end};
    tmpVec = [tmpVec, zeros(1, maxVecLen - length(tmpVec))];
    superClasses{i}{end} = tmpVec;
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
treeVecMat = zeros(length(cifar100Fine), maxVecLen);
for i = 1:length(cifar100Fine)
    superIdx = -1;
    for j = 1:length(superClasses)
       if sum(strcmp(superClasses{j}, cifar100Fine{i})) 
          superIdx =  j;
          break;
       end
    end
    
    neighboursMat(i,:) = neighboursIdxVec{j};
    treeVecMat(i,:) = superClasses{j}{end};
end

if ~exist('neighboursMatImgnt.h5', 'file')
%     f = H5F.create('neighboursMat.h5');
    h5create('neighboursMatImgnt.h5', '/data', size(neighboursMat))
    h5write('neighboursMatImgnt.h5', '/data', neighboursMat);
%     fclose(f);
end

if ~exist('treeVecMatImgnt.h5', 'file')
%     f = H5F.create('treeVecMat.h5');
    h5create('./treeVecMatImgnt.h5', '/data', size(treeVecMat))
    h5write('treeVecMatImgnt.h5', '/data', treeVecMat);
%     fclose(f);
end