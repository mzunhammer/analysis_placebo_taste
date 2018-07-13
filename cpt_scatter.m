function cpt_scatter(x,y,factor)
figure
levels=categories(factor);
dotcolor=[.8 .8 .8];
iter=5000;
for i = 1:length(levels)
    curr_i=factor==levels{i};
    curr_x = x(curr_i);
    curr_y = y(curr_i);
    plot(curr_x,...
         curr_y,...
         '.','MarkerSize',20,'Color',dotcolor./i)
    hold on
    lsline
end
hold off
end