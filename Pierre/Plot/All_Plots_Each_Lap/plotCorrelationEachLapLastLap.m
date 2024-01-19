% Function that plot the correlation between place field calculated with
% lap N of track 1 / 2 (physical) and last lap

PATH.SCRIPT = fileparts(mfilename('fullpath'));
path_to_data = PATH.SCRIPT + "\..\Data\PC_Decoding_Each_Lap_ALL\";
listing_files = {dir(path_to_data).name};
listing_files([1, 2]) = [];

finalData = struct("condition", {}, "session", {}, "lap", {}, "PV_cor", {});

for file_ID = 1:length(listing_files)
    disp(file_ID + " / " + length(listing_files));
    filename = listing_files(file_ID);
    filename = filename{1};
    
    % We get the main variable = condition from the name
    split_name = split(filename, '.');
    split_name = split(split_name(1), '_');
    split_condition = split(split_name(end - 1), 'x');
    if split_name(end) == "Track1" || split_name(end) == "Track3"
        condition = string(split_condition(1));
        % We define the lap we want to do the comparison with
        pathToCompareTo = filename;
        pathToCompareTo(end - 4) = '3'; % Track 3 is re-exp of track 1
    else
        condition = string(split_condition(2));
        pathToCompareTo = filename;
        pathToCompareTo(end - 4) = '4'; % Track 4 is re-exp of track 2
    end
    
    if split_name(end) == "Track3" || split_name(end) == "Track4"
        session = 2;
    else
        session = 1;
    end
    
    % Now we can load the data
    currentPFData = load(path_to_data + filename);
    currentPFData = currentPFData.placeFieldDecEachLap;
    
    concurentPFData = load(path_to_data + pathToCompareTo);
    concurentPFData = concurentPFData.placeFieldDecEachLap;
    concurentPFVector = concurentPFData(end).place_fields;
    
    % We define a correlation vector accross each lap
    corr_vector = repelem(0, length(currentPFData));
    
    for lap = 1:length(currentPFData)
        
        currentPFVector = currentPFData(lap).place_fields;
        
        % We find the ID of shared good cells between the two
        currentGoodCells = currentPFData(lap).good_cells;
        concurrentGoodCells = concurentPFData(end).good_cells;
        [goodCells, ] = intersect(currentGoodCells, concurrentGoodCells); 
        
        global_cor_vector = repelem(0, length(100));
        
        % We iterate through spatial positions
        for x_bin = 1:100
            
            population_vector = [];
            concurent_PV = [];
            
            % we iterate throught cells
            for cell_ID = goodCells
                % We register the mean activity of the cell at this point
                cell_PF = currentPFVector(cell_ID);
                cell_PF = cell_PF{1};
                cellActivityAtBin = cell_PF(x_bin);
                population_vector(end + 1) = cellActivityAtBin;
                
                % We register the mean activity of the cell at this point
                % on T3/4
                
                Oth_cell_PF = concurentPFVector(cell_ID);
                Oth_cell_PF = Oth_cell_PF{1};
                Oth_cellActivityAtBin = Oth_cell_PF(x_bin);
                concurent_PV(end + 1) = Oth_cellActivityAtBin;
                
            end
            
            % Now that we have our vectors, we compute the correlation
            % between them
            
            PV_COR = corrcoef(population_vector, concurent_PV);
            PV_COR = PV_COR(2, 1);
            
            % We addt this correlation to the global_cor_vector
            global_cor_vector(x_bin) = PV_COR;
        end
        
        % Get the mean PV correlation
        mean_cor = mean(global_cor_vector, 'omitnan');
        
        % We concat
        finalData = [finalData ; struct("condition", condition, "session", session , "lap", lap, "PV_cor", mean_cor)];
        
    end
    
    
end

% We mean all the values for the 16 laps condition (because multiple data)

finalDataMean = struct("condition", [], "session", [], "lap", [], "PV_cor", []);

all_16 = finalData([finalData.condition] == "16");
finalDataMean = finalData([finalData.condition] ~= "16");

for session = 1:2
    for uniqueLap = unique([all_16.lap])
        allMatches = all_16([all_16.lap] == uniqueLap & [all_16.session] == session);
        mean_PV_cor = mean([allMatches.PV_cor]);
        if ~isnan(mean_PV_cor)
            finalDataMean = [finalDataMean ; ...
                struct("condition", "16", "session", session, "lap", uniqueLap, "PV_cor", mean_PV_cor)];
        end
    end
end

% Now we can plot !

unique_conditions = unique([finalDataMean.condition]);
% Re-order condition in increasing order                                                  
unique_conditions = unique_conditions([1, 3, 4, 5, 6, 2]);

for session = 1:2
    disp(session);
    subplot(1, 2, session)
    
    for condition = unique_conditions
        disp(condition);
        
        subset = finalDataMean([finalDataMean.condition] == condition & [finalDataMean.session] == session);
        X = [subset.lap];
        Y = [subset.PV_cor];
        [~,Xsort]=sort(X); %Get the order of B
        Y = Y(Xsort);
        X = sort(X);
        
        % We remove values after 20
        if length(Y) > 20
            Y = Y(1:20);
            X = X(1:20);
        end
        
        % If only one point (condition 16x1), we only plot the point
        
        if length(Y) == 1
            plot(X, Y, '.', 'DisplayName',condition)
        else
            plot(X, Y, 'LineWidth', 2, 'DisplayName',condition)
        end
        
        hold on;
    end
    set(gca, 'YLim', [0, 0.5]);
    hold off;
    lgd = legend;
end

