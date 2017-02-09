
cifar100Fine = {'apples', 'aquarium_fish', 'baby', 'bear', 'beaver', 'bed', 'bee', 'beetle', 'bicycle', 'bottles', 'bowls', 'boy', 'bridge', 'bus', 'butterfly', 'camel', 'cans', 'castle', 'caterpillar', 'cattle', 'chair', 'chimpanzee', 'clock', 'cloud', 'cockroach', 'couch', 'crab', 'crocodile', 'cups', 'dinosaur', 'dolphin', 'elephant', 'flatfish', 'forest', 'fox', 'girl', 'hamster', 'house', 'kangaroo', 'keyboard', 'lamp', 'lawn_mower', 'leopard', 'lion', 'lizard', 'lobster', 'man', 'maple_tree', 'motorcycle', 'mountain', 'mouse', 'mushrooms', 'oak_tree', 'oranges', 'orchids', 'otter', 'palm_tree', 'pears', 'pickup_truck', 'pine_tree', 'plain', 'plates', 'poppies', 'porcupine', 'possum', 'rabbit', 'raccoon', 'ray', 'road', 'rocket', 'roses', 'sea', 'seal', 'shark', 'shrew', 'skunk', 'skyscraper', 'snail', 'snake', 'spider', 'squirrel', 'streetcar', 'sunflowers', 'sweet_peppers', 'table', 'tank', 'telephone', 'television', 'tiger', 'tractor', 'train', 'trout', 'tulips', 'turtle', 'wardrobe', 'whale', 'willow_tree', 'wolf', 'woman', 'worm'};
superClasses = ...
{{'aquatic mammals', 'beaver', 'dolphin', 'otter', 'seal', 'whale', [1 -1 1 -1 -1]}, ...
{'fish', 'aquarium_fish', 'flatfish', 'ray', 'shark', 'trout' [1 -1 1 -1 1]}, ...
{'flowers', 'orchids', 'poppies', 'roses', 'sunflowers', 'tulips' [1 1 -1 -1]}, ...
{'food containers', 'bottles', 'bowls', 'cans', 'cups', 'plates' [-1 -1 1]}, ...
{'fruit and vegetables', 'apples', 'mushrooms', 'oranges', 'pears', 'sweet_peppers' [1 1 1]}, ...
{'household electrical devices', 'clock', 'keyboard', 'lamp', 'telephone', 'television' [-1 -1 -1 1]}, ...
{'household furniture', 'bed', 'chair', 'couch', 'table', 'wardrobe' [-1 -1 -1 -1]}, ...
{'insects', 'bee', 'beetle', 'butterfly', 'caterpillar', 'cockroach' [1 -1 1 1 -1 1]}, ...
{'large carnivores', 'bear', 'leopard', 'lion', 'tiger', 'wolf' [1 -1 -1 1 1]}, ...
{'large man-made outdoor things', 'bridge', 'castle', 'house', 'road', 'skyscraper' [-1 1 -1 -1]}, ...
{'large natural outdoor scenes', 'cloud', 'forest', 'mountain', 'plain', 'sea' [-1 1 -1 1]}, ...
{'large omnivores and herbivores', 'camel', 'cattle', 'chimpanzee', 'elephant', 'kangaroo' [1 -1 -1 1 -1]}, ...
{'medium-sized mammals', 'fox', 'porcupine', 'possum', 'raccoon', 'skunk' [1 -1 -1 -1 1 -1]}, ...
{'non-insect invertebrates', 'crab', 'lobster', 'snail', 'spider', 'worm' [1 -1 1 1 -1 -1]}, ...
{'people', 'baby', 'boy', 'girl', 'man', 'woman' [1 -1 -1 -1 1 1]}, ...
{'reptiles', 'crocodile', 'dinosaur', 'lizard', 'snake', 'turtle' [1 -1 1 1 1]}, ...
{'small mammals', 'hamster', 'mouse', 'rabbit', 'shrew', 'squirrel' [1 -1 -1 -1 -1]}, ...
{'trees', 'maple_tree', 'oak_tree', 'palm_tree', 'pine_tree', 'willow_tree' [1 1 -1 1]}, ...
{'vehicles 1', 'bicycle', 'bus', 'motorcycle', 'pickup_truck', 'train' [-1 1 1 1]}, ...
{'vehicles 2', 'lawn_mower', 'rocket', 'streetcar', 'tank', 'tractor' [-1 1 1 -1]}};

maxVecLen = 0;
for i = 1:length(superClasses)
    maxVecLen = max(length(superClasses{i}{end}), maxVecLen); 
end

for i = 1:length(superClasses)
    tmpVec = superClasses{i}{end};
    tmpVec = [tmpVec, zeros(1, maxVecLen - length(tmpVec))];
    superClasses{i}{end} = tmpVec;
end

cifar100Coarse = cifar100Fine;
cifar100CoarseIdx = zeros(1, length(cifar100Coarse));
cifar100CoarseColors = zeros(length(superClasses), 3);
for i =1:length(cifar100Fine)
    for j = 1:length(superClasses)
        if sum(cellfun(@(x) strcmp(x, cifar100Fine{i}), superClasses{j})) > 0
            cifar100Coarse(i) = superClasses{j}(1);
            cifar100CoarseIdx(i) = j;
            break;
        end
        cifar100CoarseColors(j, :) = rand(1,3);
    end
end

for i = 1:length(superClasses)
    superClassesTypes{i} =  superClasses{i}{1};
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

if ~exist('neighboursMat.h5', 'file')
%     f = H5F.create('neighboursMat.h5');
    h5create('neighboursMat.h5', '/data', size(neighboursMat))
    h5write('neighboursMat.h5', '/data', neighboursMat);
%     fclose(f);
end
if ~exist('treeVecMat.h5', 'file')
%     f = H5F.create('treeVecMat.h5');
    h5create('./treeVecMat.h5', '/data', size(treeVecMat))
    h5write('treeVecMat.h5', '/data', treeVecMat);
%     fclose(f);
end