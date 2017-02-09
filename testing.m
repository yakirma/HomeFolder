
global idx;
plotIdxs = [8,10,11,13];

for i = 1:length(plotIdxs)
    idx = plotIdxs(i);
    
    subplot(2,2,i)
    plotScatters;
end
print(['sctters', '.png'], '-dpng');


