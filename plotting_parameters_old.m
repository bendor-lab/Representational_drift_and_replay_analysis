% PLOTTING PARAMETERS
% Marta Huelin

function plot_param = plotting_parameters_old

% protocol colors from viridis palette
plot_param.viridis_colormap = [0.26700401 0.00487433 0.32941519;...
    0.501960784313725 0.180392156862745 0.549019607843137;...
    0.301960784313725 0.349019607843137 0.650980392156863;...
    0.180392156862745 0.501960784313725 0.568627450980392;...
    0.12156862745098 0.670588235294118 0.541176470588235;...
    0.309803921568627 0.788235294117647 0.411764705882353];

L16 = [0.26700401 0.00487433 0.32941519];
L8 = [0.501960784313725 0.180392156862745 0.549019607843137];
L4 = [0.301960784313725 0.349019607843137 0.650980392156863];
L3 = [0.180392156862745 0.501960784313725 0.568627450980392];
L2 = [0.12156862745098 0.670588235294118 0.541176470588235];
L1 = [0.309803921568627 0.788235294117647 0.411764705882353];

L16_Transparent = [0.4 0.4 0.6];
L8_Transparent = [0.6 0.4 0.8];
L4_Transparent = [0 0.4 1];
L3_Transparent = [0.2 0.6 0.6];
L2_Transparent = [0.4 0.8 0.6];
L1_Transparent = [0.6 1 0.6];

% COLORS
colors.blue = [0, 0.4470, 0.7410];
colors.cian = [0.3010, 0.7450, 0.9330];
colors.purple = [0.4940, 0.1840, 0.5560];
colors.orange = [0.8500, 0.3250, 0.0980];
colors.light_orange = [1, 0.8, 0.2];
colors.yellow = [0.9290, 0.6940, 0.1250];
colors.light_yellow = [0.8, 0.6, 0.2]; 
colors.green = [0.4660, 0.6740, 0.1880];
colors.red = [0.6350, 0.0780, 0.1840];
colors.light_red = [0.8, 0, 0.2]; 
colors.gray = [0.25, 0.25, 0.25];
colors.darkBlue = [0, 0, 1];
colors.darkGreen = [0, 0.5, 0];
colors.magenta = [0.75, 0, 0.75];
colors.black = [0, 0, 0];

grayscale = gray(16);
plot_param.grayscale = grayscale;

%% CHAPTER 1 & 2

% Plot plField LAP correlation
plot_param.L16 = L16;
plot_param.L8 = L8;
plot_param.L4 = L4;
plot_param.L3 = L3;
plot_param.L2 = L2;
plot_param.L1 = L1;

% Protocol colors    
plot_param.T1 = L16; %16 Laps
plot_param.T2(1,:) = L8; % 8 Laps
plot_param.T2(2,:) = L4; % 4 Laps
plot_param.T2(3,:) = L3; % 3 Laps
plot_param.T2(4,:) = L2; % 2 Laps
plot_param.T2(5,:) = L1; % 1 Lap

% Protocol transparent colors    
plot_param.T1_transp = L16_Transparent; %16 Laps
plot_param.T2_transp(1,:) = L8_Transparent; % 8 Laps
plot_param.T2_transp(2,:) = L4_Transparent; % 4 Laps
plot_param.T2_transp(3,:) = L3_Transparent; % 3 Laps
plot_param.T2_transp(4,:) = L2_Transparent; % 2 Laps
plot_param.T2_transp(5,:) = L1_Transparent; % 1 Lap

% 8 LAPS color
plot_param.P(1).colorT(1,:) = L16;
plot_param.P(1).colorT(2,:) = L8;
plot_param.P(1).colorT(3,:) = L16;
plot_param.P(1).colorT(4,:) = L8;
% 4 LAPS color
plot_param.P(2).colorT(1,:) = L16;
plot_param.P(2).colorT(2,:) = L4;
plot_param.P(2).colorT(3,:) = L16;
plot_param.P(2).colorT(4,:) = L4;
% 3 LAPS color
plot_param.P(3).colorT(1,:) = L16;
plot_param.P(3).colorT(2,:) = L3;
plot_param.P(3).colorT(3,:) = L16;
plot_param.P(3).colorT(4,:) = L3;
% 2 LAPS color
plot_param.P(4).colorT(1,:) = L16;
plot_param.P(4).colorT(2,:) = L2;
plot_param.P(4).colorT(3,:) = L16;
plot_param.P(4).colorT(4,:) = L2;
% 1 LAP color
plot_param.P(5).colorT(1,:) = L16;
plot_param.P(5).colorT(2,:) = L1;
plot_param.P(5).colorT(3,:) = L16;
plot_param.P(5).colorT(4,:) = L1;

%Line style for each track (1 to 4)
plot_param.Linestyle{1} = '-';
plot_param.Linestyle{2} = '-';
plot_param.Linestyle{3} = ':';
plot_param.Linestyle{4} = ':';

%Line width for each track (1 to 4)
plot_param.Linewidth{1} = 2;
plot_param.Linewidth{2} = 2;
plot_param.Linewidth{3} = 2.5;
plot_param.Linewidth{4} = 2.5;


% Rat colors:
plot_param.MBLU = [0.552941176470588 0.415686274509804 0.623529411764706]; %[97/255 48/255 75/255]; % MBLU
plot_param.NBLU = [0.929411764705882 0.749019607843137 0.129411764705882];%[172/255 123/255 132/255]; % NBLU
plot_param.PORA = [0 0.6 0.741176470588235];%[186 /255 86/255 36/255]; %PORA
plot_param.QBLU = [0.8 0.301960784313725 0.309803921568627];%[95/255 117/255 142/255]; %QBLU

% Rat markers
plot_param.rat_markers{1} = 'h';
plot_param.rat_markers{2} = 'diamond';
plot_param.rat_markers{3} = 'o';
plot_param.rat_markers{4} = 'square';
plot_param.rat_markers_size{1} = 6;
plot_param.rat_markers_size{2} = 5;
plot_param.rat_markers_size{3} = 5;
plot_param.rat_markers_size{4} = 6;


% TITLES
plot_param.titles.protocols = {'8 Laps','4 Laps','3 Laps','2 Laps','1 Lap'};

parameters.plot_color_line= {'b','c','b','m','g','y','c','k'};
parameters.plot_color_symbol= {'ro','gx','b+','ms','yd','c*','k^'};
parameters.plot_color_dot= {'r.','b.','g.','c.','m.','y.','k.'};  
parameters.legend={'track 1','track 2','track 3','track 4','track 5','track 6'};


% COMPARISONS COLORS
% 8 LAPS color
plot_param.comp(1).colorT(1,:) = L16;
plot_param.comp(1).colorT(2,:) = L8;
plot_param.comp(1).colorT(3,:) = grayscale(5,:); % 1 vs 2
plot_param.comp(1).colorT(4,:) = grayscale(8,:);  % 2 vs 3
plot_param.comp(1).colorT(5,:) = grayscale(11,:); % 1 vs 4
plot_param.comp(1).colorT(6,:) = grayscale(13,:);  % 3 vs 4

% 4 LAPS color
plot_param.comp(2).colorT(1,:) = L16;
plot_param.comp(2).colorT(2,:) = L4;
plot_param.comp(2).colorT(3,:) = grayscale(5,:); % 1 vs 2
plot_param.comp(2).colorT(4,:) = grayscale(8,:);  % 2 vs 3
plot_param.comp(2).colorT(5,:) = grayscale(11,:); % 1 vs 4
plot_param.comp(2).colorT(6,:) = grayscale(13,:);  % 3 vs 4

% 3 LAPS color
plot_param.comp(3).colorT(1,:) = L16;
plot_param.comp(3).colorT(2,:) = L3;
plot_param.comp(3).colorT(3,:) = grayscale(5,:); % 1 vs 2
plot_param.comp(3).colorT(4,:) = grayscale(8,:);  % 2 vs 3
plot_param.comp(3).colorT(5,:) = grayscale(11,:); % 1 vs 4
plot_param.comp(3).colorT(6,:) = grayscale(13,:);  % 3 vs 4

% 2 LAPS color
plot_param.comp(4).colorT(1,:) = L16;
plot_param.comp(4).colorT(2,:) = L2;
plot_param.comp(4).colorT(3,:) = grayscale(5,:); % 1 vs 2
plot_param.comp(4).colorT(4,:) = grayscale(8,:);  % 2 vs 3
plot_param.comp(4).colorT(5,:) = grayscale(11,:); % 1 vs 4
plot_param.comp(4).colorT(6,:) = grayscale(13,:);  % 3 vs 4

% 1 LAP color
plot_param.comp(5).colorT(1,:) = L16;
plot_param.comp(5).colorT(2,:) = L1;
plot_param.comp(5).colorT(3,:) = grayscale(5,:); % 1 vs 2
plot_param.comp(5).colorT(4,:) = grayscale(8,:);  % 2 vs 3
plot_param.comp(5).colorT(5,:) = grayscale(11,:); % 1 vs 4
plot_param.comp(5).colorT(6,:) = grayscale(13,:);  % 3 vs 4



%% VIRIDIS PALETTE POTENTIAL COMBINATIONS FOR 6 COLORS
e = [0.26700401 0.00487433 0.32941519;...
    %0.349019607843137 0.180392156862745 0.490196078431373;...
    0.301960784313725 0.349019607843137 0.549019607843137;...
    0.180392156862745 0.501960784313725 0.568627450980392;...
    0.12156862745098 0.670588235294118 0.541176470588235;...
    0.309803921568627 0.788235294117647 0.411764705882353;...
    0.477504460000000,0.821443510000000,0.318195290000000];
      
a = [0.26700401 0.00487433 0.32941519;...
    0.349019607843137 0.180392156862745 0.490196078431373;...
    0.301960784313725 0.349019607843137 0.549019607843137;...
    0.180392156862745 0.501960784313725 0.568627450980392;...
    0.12156862745098 0.670588235294118 0.541176470588235;...
    0.309803921568627 0.788235294117647 0.411764705882353];


b = [0.267004010000000,0.00487433000000000,0.329415190000000;...
    0.253934980000000,0.265253840000000,0.529982730000000;...
    0.163625430000000,0.471132780000000,0.558148420000000;...
    0.134691830000000,0.658636190000000,0.517648800000000;...
    0.477504460000000,0.821443510000000,0.318195290000000;...
    0.8 0.8 0.149019607843137];


c = [0.267004010000000,0.00487433000000000,0.329415190000000;...
    0.4 0.270588235294118 0.529411764705882;...
    0.163625430000000,0.471132780000000,0.558148420000000;...
    0.134691830000000,0.658636190000000,0.517648800000000;...
    0.477504460000000,0.821443510000000,0.318195290000000;...
    0.8 0.8 0.149019607843137];

d = [0.26700401 0.00487433 0.32941519;...
    0.349019607843137 0.180392156862745 0.490196078431373;...
    0.180392156862745 0.501960784313725 0.568627450980392;...
    0.180392156862745 0.501960784313725 0.568627450980392;...
    0.12156862745098 0.670588235294118 0.541176470588235;...
    0.309803921568627 0.788235294117647 0.411764705882353];

end 