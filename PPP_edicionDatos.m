function datosSatelites = PPP_edicionDatos(datosSatelites,datosSatelitesPrevios,r,DZTDw,configPPP)

%----- Enmascaro por elevación -------------------------------------------------
if configPPP.FLAG_MASCARA_ELEVACION
	datosSatelites = enmascararPorElevacion(datosSatelites,configPPP);
end
%-------------------------------------------------------------------------------

%----- Descarto satélites en eclipse hace menos de 30 mintutos -----------------
if configPPP.FLAG_SATELITES_ECLIPSE
	datosSatelites = enmascararPorEclipses(datosSatelites,configPPP);
end
%-------------------------------------------------------------------------------

%----- Descarto mediciones por baja SNR ----------------------------------------
if configPPP.FLAG_UMBRAL_SNR
	datosSatelites = enmascararPorSNR(datosSatelites,configPPP);	
end
%-------------------------------------------------------------------------------

%----- Descarto mediciones por salto de ciclo-----------------------------------
if configPPP.FLAG_SALTO_CICLO
	datosSatelites = enmascararPorSaltoDeCiclo(datosSatelites,datosSatelitesPrevios,configPPP);	
end
%-------------------------------------------------------------------------------

end








%-------------------------------------------------------------------------------
function datosSatelites = enmascararPorElevacion(datosSatelites,configPPP)

JJ = length(datosSatelites);

for jj = 1:JJ
	if datosSatelites(jj).Elev < configPPP.MASCARA_ELEVACION
		datosSatelites(jj).Usable = false;
	end
end

end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function datosSatelites = enmascararPorEclipses(datosSatelites,configPPP)

JJ = length(datosSatelites);

for jj = 1:JJ
	if ~datosSatelites(jj).Usable || any(isnan(datosSatelites(jj).tEclipse))
		continue;
	end
	% Calculo el tiempo transcurrido desde el último eclipse detectado
	dt = datosSatelites(jj).tT - datosSatelites(jj).tEclipse;
	if dt < 1800
		datosSatelites(jj).Usable = false;
	end
end

end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function datosSatelites = enmascararPorSNR(datosSatelites,configPPP)

JJ = length(datosSatelites);
MM = length(configPPP.MEDICIONES);

for jj = 1:JJ
	
	if ~datosSatelites(jj).Usable
		continue;
	end
	
	NN = length(datosSatelites(jj).Mediciones);
		
	for nn = 1:NN
		
		if datosSatelites(jj).Mediciones(nn).Clase ~= ClaseMedicion.CN0 || ~datosSatelites(jj).Mediciones(nn).Usable
			continue;
		end
		
		SNR = datosSatelites(jj).Mediciones(nn).Valor;
		
		if SNR < configPPP.UMBRAL_SNR
			
			codigo = char(datosSatelites(jj).Mediciones(nn).Tipo);
			
			for mm = 1:MM
				codigo_med = char(configPPP.MEDICIONES(mm));
				
				flag_es_mismo_tracking = all(codigo(2:3) == codigo_med(2:3));
				flag_es_combinacionIF = configPPP.MEDICIONES(mm) == TipoMedicion.PIF || configPPP.MEDICIONES(mm) == TipoMedicion.PCIF || configPPP.MEDICIONES(mm) == TipoMedicion.LIF;
				flag_es_L1oL2 = codigo(2) == '1' || codigo(2) == '2';
				
				if  flag_es_mismo_tracking || (flag_es_combinacionIF && flag_es_L1oL2)
					mmsnr = [datosSatelites(jj).Mediciones.Tipo] == configPPP.MEDICIONES(mm);
					
					datosSatelites(jj).Mediciones(mmsnr).Usable = false;
				end
				
			end
			
		end
		
	end
	
end



end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function datosSatelites = enmascararPorSaltoDeCiclo(datosSatelites,datosSatelitesPrevios,configPPP)

JJ = length(datosSatelites);

for jj = 1:JJ
	
	if ~datosSatelites(jj).Usable
		continue;
	end
	
	NN = length(datosSatelites(jj).Mediciones);
		
	for nn = 1:NN

		% si no es del tipo LGF o si no esta usable, continuo con el siguiente nn.
		if datosSatelites(jj).Mediciones(nn).Tipo ~= TipoMedicion.LGF || ~datosSatelites(jj).Mediciones(nn).Usable
			continue;
		end

		% Verifico si el satélite estaba presente en la época previa
		jjprev = find(	([datosSatelitesPrevios.PRN] == datosSatelites(jj).PRN) & ...
						([datosSatelitesPrevios.GNSS] == datosSatelites(jj).GNSS) & ...
						([datosSatelitesPrevios.Usable] == datosSatelites(jj).Usable));

		% si en la época anterior la medicion no era usable, hubo salto de ciclo
		% y entonces el satélite actual no se utiliza.	
		if isempty(jjprev)
			datosSatelites(jj).Mediciones(nn).Usable = false;
			continue;
		end
		% si está la medición y también en la época anterior, entonces detecto a ver si hay salto de ciclo.
		combact = datosSatelites(jj).Mediciones(nn).Valor;
		combant = datosSatelitesPrevios(jjprev).Mediciones(nn).Valor;
		% valor a comparar con el umbral
		d = combact - combant;
		% El umbral puede pasarse dentro de configPPP. El libro de la ESA 
		% recomienda que el umbral dependa del tiempo de muestreo 
		% a0*(1 - exp(-(Ts/T0)/2)) con a0 = 3/2(Lambda2 - Lambda 1)
		if abs(d) > configPPP.UMBRAL_SALTO_CICLO_LGF
			indx = find([datosSatelites(jj).Mediciones.Clase] == ClaseMedicion.FASE_PORTADORA);
			for ii = 1:length(indx)
				datosSatelites(jj).Mediciones(indx(ii)).Usable = false;
			end
		end

	end

end

end