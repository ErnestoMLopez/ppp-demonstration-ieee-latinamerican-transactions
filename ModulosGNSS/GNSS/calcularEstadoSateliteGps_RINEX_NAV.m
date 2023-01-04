function [ps,vs,healthy] = calcularEstadoSateliteGps_RINEX_NAV(t,PRN,datosRINEX_NAV)
%CALCULARESTADOSATELITEGPS_RINEX_NAV Cómputo del estado de un satélite GPS (marco ECEF)
% A partir de las efemérides provistas en el mensaje de navegación la función
% devuelve la posición y velocidad del satélite pedido (solo uno) en marco ECEF.
%
% Todos los ángulos usados dentro de la función están
% expresados en radianes.
%
% ARGUMENTOS:
%	t				- Tiempo GPS para el que se quiere calcular la posición.
%	PRN				- PRN del satélite del que se desea calcular su posición
%	datosRINEX_NAV	- Estructura de datos del mensaje de navegación provista 
%					por la función leerArchivoRINEX_NAV.
%
% DEVOLUCIóN:
%	ps (3x1)		- Posición en el marco ECEF para el tiempo GPS dado [m]
%	vs (3x1)		- Velocidad en el marco ECEF para el tiempo GPS dado [m/s]
%	healthy			- Indicador de validez (1) o no (0) del satélite


%==========================================================================
% Constantes
%==========================================================================
MUE = 3.986005E14;		% Parámetro gravitacional GM de la Tierra [m^3/s^2] (WGS-84 según ICD GPS)
WE	= 7.2921151467e-5;	% Velocidad angular de rotación terrestre [rad/s] (WGS-84)

%==========================================================================
% Inicialización variables de salida
%==========================================================================
ps		= NaN(3,1);
vs		= NaN(3,1); 
healthy	= false;

%==========================================================================
% Inicio lazo principal de cálculos
%==========================================================================

% Busco las efemérides con el PRN deseado de GPS
PRNs = [datosRINEX_NAV.gpsEph.PRN]';
indx = (PRNs == PRN);

if ~any(indx)
	fprintf('No se encuentra el satelite buscado: PRN = %d\n', PRN)
	return;					% Si no se encuentra nada retorna NaNs
end	

datosEphPRN = datosRINEX_NAV.gpsEph(indx);

% ToMs = [datosEphPRN.ttom]';
ToEs = [datosEphPRN.toe]';
FitInts = [datosEphPRN.FitInterval]';

EE = length(ToEs);

for ee = 1:EE
% 	diffttrans = t - datosEphPRN(ee).ttom;
	difftoe = t - ToEs(ee);
	difftvalidez = 0.5*3600*FitInts(ee);
	
	% Si el tiempo es posterior al tiempo de transmisión de las efemérides
	% (diffttrans > 0), entonces no debería usarlas pensando en que aún no 
	% fueron recibidas. Sin embargo, pedir esto y además que el tiempo esté 
	% dentro del intervalo de validez de las efemérides puede llegar a ser muy 
	% restrictivo (caso empírico con un archivo BRDC, no de una estación) así 
	% que solo pido lo segundo y que al menos dtoe sea negativo
	if difftoe > 0 || difftoe > difftvalidez || difftoe < -difftvalidez
		ephvalid = false;
	else
		ephvalid = true;
		break;
	end
end

% Si no encontré ninguna efemérides válida salgo
if ~ephvalid
	return;
end


% Reduzco el conjunto de estructuras de efemerides a las del satélite 
toe			= datosEphPRN(ee).toe;
sqrt_a		= datosEphPRN(ee).sqrt_a;
ecc			= datosEphPRN(ee).e;
i0			= datosEphPRN(ee).i0;
OMEGA0		= datosEphPRN(ee).OMEGA0;
omega		= datosEphPRN(ee).omega;
M0			= datosEphPRN(ee).M0;
i_DOT		= datosEphPRN(ee).i_DOT;
OMEGA_DOT	= datosEphPRN(ee).OMEGA_DOT;
Delta_n		= datosEphPRN(ee).Delta_n;
Cuc			= datosEphPRN(ee).Cuc;
Cus			= datosEphPRN(ee).Cus;
Crc			= datosEphPRN(ee).Crc;
Crs			= datosEphPRN(ee).Crs;
Cic			= datosEphPRN(ee).Cic;
Cis			= datosEphPRN(ee).Cis;
health		= datosEphPRN(ee).Health;
	
	
% Parámetros derivados
[~,toetow] = gpsTime2gpsWeekTOW(toe);	% Time of ephemeris en TOW
dt	= t - toe;							% Diferencia entre el toe y la época
a	= sqrt_a.^2;						% Semieje mayor [m]
n0	= sqrt(MUE/a^3);					% Movimiento medio nominal [rad/s]
n	= n0 + Delta_n;						% Movimiento medio corregido
M	= M0 + n*dt;						% Anomalía media
E	= kepler_E(ecc, M);					% Anomalía excéntrica
cosE	= cos(E);
sinE	= sin(E);
E_dot	= n / (1-ecc*cosE);

nu		= atan2(sqrt(1 - ecc.^2).*sinE, cosE-ecc);% Anomalía verdadera
cosnu	= cos(nu);
sinnu	= sin(nu);

phi			= nu + omega;						% Argumento de la altitud
delta_phi	= Cus*sin(2*phi) + Cuc*cos(2*phi);	% Corrección argumento de la latitud
delta_r		= Crs*sin(2*phi) + Crc*cos(2*phi);	% Corrección radio
delta_i		= Cis*sin(2*phi) + Cic*cos(2*phi);	% Corrección inclinación

u	= phi + delta_phi;
r	= a*(1-ecc*cosE) + delta_r;
inc = i0 + delta_i + i_DOT*dt;

cosu = cos(u);  cos2u = cos(2*u);
sinu = sin(u);  sin2u = sin(2*u);

% Tasa de cambio de la anomalía verdadera, argumento de la latitud,
% radio e inclinación
nu_dot	= sinE*E_dot*(1+ecc*cosnu) / (sinnu*(1-ecc*cosE));
u_dot	= nu_dot + 2*(Cus*cos2u-Cuc*sin2u)*nu_dot;
r_dot	= a*ecc*sinE*n/(1-ecc*cosE) + 2*(Crs*cos2u-Crc*sin2u)*nu_dot;
inc_dot = i_DOT + 2*(Cis*cos2u-Cic*sin2u)*nu_dot;

% Ascensión recta del nodo ascendente y su tasa de cambio
node = OMEGA0 + (OMEGA_DOT-WE)*dt - (WE*toetow);
node_dot = OMEGA_DOT - WE;

cosi = cos(inc);	sini = sin(inc);
coso = cos(node);	sino = sin(node);

% Cálculo de la posición y velocidad
xo = r * cosu;						% Posición x en el plano oribital
yo = r * sinu;						% Posición y en el plano oribital

xo_dot = r_dot*cosu - yo*u_dot;		% Velocidad x en el plano
yo_dot = r_dot*sinu + xo*u_dot;		% Velocidad y en el plano

ps(1) = xo*coso - yo*cosi*sino;		% Posición en x
ps(2) = xo*sino + yo*cosi*coso;		% Posición en y
ps(3) = yo*sini;					% Posición en x

vs(1) = (xo_dot - yo*cosi*node_dot)*coso - ...
		(xo*node_dot + yo_dot*cosi - yo*sini*inc_dot)*sino;
vs(2) = (xo_dot - yo*cosi*node_dot)*sino + ...
		(xo*node_dot + yo_dot*cosi - yo*sini*inc_dot)*coso;
vs(3) = yo_dot*sini + yo*cosi*inc_dot;

% Indicador health del satélite
if health == 0
	healthy = true;
else
	healthy = false;
end

end



