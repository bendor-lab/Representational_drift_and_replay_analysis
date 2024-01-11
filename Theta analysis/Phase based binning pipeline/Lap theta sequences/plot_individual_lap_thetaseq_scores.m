% Method: 1 for WeightedCorr or 2 for QuadrantRatio

function plot_individual_lap_thetaseq_scores(method)

load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')

if method == 1
    data = lap_WeightedCorr;
    quant = 'Weighted Correlation';
else
    data = lap_QuadrantRatio;
    quant = 'Quadrant Ratio';
end

PP = plotting_parameters;
prot_idx = [8,8,8,8,4,4,4,4,3,3,3,3,2,2,2,2,1,1,1,1];
protocols = [8,4,3,2,1];

% Get all track scores
T1 = nan(length(data),16);
T2 = nan(length(data),8);
T3 = nan(length(data),16);
T4 = nan(length(data),16);

 for ii = 1 : length(data)
     T1(ii,1:length(data(ii).track(1).score)) = data(ii).track(1).score;
     T2(ii,1:length(data(ii).track(2).score)) = data(ii).track(2).score;
     T3(ii,1:length(data(ii).track(3).score)) = data(ii).track(3).score;
     T4(ii,1:length(data(ii).track(4).score)) = data(ii).track(4).score;
 end


% Get average
for j = 1 : 16
    means(1,j) = sum(T1(~isnan(T1(:,j)),j))/(size(T1,1) - length(find(isnan(T1(:,j)))));
    stds(1,j) = sqrt(mean((T1(~isnan(T1(:,j)),j) - means(1,j)).^2));
    means(3,j) = sum(T3(~isnan(T3(:,j)),j))/(size(T3,1) - length(find(isnan(T3(:,j)))));
    stds(3,j) = sqrt(mean((T3(~isnan(T3(:,j)),j) - means(3,j)).^2));        
end
for p = 1 : length(protocols)
    dat = T2(prot_idx == protocols(p),1:protocols(p));
    dat4 = T4(prot_idx == protocols(p),1:16);    
    for j = 1 : protocols(p)
        mean_T2.P(p,j) = sum(dat(~isnan(dat(:,j)),j))/(size(dat,1) - length(find(isnan(dat(:,j)))));
        std_T2.P(p,j) = sqrt(mean((dat(~isnan(dat(:,j)),j) - mean_T2.P(p,j)).^2));
    end
    for j = 1 : 16
        mean_T4.P(p,j) = sum(dat4(~isnan(dat4(:,j)),j))/(size(dat4,1) - length(find(isnan(dat4(:,j)))));
        std_T4.P(p,j) = sqrt(mean((dat4(~isnan(dat4(:,j)),j) -  mean_T4.P(p,j)).^2));
    end
end

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = ['Individual_Lap_thetaseq_scores_' quant];
x1 = 1 : 16;
x2 = 18: 18+15;

for t = 1 : 4
    if t == 1
        xx = x1;
    else
        xx = x2;
    end
    hold on
    if t == 1 | t == 3
        plot(xx, means(t,:),'LineWidth',4,'Color',PP.T1);
        plot(xx, means(t,:),'o','MarkerSize',5,'MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1);
        % plot(x, mean_qr_scores,'o','MarkerEdgeColor',col{t},'MarkerFaceColor',col{t},'MarkerSize',4.5)
        % Add standard deviation as shade
        shade1 = means(t,:) + stds(t,:);
        shade2 = means(t,:) - stds(t,:);
        x = [xx,fliplr(xx)];
        inBetween = [shade1,fliplr(shade2)];
        h = fill(x,inBetween,PP.T1);
        set(h,'facealpha',0.05,'LineStyle','none')
        ylabel('Scores')
        xlabel('Lap number')
        FontSize = 14;
    else
        if t == 2
            data = mean_T2.P;
            data2 = std_T2.P;
            xx = protocols;
            for jj = 1 : size(data,1)
                plot(1:xx(jj),data(jj,1:xx(jj)),'LineWidth',4,'Color',PP.T2(jj,:));
                plot(1:xx(jj), data(jj,1:xx(jj)),'o','MarkerSize',5,'MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:));
                % plot(x, mean_qr_scores,'o','MarkerEdgeColor',col{t},'MarkerFaceColor',col{t},'MarkerSize',4.5)
                % Add standard deviation as shade
                shade1 = data(jj,1:xx(jj)) + data2(jj,1:xx(jj));
                shade2 = data(jj,1:xx(jj)) - data2(jj,1:xx(jj));
                x = [1:xx(jj),fliplr(1:xx(jj))];
                inBetween = [shade1,fliplr(shade2)];
                h = fill(x,inBetween,PP.T2(jj,:));
                set(h,'facealpha',0.05,'LineStyle','none')
                ylabel('Scores')
                xlabel('Lap number')
            end
        else
            data = mean_T4.P;
            data2 = std_T4.P;
            for jj = 1 : size(data,1)
                plot(x2,data(jj,:),'LineWidth',4,'Color',PP.T2(jj,:));
                plot(x2, data(jj,:),'o','MarkerSize',5,'MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:));
                % plot(x, mean_qr_scores,'o','MarkerEdgeColor',col{t},'MarkerFaceColor',col{t},'MarkerSize',4.5)
                % Add standard deviation as shade
                shade1 = data(jj,:) + data2(jj,:);
                shade2 = data(jj,:) - data2(jj,:);
                x = [x2,fliplr(x2)];
                inBetween = [shade1,fliplr(shade2)];
                h = fill(x,inBetween,PP.T2(jj,:));
                set(h,'facealpha',0.05,'LineStyle','none')
                ylabel('Scores')
                xlabel('Lap number')
            end
        end
    end
end   
    plot([17 17],[max(ylim) min(ylim)],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2);
    title(quant)
    ax= gca;
    ax.FontSize = 14;
    axis tight
    
    figure
    
    boxplot(T2,'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes =a(idx);
    set(boxes,'LineWidth',2); % Set width
    box off
    
    temp = nan(40,5);
    temp(1:20,1:5) = T1(:,1:5);
    temp(21:40,1) = T2(:,1);
    temp(21:40,2) = T2(:,2);
    temp(21:40,3) = T2(:,3);
    temp(21:40,4) = T2(:,4);
    temp(21:40,5) = T2(:,5);


    

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences',[])
end