% Script para IEEE Latin American Transactions:
% "Low-Cost Satellite-Based Correction Service for Precise Point Positioning in
% Latin America"

clear; close all; clc;
addpath(genpath('./ModulosGNSS/'));

load ConstantesGNSS.mat
load ConstantesOrbitales.mat
load ConstantesTroposfera.mat


%% Opciones de simulacion

configPPP = struct( ...
	'T',				30, ...		% Tiempo de muestreo
	'GNSS',				[SistemaGNSS.GPS], ...						% GNSS a utilizar
	'OBSERVABLES',		[TipoMedicion.PIF; ...	% Observables a utilizar en todo el 
						 TipoMedicion.LIF; ...	% procesamiento (edición de datos y posicionamiento)
						 TipoMedicion.MWC; ...
						 TipoMedicion.LGF], ...
						 ...	
	'MEDICIONES',		[TipoMedicion.PIF; ...	% Mediciones a utilizar en el posicionamiento
						 TipoMedicion.LIF], ...
	'INICIALIZAR_ESTADO_CON_RINEX',	1, ...		% Obtención del estimado de posición y de reloj a-priori: 0: calcular con la primera época, 1: posición aproximada RINEX y sesgo de reloj nulo
	'PRODUCTOS_GNSS',	true, ...	% Flag indicador de uso de productos precisos, 1: IGS, 0: Efemérides
	'MASCARA_ELEVACION',5, ...		% Ángulo de máscara de elevación
	'SIGMA_UERE',		1.2,...		% Estimado del error equivalente de rango del usuario utilizando combinación IF
	... 
	'SIGMA_PR',			1,...		% Desv. est. asumida del ruido de pseudorangos
	'SIGMA_CP',			0.01,...	% Desv. est. asumida del ruido de fases de portadora
	...
	'SIGMA_APRIORI_R',	1, ...		% Desv. est. a-priori de la posición del receptor
	'SIGMA_APRIORI_CDTR',1E6, ...	% Desv. est. a-priori del sesgo de reloj de receptor
	'SIGMA_APRIORI_DZTD',0.5, ...	% Desv. est. a-priori de la corrección por ZTD wet
	'SIGMA_APRIORI_B',	2, ...		% Desv. est. a-priori de las ambigüedades de fase
	...
	'SIGMA_R',			0, ...		% Desv. est. asumida del ruido de proceso para la posición del receptor
	'SIGMA_CDTR',		1000, ...	% Desv. est. asumida del ruido de proceso para el sesgo de reloj de receptor
	'SIGMA_DZTD',		0.1, ...	% Desv. est. asumida del ruido de proceso para la corrección por ZTD wet
	...
	'TAU_CDTR',			100,...		% Tiempo de correlación del sesgo de reloj de receptor
	'TAU_DZTD',			3600, ...	% Tiempo de correlación de la corrección del retardo troposférico zenital húmedo
	...
	'FLAG_MASCARA_ELEVACION',		true,...	% Flags para aplicar (1) o no (0) correcciones y tests
	'FLAG_SATELITES_ECLIPSE',		true,...
	'FLAG_SALTO_CICLO',				true,...
	'FLAG_UMBRAL_SNR',				true,...
	'FLAG_UMBRAL_PDOP',				false,...
	'FLAG_CORR_RELOJ_SATELITE',		true,...
	'FLAG_CORR_RELATIVISTA',		true,...
	'FLAG_CORR_SAGNAC',				true,...
	'FLAG_CORR_APC_SATELITE',		true,...
	'FLAG_CORR_PCV_SATELITE',		true,...
	'FLAG_CORR_APC_RECEPTOR',		true,...
	'FLAG_CORR_PCV_RECEPTOR',		true,...
	'FLAG_CORR_ARP',				true,...
	'FLAG_CORR_WIND_UP',			true,...	
	'FLAG_CORR_MAREAS',				true,...
	'FLAG_CORR_TROPOSFERA',			true,...	
	'FLAG_CORR_IONOSFERA_ORDEN_SUP',false,...
	'FLAG_CORR_RELATIVISTA_GEN',	true,...	
	...
	'UMBRAL_SALTO_CICLO_LGF',	0.0808*(1 - exp((-30/60)/2)), ... % Umbral para el detector de saltos de ciclos basado en diferencias L1 y P1
	'UMBRAL_PDOP',		15, ...		% Máxima PDOP para validación de solución
	'UMBRAL_SNR',		30, ...		% Mínima SNR para utilización de mediciones
	'UMBRAL_RES_PR',	1);			% Máxima desv. est. de los residuos de pseudorangos para la preedición de datos


%% Configuracion del dia y estacion a procesar
%%------------------------------------------------------------------------------

for ESTACION = {'AREG','BOGT','CHPI','CORD'}
	for DD = 1:8
		
		MM = 03;
		YYYY = 2020;
		
		% Descargo, leo y guardo los observables
		
		rutaarchivoobs = PPP_descargarObservablesEstacion(ESTACION{1},DD,MM,YYYY);
		
		[filepath,name,ext] = fileparts(rutaarchivoobs);
		rutaarchivosalida = [filepath '/IEEELatamOutputData.mat'];
		
		% Procesamiento PPP (productos IGS)
		configPPP.PRODUCTOS_GNSS = true;
		rutaarchivoppp = PPP_main(rutaarchivoobs,configPPP);
		
		load(rutaarchivoppp);
		
		% Renombro para no sobreescribir datos
		datosPPP_IGS = datosPPP;
		
		
		% Procesamiento PPP (efemérides)
		configPPP.PRODUCTOS_GNSS = false;
		rutaarchivoppp = PPP_main(rutaarchivoobs,configPPP);
		
		load(rutaarchivoppp);
		
		% Renombro para no sobreescribir datos
		datosPPP_EPH = datosPPP;
		
		
		% Procesamiento SRTPPP
		rutaarchivossrtppp = SRTPPP_main(rutaarchivoobs,configPPP);
		load(rutaarchivossrtppp);
		
		% Renombro para no sobreescribir datos
		datosPPP_IGC = datosSRTPPP;
		
		
		% Graficos y guardado
		[datosPPP_IGS,datosPPP_EPH,datosPPP_IGC] = IEEELatam_PPP_graficarSolucion(datosPPP_IGS,datosPPP_EPH,datosPPP_IGC,true,true,true);
		
		save(rutaarchivosalida,'datosPPP_IGS','datosPPP_EPH','datosPPP_IGC','datosObsRNX','datosNavRNX','datosSP3','datosSatCLK','datosEstCLK','datosSatATX','datosRecATX');
		
	end
end


%% Tablas

LIMITE_CONVERGENCIA = 120;

for ESTACION = {'AREG','CORD','CHPI','BOGT'}
	
	resultados.(ESTACION{:}).LIMITE_CONVERGENCIA = NaN(7,1);
	resultados.(ESTACION{:}).errENU_EPH = NaN(7,3);
	resultados.(ESTACION{:}).errENU_IGC = NaN(7,3);
	resultados.(ESTACION{:}).errHor_EPH = NaN(7,1);
	resultados.(ESTACION{:}).errHor_IGC = NaN(7,1);
	
	for DD = 1:7
		archivo = ['.\pppdata\' num2str(DD,'%02d') '032020\' ESTACION{:} '\IEEELatamOutputData.mat'];
		load(archivo);
		[datosPPP_IGS,datosPPP_EPH,datosPPP_IGC] = IEEELatam_PPP_graficarSolucion(datosPPP_IGS,datosPPP_EPH,datosPPP_IGC,false,false,false);
		
		
		KK = length(datosPPP_IGC.tR);
		
		errHorConvergencia = 0.5;
		indxConvergencia = 0;
		flagConvergencia = false;
		
		for kk = 1:KK
			errHor = norm(datosPPP_IGC.errENU(kk,1:2));
			
			if errHor < errHorConvergencia
				if ~flagConvergencia
					indxConvergencia = kk;
				end
				flagConvergencia = true;				
			else
				flagConvergencia = false;
			end
		end
		
		LIMITE_CONVERGENCIA = indxConvergencia;
		
		resultados.(ESTACION{:}).LIMITE_CONVERGENCIA(DD) = indxConvergencia;
		resultados.(ESTACION{:}).errENU_EPH(DD,:) = nanrms(datosPPP_EPH.errENU(LIMITE_CONVERGENCIA:end,:),1);
		resultados.(ESTACION{:}).errENU_IGC(DD,:) = nanrms(datosPPP_IGC.errENU(LIMITE_CONVERGENCIA:end,:),1);
		resultados.(ESTACION{:}).errHor_EPH(DD) = nanrms(sqrt(datosPPP_EPH.errENU(LIMITE_CONVERGENCIA:end,1).^2+datosPPP_EPH.errENU(LIMITE_CONVERGENCIA:end,2).^2));
		resultados.(ESTACION{:}).errHor_IGC(DD) = nanrms(sqrt(datosPPP_IGC.errENU(LIMITE_CONVERGENCIA:end,1).^2+datosPPP_IGC.errENU(LIMITE_CONVERGENCIA:end,2).^2));
	end
end


% Imprimir en pantalla los valores de la tabla
disp('Mean RMS ENU EPH')
[mean(resultados.AREG.errENU_EPH(2:6,:),1); ...
mean(resultados.CORD.errENU_EPH(2:6,:),1); ...
mean(resultados.CHPI.errENU_EPH(2:6,:),1); ...
mean(resultados.BOGT.errENU_EPH(2:6,:),1)]

disp('Mean RMS ENU IGC')
[mean(resultados.AREG.errENU_IGC(2:6,:),1); ...
mean(resultados.CORD.errENU_IGC(2:6,:),1); ...
mean(resultados.CHPI.errENU_IGC(2:6,:),1); ...
mean(resultados.BOGT.errENU_IGC(2:6,:),1)]

disp('Mean RMS Hor EPH')
[mean(resultados.AREG.errHor_EPH(2:6,:),1); ...
mean(resultados.CORD.errHor_EPH(2:6,:),1); ...
mean(resultados.CHPI.errHor_EPH(2:6,:),1); ...
mean(resultados.BOGT.errHor_EPH(2:6,:),1)]

disp('Mean RMS Hor IGC')
[mean(resultados.AREG.errHor_IGC(2:6,:),1); ...
mean(resultados.CORD.errHor_IGC(2:6,:),1); ...
mean(resultados.CHPI.errHor_IGC(2:6,:),1); ...
mean(resultados.BOGT.errHor_IGC(2:6,:),1)]

disp('Max RMS ENU EPH')
[max(resultados.AREG.errENU_EPH(2:6,:),[],1); ...
max(resultados.CORD.errENU_EPH(2:6,:),[],1); ...
max(resultados.CHPI.errENU_EPH(2:6,:),[],1); ...
max(resultados.BOGT.errENU_EPH(2:6,:),[],1)]

disp('Max RMS ENU IGC')
[max(resultados.AREG.errENU_IGC(2:6,:),[],1); ...
max(resultados.CORD.errENU_IGC(2:6,:),[],1); ...
max(resultados.CHPI.errENU_IGC(2:6,:),[],1); ...
max(resultados.BOGT.errENU_IGC(2:6,:),[],1)]


%% Graficos de un día como muestra
close all;
EST = 'CORD';
DD = 6;
archivo = ['.\pppdata\' num2str(DD,'%02d') '032020\' EST '\IEEELatamOutputData.mat'];
load(archivo);

[datosPPP_IGS,datosPPP_EPH,datosPPP_IGC] = IEEELatam_PPP_graficarSolucion(datosPPP_IGS,datosPPP_EPH,datosPPP_IGC,true,true,true);


%% Analisis convergencia


for ESTACION = {'AREG','CORD','CHPI','BOGT'}
	
	disp(ESTACION{:});
	for DD = 2:6
		archivo = ['.\pppdata\' num2str(DD,'%02d') '032020\' ESTACION{:} '\IEEELatamOutputData.mat'];
		load(archivo);
		[datosPPP_IGS,datosPPP_EPH,datosPPP_IGC] = IEEELatam_PPP_graficarSolucion(datosPPP_IGS,datosPPP_EPH,datosPPP_IGC,false,false,false);
		
		KK = length(datosPPP_IGC.tR);
		
		errHorConvergencia = 0.5;
		indxConvergencia = 0;
		flagConvergencia = false;
		
		for kk = 1:KK
			errHor = norm(datosPPP_IGC.errENU(kk,1:2));
			
			if errHor < errHorConvergencia
				if ~flagConvergencia
					indxConvergencia = kk;
				end
				flagConvergencia = true;				
			else
				flagConvergencia = false;
			end
		end
		
		resultados.(ESTACION{:}).errENU_EPH(DD,:) = nanrms(datosPPP_EPH.errENU(LIMITE_CONVERGENCIA:end,:),1);
		resultados.(ESTACION{:}).errENU_IGC(DD,:) = nanrms(datosPPP_IGC.errENU(LIMITE_CONVERGENCIA:end,:),1);
		
	end
end