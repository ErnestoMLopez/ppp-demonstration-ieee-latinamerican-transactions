function datosSatelites = estimarMediciones(datosSatelites,cdtr)
%ESTIMARMEDICIONES Obtiene el valor estimado de las mediciones de cada sat�lite
%	A partir del arreglo de estructuras con los datos de los sat�lites presentes
%	y con todos los t�rminos ya modelados y completos se calcula el valor
%	estimado de cada medici�n dependiendo de que tipo de medici�n se trate, para
%	el posterior calculo de los residuos prefit.
% 
% ARGUMENTOS:
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				sat�lites presentes en la �poca actual.
%	cdtr		- Estimaci�n del sesgo de reloj del receptor por la velocidad de
%				la luz [m]
% 
% DEVOLUCI�N:
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				sat�lites presentes en la �poca actual con el campo
%				Mediciones.ValorEstimado completo para cada medici�n y cada
%				sat�lite.

global LUZ

JJ = length(datosSatelites);

for jj = 1:JJ
	
	NN = length(datosSatelites(jj).Mediciones);

	for nn = 1:NN

		clase_med = datosSatelites(jj).Mediciones(nn).Clase;
		tipo_med = datosSatelites(jj).Mediciones(nn).Tipo;

		% Si no es una medici�n de pseudorango, fases o combinaciones entonces
		% paso a la siguiente
		%TODO: Mediciones de Doppler podr�an ser incorporadas!
		if (clase_med ~= ClaseMedicion.PSEUDORANGO) && (clase_med ~= ClaseMedicion.FASE_PORTADORA) && (clase_med ~= ClaseMedicion.COMBINACION)
			continue;
		end
		
		rango							= datosSatelites(jj).Rango;
		sesgoRelojReceptor				= cdtr/LUZ;
		corrRelojSatelite				= datosSatelites(jj).Mediciones(nn).CorrRelojSatelite;
		corrRelativista					= datosSatelites(jj).Mediciones(nn).CorrRelativista;
		corrRelativistaGeneral			= datosSatelites(jj).Mediciones(nn).CorrRelativistaGeneral;
		corrTroposfera					= datosSatelites(jj).Mediciones(nn).CorrTroposfera;
		corrIonosfera					= datosSatelites(jj).Mediciones(nn).CorrIonosfera;
		corrIonosferaOrdenSup			= datosSatelites(jj).Mediciones(nn).CorrIonosferaOrdenSup;
		corrMareas						= datosSatelites(jj).Mediciones(nn).CorrMareas;
		corrWindUp						= datosSatelites(jj).Mediciones(nn).CorrWindUp;
		corrCentroFaseAntenaSatelite	= datosSatelites(jj).Mediciones(nn).CorrCentroFaseAntenaSatelite;
		corrCentroFaseAntenaReceptor	= datosSatelites(jj).Mediciones(nn).CorrCentroFaseAntenaReceptor;
		corrVariacionCentroFaseSatelite	= datosSatelites(jj).Mediciones(nn).CorrVariacionCentroFaseAntenaSatelite;
		corrVariacionCentroFaseReceptor	= datosSatelites(jj).Mediciones(nn).CorrVariacionCentroFaseAntenaReceptor;
		corrPuntoReferenciaAntena		= datosSatelites(jj).Mediciones(nn).CorrPuntoReferenciaAntena;
		

		% Armo el valor estimado de la medici�n con todos los t�rminos
		
		% Modelo para mediciones en combinaci�n libre de ion�sfera
		if (tipo_med >= TipoMedicion.PIF) && (tipo_med <= TipoMedicion.PCIF)
		
			if clase_med == ClaseMedicion.FASE_PORTADORA
				ambig	= datosSatelites(jj).Mediciones(nn).Ambig;
				if datosSatelites(jj).GNSS == SistemaGNSS.GLONASS
					lambda	= obtenerLongitudDeOnda(datosSatelites(jj).GNSS,tipo_med,datosSatelites(jj).Canal);
				else
					lambda	= obtenerLongitudDeOnda(datosSatelites(jj).GNSS,tipo_med,[]);
				end

				zk_est = rango + LUZ*(sesgoRelojReceptor - corrRelojSatelite - corrRelativista) + corrRelativistaGeneral + corrTroposfera - corrIonosferaOrdenSup + corrMareas + corrCentroFaseAntenaSatelite + corrVariacionCentroFaseSatelite + corrCentroFaseAntenaReceptor + corrVariacionCentroFaseReceptor + corrPuntoReferenciaAntena + lambda*corrWindUp + ambig;
			else
				zk_est = rango + LUZ*(sesgoRelojReceptor - corrRelojSatelite - corrRelativista) + corrRelativistaGeneral + corrTroposfera + corrIonosferaOrdenSup + corrMareas + corrCentroFaseAntenaSatelite + corrVariacionCentroFaseSatelite + corrCentroFaseAntenaReceptor + corrVariacionCentroFaseReceptor + corrPuntoReferenciaAntena;
			end
			
		%TODO: Por ahora solo se implementa el modelo para mediciones IF
		else
			zk_est = NaN;
		end
		
		% Cargo el valor estimado
		datosSatelites(jj).Mediciones(nn).ValorEstimado = zk_est;
		
	end
	
end

end