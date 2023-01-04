%% Constantes del modelo troposferico MOPS con mapeo de Niell
clear;

global TROPO_GM TROPO_G TROPO_K1 TROPO_K2 TROPO_RD TROPO_DminN TROPO_DminS TROPO_AVG TROPO_VAR TROPO_NIELL

TROPO_GM = 9.784;		% [m/s^2]
TROPO_G  = 9.80665;		% [m/s^2]
TROPO_K1 = 77.604;		% [K/mbar]
TROPO_K2 = 382000;		% [K^2/mbar]
TROPO_RD = 287.054;		% [J/(kgK)]
TROPO_DminN   = 28;			% DoY min para el norte
TROPO_DminS   = 211;			% DoY min para el sur

p0 = [1013.25 1017.25 1015.75 1011.75 1013.00]; % [mbar]
t0 = [299.65 294.15 283.15 272.15 263.65];      % [K]
e0 = [26.31 21.79 11.66 6.78 4.11];             % [mbar]
b0 = [6.30e-3 6.05e-3 5.58e-3 5.39e-3 4.53e-3]; % [K/m]
l0 = [2.77 3.15 2.57 1.81 1.55];                % [?]

TROPO_AVG = [p0;t0;e0;b0;l0];

dp = [0.00 -3.75 -2.25 -1.75 -0.50];            % [mbar]
dt = [0.00 7.00 11.00 15.00 14.50];             % [K]
de = [0.00 8.85 7.24 5.36 3.39];                % [mbar]
db = [0.00e-3 0.25e-3 0.32e-3 0.81e-3 0.62e-3]; % [K/m]
dl = [0.00 0.33 0.46 0.74 0.30];                % [?]

TROPO_VAR = [dp;dt;de;db;dl];

a_avg = [1.2769934e-3 1.2683230e-3 1.2465397e-3 1.2196049e-3 1.2045996e-3];
b_avg = [2.9153695e-3 2.9152299e-3 2.9288445e-3 2.9022565e-3 2.9024912e-3];
c_avg = [62.610505e-3 62.837393e-3 63.721774e-3 63.824265e-3 64.258455e-3];
a_amp = [0.0 1.2709626e-5 2.6523662e-5 3.4000452e-5 4.1202191e-5];
b_amp = [0.0 2.1414979e-5 3.0160779e-5 7.2562722e-5 11.723375e-5];
c_amp = [0.0 9.0128400e-5 4.3497037e-5 84.795348e-5 170.37206e-5];
aht   = [2.53e-5 2.53e-5 2.53e-5 2.53e-5 2.53e-5];
bht   = [5.49e-3 5.49e-3 5.49e-3 5.49e-3 5.49e-3];
cht   = [1.14e-3 1.14e-3 1.14e-3 1.14e-3 1.14e-3];
a_wet = [5.8021897e-4 5.6794847e-4 5.8118019e-4 5.9727542e-4 6.1641693e-4];
b_wet = [1.4275268e-3 1.5138625e-3 1.4572752e-3 1.5007428e-3 1.7599082e-3];
c_wet = [4.3472961e-2 4.6729510e-2 4.3908931e-2 4.4626982e-2 5.4736038e-2];

TROPO_NIELL = [a_avg;b_avg;c_avg;a_amp;b_amp;c_amp;aht;bht;cht;a_wet;b_wet;c_wet];

clear p0 t0 e0 b0 l0 dp dt de db dl a_avg b_avg c_avg a_amp b_amp c_amp aht bht cht a_wet b_wet c_wet

save('../Datos/ConstantesTroposfera.mat');  

disp(['Constantes de la TROPOSFERA guardadas'])	                
