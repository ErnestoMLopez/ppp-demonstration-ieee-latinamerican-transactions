function [ps,vs,healthy] = calcularEstadoSateliteGps_RINEX_NAV(t,PRN,datosRINEX_NAV)
%CALCULARESTADOSATELITEGPS_RINEX_NAV C�mputo del estado de un sat�lite GPS (marco ECEF)
% A partir de las efem�rides provistas en el mensaje de navegaci�n la funci�n
% devuelve la posici�n y velocidad del sat�lite pedido (solo uno) en marco ECEF.
%
% Todos los �ngulos usados dentro de la funci�n est�n
% expresados en radianes.
%
% ARGUMENTOS:
%	t				- Tiempo GPS para el que se quiere calcular la posici�n.
%	PRN				- PRN del sat�lite del que se desea calcular su posici�n
%	datosRINEX_NAV	- Estructura de datos del mensaje de navegaci�n provista 
%					por la funci�n leerArchivoRINEX_NAV.
%
% DEVOLUCI�N:
%	ps (3x1)		- Posici�n en el marco ECEF para el tiempo GPS dado [m]
%	vs (3x1)		- Velocidad en el marco ECEF para el tiempo GPS dado [m/s]
%	healthy			- Indicador de validez (1) o no (0) del sat�lite


%==========================================================================
% Constantes
%==========================================================================
MUE = 3.986005E14;		% Par�metro gravitacional GM de la Tierra [m^3/s^2] (WGS-84 seg�n ICD GPS)
WE	= 7.2921151467e-5;	% Velocidad angular de rotaci�n terrestre [rad/s] (WGS-84)

%==========================================================================
% Inicializaci�n variables de salida
%==========================================================================
ps		= NaN(3,1);
vs		= NaN(3,1); 
healthy	= false;

%==========================================================================
% Inicio lazo principal de c�lculos
%==========================================================================

% Busco las efem�rides con el PRN deseado de GPS
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
	
	% Si el tiempo es posterior al tiempo de transmisi�n de las efem�rides
	% (diffttrans > 0), entonces no deber�a usarlas pensando en que a�n no 
	% fueron recibidas. Sin embargo, pedir esto y adem�s que el tiempo est� 
	% dentro del intervalo de validez de las efem�rides puede llegar a ser muy 
	% restrictivo (caso emp�rico con un archivo BRDC, no de una estaci�n) as� 
	% que solo pido lo segundo y que al menos dtoe sea negativo
	if difftoe > 0 || difftoe > difftvalidez || difftoe < -difftvalidez
		ephvalid = false;
	else
		ephvalid = true;
		break;
	end
end

% Si no encontr� ninguna efem�rides v�lida salgo
if ~ephvalid
	return;
end


% Reduzco el conjunto de estructuras de efemerides a las del sat�lite 
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
	
	
% Par�metros derivados
[~,toetow] = gpsTime2gpsWeekTOW(toe);	% Time of ephemeris en TOW
dt	= t - toe;							% Diferencia entre el toe y la �poca
a	= sqrt_a.^2;						% Semieje mayor [m]
n0	= sqrt(MUE/a^3);					% Movimiento medio nominal [rad/s]
n	= n0 + Delta_n;						% Movimiento medio corregido
M	= M0 + n*dt;						% Anomal�a media
E	= kepler_E(ecc, M);					% Anomal�a exc�ntrica
cosE	= cos(E);
sinE	= sin(E);
E_dot	= n / (1-ecc*cosE);

nu		= atan2(sqrt(1 - ecc.^2).*sinE, cosE-ecc);% Anomal�a verdadera
cosnu	= cos(nu);
sinnu	= sin(nu);

phi			= nu + omega;						% Argumento de la altitud
delta_phi	= Cus*sin(2*phi) + Cuc*cos(2*phi);	% Correcci�n argumento de la latitud
delta_r		= Crs*sin(2*phi) + Crc*cos(2*phi);	% Correcci�n radio
delta_i		= Cis*sin(2*phi) + Cic*cos(2*phi);	% Correcci�n inclinaci�n

u	= phi + delta_phi;
r	= a*(1-ecc*cosE) + delta_r;
inc = i0 + delta_i + i_DOT*dt;

cosu = cos(u);  cos2u = cos(2*u);
sinu = sin(u);  sin2u = sin(2*u);

% Tasa de cambio de la anomal�a verdadera, argumento de la latitud,
% radio e inclinaci�n
nu_dot	= sinE*E_dot*(1+ecc*cosnu) / (sinnu*(1-ecc*cosE));
u_dot	= nu_dot + 2*(Cus*cos2u-Cuc*sin2u)*nu_dot;
r_dot	= a*ecc*sinE*n/(1-ecc*cosE) + 2*(Crs*cos2u-Crc*sin2u)*nu_dot;
inc_dot = i_DOT + 2*(Cis*cos2u-Cic*sin2u)*nu_dot;

% Ascensi�n recta del nodo ascendente y su tasa de cambio
node = OMEGA0 + (OMEGA_DOT-WE)*dt - (WE*toetow);
node_dot = OMEGA_DOT - WE;

cosi = cos(inc);	sini = sin(inc);
coso = cos(node);	sino = sin(node);

% C�lculo de la posici�n y velocidad
xo = r * cosu;						% Posici�n x en el plano oribital
yo = r * sinu;						% Posici�n y en el plano oribital

xo_dot = r_dot*cosu - yo*u_dot;		% Velocidad x en el plano
yo_dot = r_dot*sinu + xo*u_dot;		% Velocidad y en el plano

ps(1) = xo*coso - yo*cosi*sino;		% Posici�n en x
ps(2) = xo*sino + yo*cosi*coso;		% Posici�n en y
ps(3) = yo*sini;					% Posici�n en x

vs(1) = (xo_dot - yo*cosi*node_dot)*coso - ...
		(xo*node_dot + yo_dot*cosi - yo*sini*inc_dot)*sino;
vs(2) = (xo_dot - yo*cosi*node_dot)*sino + ...
		(xo*node_dot + yo_dot*cosi - yo*sini*inc_dot)*coso;
vs(3) = yo_dot*sini + yo*cosi*inc_dot;

% Indicador health del sat�lite
if health == 0
	healthy = true;
else
	healthy = false;
end

end



