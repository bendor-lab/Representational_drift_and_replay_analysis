
function plot_Lap_PV_correlation 

% Plot lap to lap PV comparison (leave one out)
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\lap_PV_comparison_excl.mat')

protocols = 1:5;
num_tracks = 4;
c=1;
for t = 1 : num_tracks
    curr_sess = 1 : 4;
    pv_average_lap(t).track = nan(16,length(protocols)*length(curr_sess));
    % Extract averaged PV per lap, for each track and session
    for prot = 1 : length(protocols)
        pv_average_lap(t).track(:,curr_sess) = cell2mat(arrayfun(@(x) squeeze(PV_vals.average_lap_population_vector(t,x,:)),curr_sess,'UniformOutput',0));
        if prot == 2
            curr_sess = curr_sess + 3; % excluding 16x4 MBLU
        else
            curr_sess = curr_sess + 4;
        end
    end
    pv_average_lap(t).track(pv_average_lap(t).track == 0) = NaN; % replace 0 by NaNs
    % For each protocol, average by track and get std
    if mod(t,2) ~= 0 % T1 or T3
        PV_protocol_lap_average(:,c) = mean(pv_average_lap(t).track,2,'omitnan');
        PV_protocol_lap_std(:,c) = std(pv_average_lap(t).track,[],2,'omitnan');
        c=c+1;
    else
        PV_protocol_lap_average(:,c:c+4) = cell2mat(arrayfun(@(x) mean(pv_average_lap(t).track(:,x:x+3),2,'omitnan'),[1,5,9,13,17],'UniformOutput',0));
        PV_protocol_lap_std(:,c:c+4) = cell2mat(arrayfun(@(x) std(pv_average_lap(t).track(:,x:x+3),[],2,'omitnan'),[1,5,9,13,17],'UniformOutput',0));
        c=c+5;
    end
end
PV_protocol_lap_average(9,2) = NaN;
PV_protocol_lap_std(9,2) = NaN;


%%%  PLOT

f1 = figure('units','normalized','Color','w','Name','Lap PV correlation');
PP = plotting_parameters;

% Plot T1
x = 1:numel(PV_protocol_lap_average(:,1));
shade1 = PV_protocol_lap_average(:,1) + PV_protocol_lap_std(:,1);
shade2 = PV_protocol_lap_average(:,1) - PV_protocol_lap_std(:,1);
x2 = [x,fliplr(x)];
inBetween = [shade1',fliplr(shade2')];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
p1 = plot(PV_protocol_lap_average(:,1),'Color',PP.T1,'LineWidth',4);
hold on
plot(PV_protocol_lap_average(:,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)

% T1 Re-exposure
x = 18:17+numel(PV_protocol_lap_average(:,7));
shade1 = PV_protocol_lap_average(:,7) + PV_protocol_lap_std(:,7);
shade2 = PV_protocol_lap_average(:,7) - PV_protocol_lap_std(:,7);
x2 = [x,fliplr(x)];
inBetween = [shade1',fliplr(shade2')];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
plot(18:1:18+15,PV_protocol_lap_average(:,7),'Color',PP.T1,'LineWidth',4);
plot(18:1:18+15,PV_protocol_lap_average(:,7),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)

for ii = 2 : length(protocols)+1

    % Plot T2
    x = 1:numel(PV_protocol_lap_average(:,ii));
    shade1 = PV_protocol_lap_average(:,ii) + PV_protocol_lap_std(:,ii);
    shade2 = PV_protocol_lap_average(:,ii) - PV_protocol_lap_std(:,ii);
    x2 = [x,fliplr(x)];
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,PP.T2(ii-1,:));
    set(h,'facealpha',0.04,'LineStyle','none')
    hold on
    plot(PV_protocol_lap_average(:,ii),'Color',PP.T2(ii-1,:),'LineWidth',4);
    plot(PV_protocol_lap_average(:,ii),'o','MarkerFaceColor',PP.T2(ii-1,:),'MarkerEdgeColor',PP.T2(ii-1,:),'MarkerSize',5)

    % T2 re-exposure

    x = 18:17+numel(PV_protocol_lap_average(:,ii+6));
    shade1 = PV_protocol_lap_average(:,ii+6) + PV_protocol_lap_std(:,ii+6);
    shade2 = PV_protocol_lap_average(:,ii+6) - PV_protocol_lap_std(:,ii+6);
    x2 = [x,fliplr(x)];
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,PP.T2(ii-1,:));
    set(h,'facealpha',0.04,'LineStyle','none')
    hold on
    plot(18:1:18+15,PV_protocol_lap_average(:,ii+6),'Color',PP.T2(ii-1,:),'LineWidth',4);
    plot(18:1:18+15,PV_protocol_lap_average(:,ii+6),'o','MarkerFaceColor',PP.T2(ii-1,:),'MarkerEdgeColor',PP.T2(ii-1,:),'MarkerSize',5)
end
hold on

set(gca,'FontSize',15,'TickDir','out','TickLength',[.005 1],'LineWidth',1.5)
box off
xlabel('Laps','FontSize',15); ylabel('PV correlation','FontSize',15)
xticks([0:2:16,19:2:35]); xticklabels([0:2:16,2:2:16])
form.TickDir = 'out';
form.TickLength = [.005 1];
form.LineWidth = 1.5;


end
