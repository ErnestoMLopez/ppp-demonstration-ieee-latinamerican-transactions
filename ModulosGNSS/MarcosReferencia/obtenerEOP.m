function EOP = obtenerEOP(jd,datosEOPoERP)
%OBTENEREOP Extrae los EOP de la época dada
% Devuelve los parámetros de orientación de la Tierra para la época especificada
% necesarios para el cómputo de correcciones de mediciones o para la 
% transformación ECI/ECEF. Esta función acepta productos EOP, obtenidos a través
% del IERS y que proporcionan todos los elementos para la transformación
% ICRF/ITRF completa mediante la teoría IAU-2000/2006A, o productos ERP,
% provistos por el IGS, los cuales representan un subconjunto de los EOP. Estos
% son utilizados por ejemplo en procesamiento en tiempo real mediante los
% productos ultra-rapid. En caso de proporcionarse ERPs se completa el resto de
% los campos de los EOP con ceros.
% 
% ARGUMENTOS:
%	jd				- Fecha juliana UTC [JD]
%	datosEOPoERP 	- Estructura que contiene una matriz de ERP de (Mx19) 
%					(puede contener menos, mínimo 12) obtenida mediante
%					leerArchivoERP, o estructura con una matriz de EOP de
%					(MMx13) obtenida mediante leerArchivoEOP
%
% DEVOLUCIÓN:
%	EOP				- Estructura con los siguentes campos:
%		dTA 		- Diferencia TAI-UTC [s]
%		dUT1		- Diferencia UT1-UTC [s]
%		LOD			- Length of day (exceso de duración del día) [s] 
%		pm			- Movimiento del polo, estructura de campos:	
%			pm.x [rad]
%			pm.y [rad]
%		dCIP		- Corrección del Polo Intermedio Celeste (CIP) 
%					(teoría IAU 2006), estructura de campos:
%			dCIP.dX [rad]
%			dCIP.dY [rad]
%		dNut		- Corrección de los ángulos de nutación (teoría 
%					IAU 1980), estructura de campos:
%			dNut.dDeps [rad]
%			dNut.dDpsi [rad]

persistent jdprevio;
persistent EOPprevio;

if isempty(jdprevio)
	jdprevio = 0;
end

if jd == jdprevio
	EOP = EOPprevio;	
	return;
end


datos = datosEOPoERP.data;
MM = size(datos,1);

mjd = jd - 2400000.5;

% Inicializo la estructura de salida
EOP = struct('dAT',0, ...
			'dUT1',0, ...
			'LOD',0, ...
			'pm', struct('x',0,'y',0), ...
			'dNut', struct('dDeps',0,'dDpsi',0), ...
			'dCIP', struct('dX',0,'dY',0) ...
			);
		
		
if strcmp(datosEOPoERP.Producto,'ERP')
		
	dt_ERP = mjd - datos(:,1);
	[~,kk] = min(abs(dt_ERP));
	delta_t = dt_ERP(kk);
	
	if (delta_t > 0) && (kk < MM)
		
		t_central = datos(kk,1);
		t_sig = datos(kk+1,1);
		
		% Pendientes de las rectas de interpolación
		m_dUT1	= ((datos(kk+1,4) - datos(kk,4)) / (t_sig - t_central));
		m_LOD	= ((datos(kk+1,5) - datos(kk,5)) / (t_sig - t_central));
		m_pmx	= ((datos(kk+1,2) - datos(kk,2)) / (t_sig - t_central));
		m_pmy	= ((datos(kk+1,3) - datos(kk,3)) / (t_sig - t_central));
		
		EOP.dUT1	= (datos(kk,4) + m_dUT1*delta_t)*1E-7;
		EOP.LOD		= (datos(kk,5) + m_LOD*delta_t)*1E-7;
		EOP.pm.x	= arcsec2rad((datos(kk,2) + m_pmx*delta_t)*1E-6);
		EOP.pm.y	= arcsec2rad((datos(kk,3) + m_pmy*delta_t)*1E-6);
		
	elseif (delta_t < 0) && (kk > 1)
		
		t_central = datos(kk,1);
		t_ant = datos(kk-1,1);
		
		m_dUT1	= ((datos(kk,4) - datos(kk-1,4)) / (t_central - t_ant));
		m_LOD	= ((datos(kk,5) - datos(kk-1,5)) / (t_central - t_ant));
		m_pmx	= ((datos(kk,2) - datos(kk-1,2)) / (t_central - t_ant));
		m_pmy	= ((datos(kk,3) - datos(kk-1,3)) / (t_central - t_ant));
		
		EOP.dUT1	= (datos(kk,4) + m_dUT1*delta_t)*1E-7;
		EOP.LOD		= (datos(kk,5) + m_LOD*delta_t)*1E-7;
		EOP.pm.x	= arcsec2rad((datos(kk,2) + m_pmx*delta_t)*1E-6);
		EOP.pm.y	= arcsec2rad((datos(kk,3) + m_pmy*delta_t)*1E-6);
		
	elseif (delta_t == 0) || ((delta_t < 0) && (kk == 1)) || ((delta_t > 0) && (kk == MM))
		
		EOP.dUT1	= datos(kk,4)*1E-7;
		EOP.LOD		= datos(kk,5)*1E-7;
		EOP.pm.x	= arcsec2rad(datos(kk,2)*1E-6);
		EOP.pm.y	= arcsec2rad(datos(kk,3)*1E-6);
		
	end

elseif strcmp(datosEOPoERP.Producto,'EOP')
	
	dt_EOP = mjd - datos(:,4);
	[~,kk] = min(abs(dt_EOP));
	delta_t = dt_EOP(kk);
	
	if (delta_t > 0) && (kk < MM)
		
		t_central = datos(kk,4);
		t_sig = datos(kk+1,4);
		
		% Pendiente de las rectas de interpolación
		m_dAT		= ((datos(kk+1,13) - datos(kk,13)) / (t_sig - t_central));
		m_dUT1		= ((datos(kk+1,7 ) - datos(kk,7 )) / (t_sig - t_central));
		m_LOD		= ((datos(kk+1,8 ) - datos(kk,8 )) / (t_sig - t_central));
		m_pmx		= ((datos(kk+1,5 ) - datos(kk,5 )) / (t_sig - t_central));
		m_pmy		= ((datos(kk+1,6 ) - datos(kk,6 )) / (t_sig - t_central));
		m_dNutdDeps = ((datos(kk+1,9 ) - datos(kk,9 )) / (t_sig - t_central));
		m_dNutdDpsi = ((datos(kk+1,10) - datos(kk,10)) / (t_sig - t_central));
		m_dCIPdX	= ((datos(kk+1,11) - datos(kk,11)) / (t_sig - t_central));
		m_dCIPdY	= ((datos(kk+1,12) - datos(kk,12)) / (t_sig - t_central));
		
		EOP.dAT			= (datos(kk,13) + m_dAT*delta_t);
		EOP.dUT1		= (datos(kk,7) + m_dUT1*delta_t);
		EOP.LOD			= (datos(kk,8) + m_LOD*delta_t);
		EOP.pm.x		= arcsec2rad(datos(kk,5) + m_pmx*delta_t);
		EOP.pm.y		= arcsec2rad(datos(kk,6) + m_pmy*delta_t);
		EOP.dNut.dDeps	= arcsec2rad(datos(kk,9) + m_dNutdDeps*delta_t);
		EOP.dNut.dDpsi	= arcsec2rad(datos(kk,10) + m_dNutdDpsi*delta_t);
		EOP.dCIP.dX		= arcsec2rad(datos(kk,11) + m_dCIPdX*delta_t);
		EOP.dCIP.dY		= arcsec2rad(datos(kk,12) + m_dCIPdY*delta_t);

	elseif (delta_t < 0) && (kk > 1)
		
		t_central = datos(kk,4);
		t_ant = datos(kk-1,4);
		
		% Pendiente de las rectas de interpolación
		m_dAT		= ((datos(kk,13) - datos(kk-1,13)) / (t_central - t_ant));
		m_dUT1		= ((datos(kk,7 ) - datos(kk-1,7 )) / (t_central - t_ant));
		m_LOD		= ((datos(kk,8 ) - datos(kk-1,8 )) / (t_central - t_ant));
		m_pmx		= ((datos(kk,5 ) - datos(kk-1,5 )) / (t_central - t_ant));
		m_pmy		= ((datos(kk,6 ) - datos(kk-1,6 )) / (t_central - t_ant));
		m_dNutdDeps = ((datos(kk,9 ) - datos(kk-1,9 )) / (t_central - t_ant));
		m_dNutdDpsi = ((datos(kk,10) - datos(kk-1,10)) / (t_central - t_ant));
		m_dCIPdX	= ((datos(kk,11) - datos(kk-1,11)) / (t_central - t_ant));
		m_dCIPdY	= ((datos(kk,12) - datos(kk-1,12)) / (t_central - t_ant));
		
		EOP.dAT			= (datos(kk,13) + m_dAT*delta_t);
		EOP.dUT1		= (datos(kk,7) + m_dUT1*delta_t);
		EOP.LOD			= (datos(kk,8) + m_LOD*delta_t);
		EOP.pm.x		= arcsec2rad(datos(kk,5) + m_pmx*delta_t);
		EOP.pm.y		= arcsec2rad(datos(kk,6) + m_pmy*delta_t);
		EOP.dNut.dDeps	= arcsec2rad(datos(kk,9) + m_dNutdDeps*delta_t);
		EOP.dNut.dDpsi	= arcsec2rad(datos(kk,10) + m_dNutdDpsi*delta_t);
		EOP.dCIP.dX		= arcsec2rad(datos(kk,11) + m_dCIPdX*delta_t);
		EOP.dCIP.dY		= arcsec2rad(datos(kk,12) + m_dCIPdY*delta_t);
		
	elseif (delta_t == 0) || ((delta_t < 0) && (kk == 1)) || ((delta_t > 0) && (kk == MM))
		
		EOP.dAT			= datos(kk,13);
		EOP.dUT1		= datos(kk,7);
		EOP.LOD			= datos(kk,8);
		EOP.pm.x		= arcsec2rad(datos(kk,5));
		EOP.pm.y		= arcsec2rad(datos(kk,6));
		EOP.dNut.dDeps	= arcsec2rad(datos(kk,9));
		EOP.dNut.dDpsi	= arcsec2rad(datos(kk,10));
		EOP.dCIP.dX		= arcsec2rad(datos(kk,11));
		EOP.dCIP.dY		= arcsec2rad(datos(kk,12));
		
	end
	
end


% Guardo la salida en la variable persistente
jdprevio = jd;
EOPprevio = EOP;

end
