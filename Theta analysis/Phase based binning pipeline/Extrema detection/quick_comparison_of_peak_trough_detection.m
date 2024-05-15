datapath = 'X:\BendorLab\Drobo\Neural and Behavioural Data\Theta analysis\Data Marta\P-ORA_Day5_16x8';

cscFile = 'extracted_CSC.mat';
posFile = 'extracted_position.mat';

load(fullfile(datapath,cscFile))

lfp   = CSC(1).CSCraw;
theta = CSC(1).theta;
t     = CSC(1).CSCtime;

%% method 1 - using MATLAB findpeaks function
[pks(:,2), pks(:,1)] = findpeaks(theta);
[trs(:,2), trs(:,1)] = findpeaks(-theta);
trs(:,2) = - trs(:,2);


%% method 2 - using local extrema detection over sliding window
[pks2,trs2,minChange] = findMinMax(theta, 0.25);

% clean both with 2 conditions: 
% - peaks must be positive, troughs negative
% - it has to go peak-trough-peak etc
extrema1 = clean_peaks_and_troughs(theta,pks,trs);
extrema2 = clean_peaks_and_troughs(theta,pks2,trs2);

% separate back into peaks and troughs
peaks1   = extrema1(extrema1(:,3) == 1,:);
troughs1 = extrema1(extrema1(:,3) == -1,:);

peaks2   = extrema2(extrema2(:,3) == 1,:);
troughs2 = extrema2(extrema2(:,3) == -1,:);

% compare raw and cleaned method 1
figure;
axes('next','add')
plot(t,lfp,'color',[0.5 0.5 0.5 0.5])
plot(t,theta,'k','LineWidth',1.5)
plot(t(pks(:,1)),pks(:,2),'c','Marker','x','LineStyle','none')
plot(t(trs(:,1)),trs(:,2),'b','Marker','x','LineStyle','none')
plot(t(peaks1(:,1)),peaks1(:,2),'c','Marker','o','LineStyle','none')
plot(t(troughs1(:,1)),troughs1(:,2),'b','Marker','o','LineStyle','none')

% compare method 1 and method 2
figure;
axes('next','add')
plot(t,lfp,'color',[0.5 0.5 0.5 0.5])
plot(t,theta,'k','LineWidth',1.5)
plot(t(peaks1(:,1)),peaks1(:,2),'c','Marker','x','LineStyle','none')
plot(t(troughs1(:,1)),troughs1(:,2),'b','Marker','x','LineStyle','none')
plot(t(peaks2(:,1)),peaks2(:,2),'m','Marker','o','LineStyle','none')
plot(t(troughs2(:,1)),troughs2(:,2),'g','Marker','o','LineStyle','none')
