% clear -regexp .*

heirTypes = {'Handcrafted', 'Visual', 'ImageNet', 'Random'};
measureTypes = {'hierarchy train loss'
    'Accuracy'
    'acc5 test Had error'
    'mse test error'
    'Visual heirarchical Precision'
    'Imagenet heirarchical Precision'
    'Handcrafted heirarchical Precision'
    'neg samples percent'
    'Valid-Accuracy-'
    'Valid-Accuracy-top5'
    'Valid-Visual-heirarchical-Precision'
    'Valid-Imagenet-heirarchical-Precision'
    'Valid-Handcrafted-heirarchical-Precision'};

if ~exist('testResults')
    testResults = struct;
    for i = 1:length(heirTypes)
        file = fopen([heirTypes{i}, '.log']);
        
        testResults.(heirTypes{i}) = struct;
        line = fgetl(file);
        while ischar(line)
            %         disp(line);
            for j = 1:length(measureTypes)
                measureType = measureTypes{j};
                fieldType = strrep(strrep(measureType, ' ', '_'), '-', '_');
                splits = strsplit(line, [measureType, ' = ']);
                if size(splits,2) > 1
                    data = str2double(splits(end));
                    if ~isfield(testResults.(heirTypes{i}), fieldType)
                        testResults.(heirTypes{i}).(fieldType) = [];
                    end
                    testResults.(heirTypes{i}).(fieldType)(end+1) = data;
                    break;
                end
            end
            line = fgetl(file);
        end
    end
end

%% claculate baseline stats 
baseMeasures.HandPrecision = 0.47764333333389;
baseMeasures.VisPrecision = 0.48416333333398;
baseMeasures.ImgPrecision = 0.4781033333339;

baseMeasures.accuracy = 1 - 0.2854;

HandAv = 2 * (baseMeasures.HandPrecision * baseMeasures.accuracy) / (baseMeasures.HandPrecision + baseMeasures.accuracy);
VisAv = 2 * (baseMeasures.VisPrecision * baseMeasures.accuracy) / (baseMeasures.VisPrecision + baseMeasures.accuracy);
ImgAv = 2 * (baseMeasures.ImgPrecision * baseMeasures.accuracy) / (baseMeasures.ImgPrecision + baseMeasures.accuracy);

baseStatVec = 100 * [HandAv, baseMeasures.HandPrecision, baseMeasures.accuracy, ...
    VisAv, baseMeasures.VisPrecision, baseMeasures.accuracy, ...
    ImgAv, baseMeasures.ImgPrecision, baseMeasures.accuracy]

baseMeasures.Handcrafted_heirarchical_Precision = baseMeasures.HandPrecision;
baseMeasures.Visual_heirarchical_Precision = baseMeasures.VisPrecision;
baseMeasures.Imagenet_heirarchical_Precision = baseMeasures.ImgPrecision;
baseMeasures.Accuracy = baseMeasures.accuracy;
%% get measures
roundNum = @(num, D) round(num .* 10^D) ./ 10^D;
plotPhases = {'Valid', 'Test'};
for i = 1:length(heirTypes)
    for plotPhase = plotPhases
        if strcmp(plotPhase, 'Test')
            measuresToPlot = {measureTypes{[2,5,6,7]}};
        elseif strcmp(plotPhase, 'Valid')
            measuresToPlot = {measureTypes{[9,11,12,13]}};
        end
        
        maxLen = inf;
        for k = 1:length(heirTypes)
            maxLen = min(length(testResults.(heirTypes{k}).(strrep(strrep(measuresToPlot{1}, ' ', '_'), '-', '_'))), maxLen);
        end
        
        accuracy =  1 - testResults.(heirTypes{i}).(strrep(strrep(measuresToPlot{1}, ' ', '_'), '-', '_'))(1:maxLen);
        if strcmp(plotPhase, 'Valid')
                [~, maxIdx] = max(accuracy);
                heirMaxs.(heirTypes{i}) = maxIdx;
        end
        for j = 2:length(measuresToPlot)
            measureName =  measuresToPlot{j};
            measure =  testResults.(heirTypes{i}).(strrep(strrep(measuresToPlot{j}, ' ', '_'), '-', '_'))(1:maxLen);
            
%             harmonicMeasure = 2 * (measure .* accuracy) ./ (measure + accuracy);
%             maxIdx = maxLen;
            
            fieldType = strrep(strrep(measuresToPlot{j}, ' ', '_'), '-', '_');
            
                
            if strcmp(plotPhase, 'Test')
                measures.(fieldType){i} = [roundNum(100*measure(maxIdx), 2), roundNum(100*accuracy(maxIdx), 2)];
            end
            
        end
    end
end
measuresNames = fieldnames(measures);
VisualPrecision = measures.(measuresNames{1})';
ImagnetPrecision = measures.(measuresNames{2})';
HandCraftedPrecision = measures.(measuresNames{3})';

measuresTable = table(HandCraftedPrecision , ...
    VisualPrecision , ...
    ImagnetPrecision , ...
    'RowNames', heirTypes);

writetable(measuresTable, 'measureTable.csv');

%% plot graphs
doPlotGraphs = 1;
plotPhases = {'Test'}; % 'Valid'};
for plotPhase = plotPhases
    if doPlotGraphs
        figure;
        if strcmp(plotPhase, 'Test')
            measuresToPlot = {measureTypes{[2,5,6,7]}};
        elseif strcmp(plotPhase, 'Valid')
            measuresToPlot = {measureTypes{[9,11,12,13]}};
        end
        shapes = {'-', '--', '--*', '--o', '--^'};
        maxLen = inf;
        for i = 1:length(heirTypes)
            maxLen = min(length(testResults.(heirTypes{i}).(strrep(strrep(measuresToPlot{1}, ' ', '_'), '-', '_'))), maxLen);
        end
        for j = 1:length(measuresToPlot)
            subplot(2,2,j);
            maxIdxs = [];
            maxVals = [];
            for i = 1:length(heirTypes)
                %         subplot(2,2,i);
                
                %         errorField = strrep(measureTypes{2}, ' ', '_');
                %         plot((1-testResults.(heirTypes{i}).(errorField)));
                %         hold on;
                %     for j = 1:length(measuresToPlot)
                fieldType = strrep(strrep(measuresToPlot{j}, ' ', '_'), '-', '_');
                
                if strcmp(fieldType, 'Accuracy') || strcmp(fieldType, 'Valid_Accuracy_')
                    plot(1 - testResults.(heirTypes{i}).(fieldType)(2:maxLen), shapes{i});
                else
                    plot(testResults.(heirTypes{i}).(fieldType)(2:maxLen), shapes{i});% .* ...
                    %             (1-testResults.(heirTypes{i}).(errorField)));
                end
                
                maxIdxs = [maxIdxs, heirMaxs.(heirTypes{i})];
                if ~strcmp(fieldType, 'Accuracy')
                    maxVals = [maxVals, testResults.(heirTypes{i}).(fieldType)(maxIdxs(end))];
                else
                    maxVals = [maxVals, 1 - testResults.(heirTypes{i}).(fieldType)(maxIdxs(end))];
                end
                
                hold on;
            end
            
            plot(1:maxLen-1, baseMeasures.(fieldType) * ones(1 ,maxLen-1), '--g');
            
            if ~strcmp(fieldType, 'Accuracy')
                [~, best] = max(maxVals);
                plot(maxIdxs(best), maxVals(best), 'r^')
            else
               for k = 1:length(maxIdxs)
                   plot(maxIdxs(k), maxVals(k), 'r^')
               end
            end
            
            
            legend({heirTypes{:}, 'Baseline'}, 'Location', 'southwest');
            grid on;
            %     if j == 1
            %         legend({'accuracy', measuresToPlot{:}}, 'Location', 'best');
            %     end
            hold off;
            %     title(heirTypes{i});
            
            if strcmp(measuresToPlot{j}, 'Accuracy') || strcmp(fieldType, 'Valid_Accuracy_')
                title('Flat Precision');
            else
                title(measuresToPlot{j})
            end
        end
        
        %     print(['test_results', '.png'], '-dpng');
    end
end
%% plot graphs
doPlotTrainLoss = 0;
if doPlotTrainLoss
    measuresToPlot = {measureTypes{[1]}};
    shapes = {'-', '--', '--*', '--o', '--^'};
    maxLen = inf;
    for i = 1:length(heirTypes)
        maxLen = min(length(testResults.(heirTypes{i}).(strrep(strrep(measuresToPlot{1}, ' ', '_'), '-', '_'))), maxLen);
    end
    for j = 1:length(measuresToPlot)
%         subplot(2,2,j);
        for i = 1:length(heirTypes)
            %         subplot(2,2,i);
            
            %         errorField = strrep(measureTypes{2}, ' ', '_');
            %         plot((1-testResults.(heirTypes{i}).(errorField)));
            %         hold on;
            %     for j = 1:length(measuresToPlot)
            fieldType = strrep(strrep(measuresToPlot{j}, ' ', '_'), '-', '_')
            
            if strcmp(fieldType, 'Accuracy')  || strcmp(fieldType, 'Valid_Accuracy_')
                plot(1 - testResults.(heirTypes{i}).(fieldType)(2:maxLen), shapes{i});
            else
                plot(testResults.(heirTypes{i}).(fieldType)(2:maxLen), shapes{i});% .* ...
                %             (1-testResults.(heirTypes{i}).(errorField)));
            end
            hold on;
        end
        
        legend(heirTypes, 'Location', 'best');
        grid on;
        %     if j == 1
        %         legend({'accuracy', measuresToPlot{:}}, 'Location', 'best');
        %     end
        hold off;
        %     title(heirTypes{i});
        title(measuresToPlot{j})
    end
end