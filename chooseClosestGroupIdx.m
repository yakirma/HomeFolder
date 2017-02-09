function chosenGroup = chooseClosestGroupIdx(baseGroup, exploredGroups, superClasses)
if sum(exploredGroups == baseGroup) == 0
    chosenGroup = baseGroup;
else
    relevantGroups = setdiff(1:length(superClasses), exploredGroups);
    
    scores = zeros(1, length(superClasses));
    for i = relevantGroups
        equals = superClasses{i}{end} == superClasses{baseGroup}{end};
        initSeqlen = find(diff(equals));
        if isempty(initSeqlen)
            initSeqlen =length(equals);
        else
             initSeqlen = initSeqlen(1);
        end
        equals = equals(1:initSeqlen);
        scores(i) = sum(equals);
    end
    
    [~, chosenGroup] = max(scores);
end

