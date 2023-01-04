function datosSatelites = estimarMediciones(datosSatelites,cdtr)
%ESTIMARMEDICIONES Obtiene el valor estimado de las mediciones de cada satélite
%	A partir del arreglo de estructuras con los datos de los satélites presentes
%	y con todos los términos ya modelados y completos se calcula el valor
%	estimado de cada medición dependiendo de que tipo de medición se trate, para
%	el posterior calculo de los residuos prefit.
% 
% ARGUMENTOS:
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				satélites presentes en la época actual.
%	cdtr		- Estimación del sesgo de reloj del receptor por la velocidad de
%				la luz [m]
% 
% DEVOLUCIÓN:
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				satélites presentes en la época actual con el campo
%				Mediciones.ValorEstimado completo para cada medición y cada
%				satélite.

global LUZ

JJ = length(datosSatelites);

for jj = 1:JJ
	
	NN = length(datosSatelites(jj).Mediciones);

	for nn = 1:NN

		clase_med = datosSatelites(jj).Mediciones(nn).Clase;
		tipo_med = datosSatelites(jj).Mediciones(nn).Tipo;

		% Si no es una medición de pseudorango, fases o combinaciones entonces
		% paso a la siguiente
		%TODO: Mediciones de Doppler podrían ser incorporadas!
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
		

		% Armo el valor estimado de la medición con todos los términos
		
		% Modelo para mediciones en combinación libre de ionósfera
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