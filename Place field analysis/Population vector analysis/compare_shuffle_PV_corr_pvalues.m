% COMPARISON SHUFFLE TO REAL DATA HISTOGRAM OF PVALS
% MH 2020
% Compare population vector analysis distributions versus shuffles. 
% INPUT:
    % remap: 'global' or 'rate' for different types of remapping

function protocol = compare_shuffle_PV_corr_pvalues(remap)

if strcmp(remap,'global')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\population_vector_data_bayesian.mat')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\global_shuffle_population_vector_data_bayesian.mat')
elseif strcmp(remap,'rate')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\firing_rate_population_vector_data_bayesian.mat')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\firing_rate_shuffle_population_vector_data_bayesian.mat')    
    protocol = protocol_firing_rate;
    clear protocol_firing_rate
    protocol_global_shuffle = protocol_firing_rate_shuffle;
    clear protocol_firing_rate_shuffle
end

PP = plotting_parameters;
rats = {'MBLU','NBLU','PORA','QBLU'};
comps = {'T1vsRT1','T2vsRT2','T1vsT2'};

f1 = figure;
f1.Name = 'Pval distribution shuffle vs PV corr bayesian';
cnt = 1;        
for c = 1 : 3 % for first 3 comparisons    
    for p = 1 : size(protocol,2) % for each protocol
        for r = 1 : size(protocol(p).session,2) % for each rat/session
            subplot(3,5,cnt)
            hold on
            % shuffles
            histogram(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector'))(:,c),'Normalization','probability','DisplayStyle','stairs','EdgeColor',[0.3 0.3 0.3],'LineWidth',2)
            thresh = prctile(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector'))(:,c),05);
            % Real data
            if strcmp(remap,'global')
            histogram(protocol(p).session(r).population_vector(:,c),'Normalization','probability','DisplayStyle','stairs','EdgeColor',PP.(sprintf('%s',rats{r})),'LineWidth',3)
            plot([median(protocol(p).session(r).population_vector(:,c)) median(protocol(p).session(r).population_vector(:,c))],[1 1],'Marker','*','MarkerFaceColor',PP.(sprintf('%s',rats{r})),...
                'MarkerEdgeColor',PP.(sprintf('%s',rats{r})),'MarkerSize',6)
            else
            histogram(protocol(p).session(r).firing_rate_PPvector(:,c),'Normalization','probability','DisplayStyle','stairs','EdgeColor',PP.(sprintf('%s',rats{r})),'LineWidth',3)
            plot([median(protocol(p).session(r).firing_rate_PPvector(:,c)) median(protocol(p).session(r).firing_rate_PPvector(:,c))],[1 1],'Marker','*','MarkerFaceColor',PP.(sprintf('%s',rats{r})),...
                'MarkerEdgeColor',PP.(sprintf('%s',rats{r})),'MarkerSize',6)
            end
            plot([median(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector'))(:,c)) median(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector'))(:,c))],[1 1],'Marker','*',...
                'MarkerFaceColor',[0.3 0.3 0.3],'MarkerEdgeColor',[0.3 0.3 0.3],'MarkerSize',6)            
            
            % RUN KRUSKAL-WALLIS
            joined_data = NaN(length(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector'))(:,c)),2);
            joined_data(:,1) = protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector'))(:,c);
            if strcmp(remap,'global')
                joined_data(1:length(protocol(p).session(r).population_vector(:,c)),2) = protocol(p).session(r).population_vector(:,c);
            else
                joined_data(1:length(protocol(p).session(r).firing_rate_PPvector(:,c)),2) = protocol(p).session(r).firing_rate_PPvector(:,c);
            end
            [pv,tble,~] = kruskalwallis(joined_data,[],'off');
            protocol(p).(sprintf('%s',comps{c},'_KWtble')){r} = tble;
            protocol(p).(sprintf('%s',comps{c},'_KWtble_pval'))(r) = pv;
            
        end
        ylabel('Prop of p-value')
        xlabel('P-value')
        if isfield('protocol','protocol_ID')
            title(protocol(p).protocol_ID)
        else
            title(protocol(p).session_ID)
        end
        cnt = cnt +1;
    end
end

f2 = figure;
f2.Name = 'Pval distribution shuffle vs PV corr bayesian_SECTION';
cnt = 1;        
for c = 1 : 3 % for first 3 comparisons
    
    for p = 1 : size(protocol,2) % for each protocol
        for r = 1 : size(protocol(p).session,2) % for each rat/session
            subplot(3,5,cnt)
            hold on
            % shuffles
            histogram(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector_SECTION'))(:,c),'Normalization','probability','DisplayStyle','stairs','EdgeColor',[0.3 0.3 0.3],'LineWidth',2)
            thresh = prctile(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector_SECTION'))(:,c),05);
            % Real data
            if strcmp(remap,'global')
                histogram(protocol(p).session(r).section_population_vector(:,c),'Normalization','probability','DisplayStyle','stairs','EdgeColor',PP.(sprintf('%s',rats{r})),'LineWidth',3)
                plot([median(protocol(p).session(r).section_population_vector(:,c)) median(protocol(p).session(r).section_population_vector(:,c))],[1 1],'Marker','*','MarkerFaceColor',PP.(sprintf('%s',rats{r})),...
                    'MarkerEdgeColor',PP.(sprintf('%s',rats{r})),'MarkerSize',6)
            else
                histogram(protocol(p).session(r).firing_rate_PPvector_SECTION(:,c),'Normalization','probability','DisplayStyle','stairs','EdgeColor',PP.(sprintf('%s',rats{r})),'LineWidth',3)
                plot([median(protocol(p).session(r).firing_rate_PPvector_SECTION(:,c)) median(protocol(p).session(r).firing_rate_PPvector_SECTION(:,c))],[1 1],'Marker','*','MarkerFaceColor',PP.(sprintf('%s',rats{r})),...
                    'MarkerEdgeColor',PP.(sprintf('%s',rats{r})),'MarkerSize',6)                
            end
            plot([median(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector_SECTION'))(:,c)) median(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector_SECTION'))(:,c))],[1 1],'Marker','*',...
                'MarkerFaceColor',[0.3 0.3 0.3],'MarkerEdgeColor',[0.3 0.3 0.3],'MarkerSize',6)
            
            % RUN KRUSKAL-WALLIS
            joined_data = NaN(length(protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector_SECTION'))(:,c)),2);
            joined_data(:,1) = protocol_global_shuffle(p).session(r).(sprintf('%s','shuffled_',remap,'Remap_PPvector_SECTION'))(:,c);
            if strcmp(remap,'global')
                joined_data(1:length(protocol(p).session(r).section_population_vector(:,c)),2) = protocol(p).session(r).section_population_vector(:,c);
            else
                joined_data(1:length(protocol(p).session(r).firing_rate_PPvector(:,c)),2) = protocol(p).session(r).firing_rate_PPvector(:,c);
            end
            [pv,tble,~] = kruskalwallis(joined_data,[],'off');
            protocol(p).(sprintf('%s',comps{c},'_KWtble_SECTION')){r} = tble;
            protocol(p).(sprintf('%s',comps{c},'_KWtble_SECTION_pval'))(r) = pv;
        end
        ylabel('Prop of p-value')
        xlabel('P-value')
        if isfield('protocol','protocol_ID')
            title(protocol(p).protocol_ID)
        else
            title(protocol(p).session_ID)
        end
        cnt = cnt +1;
    end
end

end