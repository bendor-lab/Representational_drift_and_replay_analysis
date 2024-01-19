% Script to plot place field of a place cell before / after sleep
cd C:\Users\pierre.varichon\Desktop\Pierre\Scripts

load 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN'
data_POST1 = place_fields_BAYESIAN;

load 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN'
data_POST2 = place_fields_BAYESIAN;

clear place_fields_BAYESIAN;

cellId = 2;

pf_Track1_POST1 = data_POST1.track(1).raw{cellId};
pf_Track1_POST2 = data_POST2.track(1).raw{cellId};

pf_Track2_POST1 = data_POST1.track(2).raw{cellId};
pf_Track2_POST2 = data_POST2.track(2).raw{cellId};


tiledlayout(2,1)

% Top plot
nexttile
plot(pf_Track1_POST1)
hold on;
plot(pf_Track1_POST2)
title("Place Field of cell n" + cellId + " on track 1")

% Bottom plot
nexttile
plot(pf_Track2_POST1)
hold on;
plot(pf_Track2_POST2)
title("Place Field of cell n" + cellId + " on track 2")

