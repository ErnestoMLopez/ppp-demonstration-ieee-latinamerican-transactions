function J20002ITRF = j20002itrf(UTC,EOP)
%J20002ITRF Matrices de transformación y de moviemiento del polo 
%entre marcos J2000/ITRF
%   Calcula la matriz de transformación entre los marcos J2000 e ITRF 
%	mediante la teoría IAU-76/FK5, como así también la matriz de movimiento 
%	del polo W, utilizada en el calculo de T pero también necesaria para 
%	convertir velocidades de un marco a otro.
% 
%	El código de esta función está basado en la función dcmeci2ecef del
%	Aerospace Toolbox de Matlab, modificado para una sola fecha, para 
%	utilizar siempre la reducción IAU-76/FK5 y para devolver no solo la
%	matriz T sino las 3 matrices que la conforman

%% Validate i/o
% Validate outputs
nargoutchk(0,1)
% Validate amount
narginchk(1,2)
% Validate date
validateattributes(UTC,{'numeric'},{'ncols',6,'real','finite','nonnan'})

% Assign date vectors
year = UTC(:,1);
month = UTC(:,2);
day = UTC(:,3);
hour = UTC(:,4);
min = UTC(:,5);
sec = UTC(:,6);

% Validate vectors
if any(year<1)
    error(message('aero:dcmeci2ecef:invalidYear'));
end
if any(month<1) || any(month>12)
    error(message('aero:dcmeci2ecef:invalidMonth'));
end
if any(day<1) || any(day>31)
    error(message('aero:dcmeci2ecef:invalidDay'));
end
if any(hour<0) || any(hour>24)
    error(message('aero:dcmeci2ecef:invalidHour'));
end
if any(min<0) || any(min>60)
    error(message('aero:dcmeci2ecef:invalidMin'));
end
if any(sec<0) || any(sec>60)
    error(message('aero:dcmeci2ecef:invalidSec'));
end
% Check for year fractions
if any(mod(year,1)~=0)
    year = fix(year);
end
if any(mod(month,1)~=0)
    month = fix(month);
end
if any(mod(day,1)~=0)
    day = fix(day);
end
if any(mod(hour,1)~=0)
    hour = fix(hour);
end
if any(mod(min,1)~=0)
    min = fix(min);
end
len = length(year);

DEG2RAD = pi/180;


%% Common time calculations
% Calculations determining the number of Julian centuries for terrestrial
% time (tTT) and UT1.

% Seconds for UT1
ssUT = sec + EOP.dUT1; 

% Seconds for UTC
ssTT = sec + EOP.dAT + 32.184; 

% Julian date for terrestrial time
jdTT = ymdhms2mjd(year,month,day,hour,min,ssTT);

% Number of Julian centuries since J2000 for terrestrial time.
tTT = (jdTT - 51544.5)/36525;
tTT2 = tTT.*tTT;
tTT3 = tTT2.*tTT;


%% IAU-76/FK-5 based transformation
% This transformation is based on the process described by Vallado
% (originally McCarthy).

% Additional time calculations:
jdUT1 = mjuliandate(year,month,day);
tUT1 = (jdUT1 - 51544.5)/36525;
tUT12 = tUT1.*tUT1;
tUT13 = tUT12.*tUT1;


%% Sidereal time
% Greenwich mean sidereal time at midnight
thGMST0h = 100.4606184 + 36000.77005361*tUT1 + 0.00038793*tUT12 - 2.6e-8*tUT13;

% Ratio of universal to sidereal time
omegaPrec = 1.002737909350795 + 5.9006e-11*tUT1 - 5.9e-15*tUT12;

% Elapsed universal time since midnight to the time of the
% observation
UT1 = hour*60*60 + min*60 + ssUT;

% Greenwich mean sidereal time at time of the observation
thGMST = mod(thGMST0h + (360/(24*60*60))*omegaPrec.*UT1,360);


%% Nutation
% Mean obliquity of the ecliptic
epsilonBar = DEG2RAD.*(23.439291 - 0.0130042*tTT - 1.64e-7*tTT2 + 5.04e-7*tTT3);

% Nutation angles obtained using JPL data
nutationAngles = earthNutation(2400000.5+jdTT);
dpsi = nutationAngles(:,1); %Nutation in Longitude
depsilon = nutationAngles(:,2); %Nutation in obliquity

%The last two terms for equation of the equinoxes are only included
%if the date is later than January 1, 1997 (MJD=50449)
omegaMoon = convang(125.04455501 - (5*360 + 134.1361851)*tTT ...
	+ 0.0020756*tTT2 + 2.139e-6*tTT3,'deg','rad');
omegaMoon(jdUT1<50449) = 0;

% Equation of the equinoxes
equinoxEq = dpsi.*cos(epsilonBar) + convang(0.00264/3600,'deg','rad')*...
	sin(omegaMoon) + convang(0.000063/3600,'deg','rad')*sin(2*omegaMoon);

% Greenwhich apparent sidereal time
thGAST = thGMST*pi/180 + equinoxEq;

% Transformation matrix for earth rotation
R = angle2dcm(thGAST,zeros(len,1),zeros(len,1));

% Adjustments to nutation angles (provided from real measurements)
dpsi = dpsi + EOP.dNut.dDpsi;
depsilon = depsilon + EOP.dNut.dDeps;

% True obliquity of ecliptic
epsilon = epsilonBar+depsilon;

% True equator to mean equinox date transformation matrix
N = angle2dcm(epsilonBar,-dpsi,-epsilon,'XZX');


%% Precession
% Zeta, theta and z represent the combined effects of general
% precession.
zeta = DEG2RAD.*((2306.2181*tTT + 0.30188*tTT2 + 0.017998*tTT3)/3600);
theta = DEG2RAD.*((2004.3109*tTT - 0.42665*tTT2 - 0.041833*tTT3)/3600);
z = DEG2RAD.*((2306.2181*tTT + 1.09468*tTT2 + 0.018203*tTT3)/3600);

% Mean equinox to celestial reference frame
P = angle2dcm(-zeta,theta,-z,'ZYZ');


%% Polar motion
W = repmat(eye(3),1,len);
W = reshape(W,3,3,len);
W(1,3,:) = EOP.pm.x;
W(3,1,:) = -EOP.pm.x;
W(2,3,:) = -EOP.pm.y;
W(3,2,:) = EOP.pm.y;

%% Matrix calculations
tmp = arrayfun(@(k) ((W(:,:,k))*R(:,:,k)*N(:,:,k)*P(:,:,k)),1:len,'UniformOutput',false);
T = reshape(cell2mat(tmp),3,3,len);

J20002ITRF.T = T;
J20002ITRF.W = W;
J20002ITRF.R = R;
J20002ITRF.Q = N*P;

end
