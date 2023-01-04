function datosObsRNX = verificarObservablesyCombinaciones(datosObsRNX,GNSSs,tipo_med)
%VERIFICAROBSERVABLESYCOMBINACIONES Verifica la existencia de los observables
%y/o combinaciones de observables pedidos para el procesamiento. En caso de
%requerirse combinaciones y disponerse de los observables adecuados estas se
%calculan (ATENCIÓN: por el momento solo soporta combinación libre de ionósfera
%de pseudorangos y fases de portadora)
% 
% ARGUMENTOS:
%	datosObsRNX		- Estructura de datos obtenida de la lectura de un archivo 
%					RINEX de observables.
%	GNSSs (SSx1)	- Arreglo de objetos clase SistemaGNSS
%	tipo_med (NNx1)	- Arreglo de objetos clase TipoMedicion
% 
% DEVOLUCIÓN:
%	datosObsRNX		- Estructura de datos obtenida de la lectura de un archivo 
%					RINEX de observables con el agregado de las combinaciones de
%					observables requerida.


global IFC_A1 IFC_A2 NLC_A1 NLC_A2 WLC_A1 WLC_A2 MPC1_A1 MPC1_A2 MPC2_A1 MPC2_A2

NSIS = length(GNSSs);

for ss = 1:NSIS
	
	flag_gnss_presente = any(datosObsRNX.GNSS == GNSSs(ss));
	if ~flag_gnss_presente
		error('ERROR! Sistema GNSS no presente...');
	end
	
	gnss_field = sistemaGNSS2stringEstructura(GNSSs(ss));
	NOBS = length(tipo_med);
	
	for nn = 1:NOBS
		% Si no se piden combinaciones busco que estén
		if tipo_med(nn) < TipoMedicion.PNL
			flag_med_presente = any(datosObsRNX.(gnss_field).Observables == tipo_med(nn));
			
			if ~flag_med_presente
				error('ERROR! Tipo de medición no presente...');
			end
			
			continue;
		end
		
		% Si se piden combinaciones éstas dependen del sistema que se esté
		% utilizando. (Por ahora solo hay combinaciones para GPS)
		
		if GNSSs(ss) == SistemaGNSS.GPS
			
%------ Combinación libre de ionósfera de pseudorangos GPS P L1-L2 -------------
			if tipo_med(nn) == TipoMedicion.PIF
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				
				if flag_C1P_presente && flag_C2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PIF];
					datosObsRNX.(gnss_field).PIF = datosObsRNX.(gnss_field).C1P;
					datosObsRNX.(gnss_field).PIF.Valor = IFC_A1.*datosObsRNX.(gnss_field).C1P.Valor + IFC_A2.*datosObsRNX.(gnss_field).C2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación libre de ionósfera de pseudorangos GPS C/A P L1-L2 ---------
			elseif tipo_med(nn) == TipoMedicion.PCIF
				flag_C1C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1C);
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				
				if flag_C1C_presente && flag_C2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PCIF];
					datosObsRNX.(gnss_field).PCIF = datosObsRNX.(gnss_field).C1C;
					datosObsRNX.(gnss_field).PCIF.Valor = IFC_A1.*datosObsRNX.(gnss_field).C1C.Valor + IFC_A2.*datosObsRNX.(gnss_field).C2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación libre de ionósfera de fases de portadora GPS L1-L2 ---------
			elseif tipo_med(nn) == TipoMedicion.LIF
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if flag_L1P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.LIF];
					datosObsRNX.(gnss_field).LIF = datosObsRNX.(gnss_field).L1P;
					datosObsRNX.(gnss_field).LIF.Valor = IFC_A1.*datosObsRNX.(gnss_field).L1P.Valor + IFC_A2.*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación Melbourne-Wübbena ------------------------------------------
			elseif tipo_med(nn) == TipoMedicion.MWC
				% Primero armo las combinaciones wide-lane de fases de portadora
				flag_LWL_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.LWL);
				flag_PNL_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.PNL);
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if ~flag_LWL_presente
					if flag_L1P_presente && flag_L2P_presente
						datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.LWL];
						datosObsRNX.(gnss_field).LWL = datosObsRNX.(gnss_field).L1P;
						datosObsRNX.(gnss_field).LWL.Valor = WLC_A1.*datosObsRNX.(gnss_field).L1P.Valor + WLC_A2.*datosObsRNX.(gnss_field).L2P.Valor;
					else
						error('ERROR! Tipo de medición no presente...');
					end
				end
				
				% Ahora armo las combinaciones narrow-lane de pseudorangos
				if ~flag_PNL_presente
					if flag_C1P_presente && flag_C2P_presente
						datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PNL];
						datosObsRNX.(gnss_field).PNL = datosObsRNX.(gnss_field).C1P;
						datosObsRNX.(gnss_field).PNL.Valor = NLC_A1.*datosObsRNX.(gnss_field).C1P.Valor + NLC_A2.*datosObsRNX.(gnss_field).C2P.Valor;
					else
						error('ERROR! Tipo de medición no presente...');
					end
				end
				
				% Finalmente armo la Melbourne-Wübbena
				datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.MWC];
				datosObsRNX.(gnss_field).MWC = datosObsRNX.(gnss_field).PNL;
				datosObsRNX.(gnss_field).MWC.Valor = datosObsRNX.(gnss_field).LWL.Valor - datosObsRNX.(gnss_field).PNL.Valor;
				
%------ Combinación wide-lane de pseudorangos ----------------------------------
			elseif tipo_med(nn) == TipoMedicion.PWL
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				
				if flag_C1P_presente && flag_C2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PWL];
					datosObsRNX.(gnss_field).PWL = datosObsRNX.(gnss_field).C1P;
					datosObsRNX.(gnss_field).PWL.Valor = WLC_A1.*datosObsRNX.(gnss_field).C1P.Valor + WLC_A2.*datosObsRNX.(gnss_field).C2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación wide-lane de fases de portadora ----------------------------
			elseif tipo_med(nn) == TipoMedicion.LWL
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if flag_L1P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.LWL];
					datosObsRNX.(gnss_field).LWL = datosObsRNX.(gnss_field).L1P;
					datosObsRNX.(gnss_field).LWL.Valor = WLC_A1.*datosObsRNX.(gnss_field).L1P.Valor + WLC_A2.*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación narrow-lane de pseudorangos --------------------------------
			elseif tipo_med(nn) == TipoMedicion.PNL
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				
				if flag_C1P_presente && flag_C2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PNL];
					datosObsRNX.(gnss_field).PNL = datosObsRNX.(gnss_field).C1P;
					datosObsRNX.(gnss_field).PNL.Valor = NLC_A1.*datosObsRNX.(gnss_field).C1P.Valor + NLC_A2.*datosObsRNX.(gnss_field).C2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación narrow-lane de fases de portadora --------------------------
			elseif tipo_med(nn) == TipoMedicion.LNL
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if flag_L1P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.LNL];
					datosObsRNX.(gnss_field).LNL = datosObsRNX.(gnss_field).L1P;
					datosObsRNX.(gnss_field).LNL.Valor = NLC_A1.*datosObsRNX.(gnss_field).L1P.Valor + NLC_A2.*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación libre de geometría de pseudorangos -------------------------
			elseif tipo_med(nn) == TipoMedicion.PGF
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				flag_C1C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1C);
				flag_C2C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2C);
				
				if flag_C1P_presente && flag_C2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PGF];
					datosObsRNX.(gnss_field).PGF = datosObsRNX.(gnss_field).C1P;
					datosObsRNX.(gnss_field).PGF.Valor = datosObsRNX.(gnss_field).C1P.Valor - datosObsRNX.(gnss_field).C2P.Valor;
				elseif flag_C1C_presente && flag_C2C_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.PGF];
					datosObsRNX.(gnss_field).PGF = datosObsRNX.(gnss_field).C1C;
					datosObsRNX.(gnss_field).PGF.Valor = datosObsRNX.(gnss_field).C1C.Valor - datosObsRNX.(gnss_field).C2C.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación libre de geometría de fases	de portadora -------------------
			elseif tipo_med(nn) == TipoMedicion.LGF
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				flag_L1C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1C);
				flag_L2C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2C);
				
				if flag_L1P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.LGF];
					datosObsRNX.(gnss_field).LGF = datosObsRNX.(gnss_field).L1P;
					datosObsRNX.(gnss_field).LGF.Valor = datosObsRNX.(gnss_field).L1P.Valor - datosObsRNX.(gnss_field).L2P.Valor;
				elseif flag_L1C_presente && flag_L2C_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.LGF];
					datosObsRNX.(gnss_field).LGF = datosObsRNX.(gnss_field).L1C;
					datosObsRNX.(gnss_field).LGF.Valor = datosObsRNX.(gnss_field).L1C.Valor - datosObsRNX.(gnss_field).L2C.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación GRAPHIC de C1 y L1 -----------------------------------------
			elseif tipo_med(nn) == TipoMedicion.G1C
				flag_C1C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1C);
				flag_L1C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1C);
				
				if flag_C1C_presente && flag_L1C_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.G1C];
					datosObsRNX.(gnss_field).G1C = datosObsRNX.(gnss_field).C1C;
					datosObsRNX.(gnss_field).G1C.Valor = (datosObsRNX.(gnss_field).C1C.Valor + datosObsRNX.(gnss_field).L1C.Valor)/2;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación GRAPHIC de P1 y L1 -----------------------------------------
			elseif tipo_med(nn) == TipoMedicion.G1P
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				
				if flag_C1P_presente && flag_L1P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.G1P];
					datosObsRNX.(gnss_field).G1P = datosObsRNX.(gnss_field).C1P;
					datosObsRNX.(gnss_field).G1P.Valor = (datosObsRNX.(gnss_field).C1P.Valor + datosObsRNX.(gnss_field).L1P.Valor)/2;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación GRAPHIC de C2 y L2 -----------------------------------------
			elseif tipo_med(nn) == TipoMedicion.G2C
				flag_C2C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2C);
				flag_L2C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2C);
				
				if flag_C2C_presente && flag_L2C_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.G2C];
					datosObsRNX.(gnss_field).G2C = datosObsRNX.(gnss_field).C2C;
					datosObsRNX.(gnss_field).G2C.Valor = (datosObsRNX.(gnss_field).C2C.Valor + datosObsRNX.(gnss_field).L2C.Valor)/2;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación GRAPHIC de P2 y L2 -----------------------------------------
			elseif tipo_med(nn) == TipoMedicion.G2P
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if flag_C2P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.G2P];
					datosObsRNX.(gnss_field).G2P = datosObsRNX.(gnss_field).C2P;
					datosObsRNX.(gnss_field).G2P.Valor = (datosObsRNX.(gnss_field).C2P.Valor + datosObsRNX.(gnss_field).L2P.Valor)/2;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación multicamino de L1 ------------------------------------------
			elseif tipo_med(nn) == TipoMedicion.MP1C
				flag_C1C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1C);
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if flag_C1C_presente && flag_L1P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.MP1C];
					datosObsRNX.(gnss_field).MP1C = datosObsRNX.(gnss_field).C1C;
					datosObsRNX.(gnss_field).MP1C.Valor = datosObsRNX.(gnss_field).C1C.Valor + MPC1_A1*datosObsRNX.(gnss_field).L1P.Valor + MPC1_A2*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación multicamino de L2 ------------------------------------------
			elseif tipo_med(nn) == TipoMedicion.MP2C
				flag_C2C_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2C);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				
				if flag_C2C_presente && flag_L2P_presente && flag_L1P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.MP2C];
					datosObsRNX.(gnss_field).MP2C = datosObsRNX.(gnss_field).C2C;
					datosObsRNX.(gnss_field).MP2C.Valor = datosObsRNX.(gnss_field).C2C.Valor + MPC2_A1*datosObsRNX.(gnss_field).L1P.Valor + MPC2_A2*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación multicamino de L1 con P1 -----------------------------------
			elseif tipo_med(nn) == TipoMedicion.MP1P
				flag_C1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C1P);
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				
				if flag_C1P_presente && flag_L1P_presente && flag_L2P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.MP1P];
					datosObsRNX.(gnss_field).MP1P = datosObsRNX.(gnss_field).C1P;
					datosObsRNX.(gnss_field).MP1P.Valor = datosObsRNX.(gnss_field).C1P.Valor + MPC1_A1*datosObsRNX.(gnss_field).L1P.Valor + MPC1_A2*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%------ Combinación multicamino de L2 con P2 -----------------------------------
			elseif tipo_med(nn) == TipoMedicion.MP2P
				flag_C2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.C2P);
				flag_L2P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L2P);
				flag_L1P_presente = any(datosObsRNX.(gnss_field).Observables == TipoMedicion.L1P);
				
				if flag_C2P_presente && flag_L2P_presente && flag_L1P_presente
					datosObsRNX.(gnss_field).Observables = [datosObsRNX.(gnss_field).Observables; TipoMedicion.MP2P];
					datosObsRNX.(gnss_field).MP2P = datosObsRNX.(gnss_field).C2P;
					datosObsRNX.(gnss_field).MP2P.Valor = datosObsRNX.(gnss_field).C2P.Valor + MPC2_A1*datosObsRNX.(gnss_field).L1P.Valor + MPC2_A2*datosObsRNX.(gnss_field).L2P.Valor;
				else
					error('ERROR! Tipo de medición no presente...');
				end
				
%-------------------------------------------------------------------------------
			else
				error('ERROR! Tipo de medición (combinación) no implementada aún...');
			end
			
		end
	end
end

end





%-------------------------------------------------------------------------------
function stringGNSS = sistemaGNSS2stringEstructura(SYS)
	
if SYS == SistemaGNSS.GPS
	stringGNSS = 'gpsObs';
	return;
elseif SYS == SistemaGNSS.GLONASS
	stringGNSS = 'glonassObs';
	return;
elseif SYS == SistemaGNSS.Galileo
	stringGNSS = 'galileoObs';
	return;
elseif SYS == SistemaGNSS.BeiDou
	stringGNSS = 'bdsObs';
	return;
elseif SYS == SistemaGNSS.QZSS
	stringGNSS = 'qzssObs';
	return;
elseif SYS == SistemaGNSS.IRNSS
	stringGNSS = 'irnssObs';
	return;	
elseif SYS == SistemaGNSS.SBAS
	stringGNSS = 'sbasObs';
	return;	
end

end
%-------------------------------------------------------------------------------