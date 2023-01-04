function [tropoCorr,Mw] = correccionTroposfera(t,r,rj,DTz)
%CORRECCIONTROPOSFERA Calcula la corrección por retardo troposférico
% Calcula el retardo troposférico en base al modelo MOPS usando el mapeo de
% Niell y DeltaTz si está disponible (estimado del filtro). De acuerdo con el 
% modelo presentado en el libro de GNSS de la ESA Vol. 1. Sección 5.4.2.2
% 
% ARGUMENTOS:
%	t			- Tiempo GPS [s]
%	r (3x1)		- Posición ECEF del receptor estimada [m]
%	rj (3x1)	- Posición ECEF del satélite j [m]
%	DTz0		- Estimación devuelta por el filtro del Kalman sobre variación 
%				en el retardo wet. Ver eq. 5.66. [m]
% 
% DEVOLUCIÓN:
%	tropoCorr	- Corrección troposférica [m]
%	Mw			- Mapeo (M(E)) utilizado para la corrección.

% ---------- Constantes ---------------------------------------------------
global TROPO_GM TROPO_G TROPO_K1 TROPO_K2 TROPO_RD TROPO_DminN TROPO_DminS TROPO_AVG TROPO_VAR TROPO_NIELL
% -------------------------------------------------------------------------    

lat_data = [15 30 45 60 75];  % los coeficientes estan tabulados para
% estas latitudes.

lla = ecef2llaGeod(r);      % para obtener latitud
lat = lla(1);

if isnan(lat)                 % por si se inicializa en (0,0,0) a r.
	tropoCorr = 0;
	Mw = NaN;
	return;
end

% segun norte o sur elijo el Dmin
if lat >= 0
	Dmin = TROPO_DminN; % T0 = 28
else
	Dmin = TROPO_DminS; % T0 = 211
end

lat = abs(lat);   % me quedo con el módulo de la latitud

%switch para elegir los parametros de las matrices con coeficientes
if lat <= 15
	indx = 1;
end
if ((lat > 15) && (lat <= 30))
	indx = 2;
end
if ((lat > 30) && (lat <= 45))
	indx = 3;
end
if ((lat > 45) && (lat <= 60))
	indx = 4;
end
if ((lat > 60) && (lat < 75))
	indx = 5;
end
if lat >= 75
	indx = 5;
end

if (lat <= 15 || lat >= 75)
	lat_norm = lat_data(indx);
	pteblavg = TROPO_AVG(:,indx);
	pteblvar = TROPO_VAR(:,indx);
	abc_dry = TROPO_NIELL(1:9,indx);
	abc_wet = TROPO_NIELL(10:12,indx);
else
	lat_norm = (lat - lat_data(indx-1)) / (lat_data(indx) - lat_data(indx-1));
	pteblavg = TROPO_AVG(:,indx-1) + (TROPO_AVG(:,indx) - TROPO_AVG(:,indx-1))*lat_norm;
	pteblvar = TROPO_VAR(:,indx-1) + (TROPO_VAR(:,indx) - TROPO_VAR(:,indx-1))*lat_norm;
	abc_dry = TROPO_NIELL(1:9,indx-1) + (TROPO_NIELL(1:9,indx) - TROPO_NIELL(1:9,indx-1))*lat_norm;
	abc_wet = TROPO_NIELL(10:12,indx-1) + (TROPO_NIELL(10:12,indx) - TROPO_NIELL(10:12,indx-1))*lat_norm;
end

% calculo para el dia particular (formulas 5.62 y 5.70 ESA GNSS Vol 1 )
doy = gpsTime2doy(t);
ptebl = pteblavg - pteblvar .* cos((doy - Dmin)*2*pi/365.25);
abcd = abc_dry(1:3) - abc_dry(4:6) .* cos((doy - 1 - Dmin)*2*pi/365.25);

% retardos para altitud cero
Trz0d = 1e-6*TROPO_K1*TROPO_RD*ptebl(1)/TROPO_GM;
Trz0w = (1e-6*TROPO_K2*TROPO_RD*ptebl(3))/(((ptebl(5) + 1)*TROPO_GM - ptebl(4)*TROPO_RD)*ptebl(2));

% Sanity check: The result of the calculus Beta*Height/Temperature must be under 1
H = lla(3);  % OJO!!! POR AHORA USO LA ALTURA ECEF....HAY QUE USAR SOBRE NIVEL DEL MAR
factor = ptebl(4)*H/ptebl(2);

if factor < 1
	Trzd = Trz0d*(1-factor).^(TROPO_G/(TROPO_RD*ptebl(4)));
	Trzw = Trz0w*(1-factor).^((ptebl(5)+1)*TROPO_G/(TROPO_RD*ptebl(4))-1);
else
	Trzd = 0;
	Trzw = 0;
end

aer = ecefdif2aer(rj,r);
E   = aer(2);

Md  = mapeoMariniNormalizado(E,abcd(1),abcd(2),abcd(3)) + ...
	(1/sind(E) - mapeoMariniNormalizado(E,abc_dry(7),abc_dry(8),abc_dry(9)))*(H/1000);
Mw  = mapeoMariniNormalizado(E,abc_wet(1),abc_wet(2),abc_wet(3));

tropoCorr = Trzd*Md + (Trzw + DTz)*Mw;

end


%-------------------------------------------------------------------------------
function MN =  mapeoMariniNormalizado(E,a,b,c)
    MN = (1 + a/(1 + b/(1 + c)))/(sind(E) + a/(sind(E) + b/(sind(E) + c)));
end
%-------------------------------------------------------------------------------