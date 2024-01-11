function sessions = bayesian_control_data

  % Real data 
  sessions.S16_1 = [{'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8'}];
  
  % Normalized between pairs, and each pair using only good cells for both tracks 
  sessions.S16_2= [{'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8\Bayesian controls\Normalize to each exposure_tracks good cells'}];
  
  % Normalized to each track and using only good cells of pertinent track 
  sessions.S16_3 = [{'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8\Bayesian controls\One track norm_track good cells'}];
  
  % Normalized to each track and using all good place cells
  sessions.S16_4 = [{'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8\Bayesian controls\One track normalization'}];








end