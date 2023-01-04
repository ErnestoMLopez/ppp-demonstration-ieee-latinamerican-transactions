function [datosPPP_IGS,datosPPP_EPH,datosPPP_IGC] = IJSCN20_PPP_graficarSolucion(datosPPP_IGS,datosPPP_EPH,datosPPP_IGC,flag_graficarENU,flag_graficarHOR,flag_graficar3D)
%IJSCN20_PPP_GRAFICARSOLUCION Graficos generales de la solución PPP

colors = [	0		0.4470	0.7410; ...
			0.8500  0.3250	0.0980; ...
			0.9290	0.6940	0.1250; ...
			0.4940	0.1840	0.5560; ...
			0.4660	0.6740	0.1880; ...
			0.3010	0.7450	0.9330; ...
			0.6350	0.0780	0.1840];

% La solución referencia será el último estimado PPP
r0 = datosPPP_IGS.solXYZ(end,:)';

KK = length(datosPPP_IGS.tR);
t = (datosPPP_IGS.tR - datosPPP_IGS.tR(1))./3600;

% Calculo el error de la solución respecto a la posición referencia
errXYZ_IGS = NaN(KK,3);
errENU_IGS = NaN(KK,3);
errXYZ_EPH = NaN(KK,3);
errENU_EPH = NaN(KK,3);
errXYZ_IGC = NaN(KK,3);
errENU_IGC = NaN(KK,3);

for kk = 1:KK
	errXYZ_IGS(kk,:) = datosPPP_IGS.solXYZ(kk,:) - r0';
	errENU_IGS(kk,:) = (ecefdif2enu(datosPPP_IGS.solXYZ(kk,:)',r0))';
	
	errXYZ_EPH(kk,:) = datosPPP_EPH.solXYZ(kk,:) - r0';
	errENU_EPH(kk,:) = (ecefdif2enu(datosPPP_EPH.solXYZ(kk,:)',r0))';
	
	errXYZ_IGC(kk,:) = datosPPP_IGC.solXYZ(kk,:) - r0';
	errENU_IGC(kk,:) = (ecefdif2enu(datosPPP_IGC.solXYZ(kk,:)',r0))';
end

titulo_graficarENU = 'Position error (ENU) vs. Final PPP solution';
titulo_graficarHOR = 'Horizontal position error vs. Final PPP solution';
titulo_graficar3D = 'Position error (3D) vs. Final PPP solution';
titulo_graficarHorVer = 'Position error w.r.t. Final PPP solution';

limites_graficarENU = [-inf inf -0.5 +0.5; ...
					   -inf inf -0.5 +0.5; ...
					   -inf inf -0.5 +0.5];
limites_graficarHOR = [-50 +50 -50 +50];
limites_graficar3D = [-inf inf 0 1];

% Calculo el error de posición horizontal y vertical por separado
errPosHor_IGS = sqrt(sum(errENU_IGS(:,1:2).^2,2));
errPosHor_EPH = sqrt(sum(errENU_EPH(:,1:2).^2,2));
errPosHor_IGC = sqrt(sum(errENU_IGC(:,1:2).^2,2));

errPosVer_IGS = abs(errENU_IGS(:,3));
errPosVer_EPH = abs(errENU_EPH(:,3));
errPosVer_IGC = abs(errENU_IGC(:,3));

% Calculo el error de posición en 3D
errPos3D_IGS = sqrt(sum(errENU_IGS.^2,2));
errPos3D_EPH = sqrt(sum(errENU_EPH.^2,2));
errPos3D_IGC = sqrt(sum(errENU_IGC.^2,2));

datosPPP_IGS.errXYZ = errXYZ_IGS;
datosPPP_IGS.errENU = errENU_IGS;
datosPPP_IGS.errPos3D = errPos3D_IGS;

datosPPP_EPH.errXYZ = errXYZ_EPH;
datosPPP_EPH.errENU = errENU_EPH;
datosPPP_EPH.errPos3D = errPos3D_EPH;

datosPPP_IGC.errXYZ = errXYZ_IGC;
datosPPP_IGC.errENU = errENU_IGC;
datosPPP_IGC.errPos3D = errPos3D_IGC;


%----- Gráfico error de posición ENU respecto a RINEX a priori -----------------
if flag_graficarENU
	figure;
	subplot(3,1,1);
	plot(t,errENU_IGS(:,1),'.-');
	title([titulo_graficarENU ' - IGS']);
	grid on; axis(limites_graficarENU(1,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_E$ [m]','Interpreter','latex');
	legend('r-r_{PPP}')
	subplot(3,1,2);
	plot(t,errENU_IGS(:,2),'.-');
	grid on; axis(limites_graficarENU(2,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_N$ [m]','Interpreter','latex');
	subplot(3,1,3);
	plot(t,errENU_IGS(:,3),'.-');
	grid on; axis(limites_graficarENU(3,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_U$ [m]','Interpreter','latex');
	xlabel('Time [h]','Interpreter','latex');
	
	
	figure;
	subplot(3,1,1);
	plot(t,errENU_EPH(:,1),'.-');
	title([titulo_graficarENU ' - EPH']);
	grid on; axis(limites_graficarENU(1,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_E$ [m]','Interpreter','latex');
	legend('r-r_{PPP}')
	subplot(3,1,2);
	plot(t,errENU_EPH(:,2),'.-');
	grid on; axis(limites_graficarENU(2,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_N$ [m]','Interpreter','latex');
	subplot(3,1,3);
	plot(t,errENU_EPH(:,3),'.-');
	grid on; axis(limites_graficarENU(3,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_U$ [m]','Interpreter','latex');
	xlabel('Time [h]','Interpreter','latex');
	
	
	figure;
	subplot(3,1,1);
	plot(t,errENU_IGC(:,1),'.-');
	title([titulo_graficarENU ' - IGC']);
	grid on; axis(limites_graficarENU(1,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_E$ [m]','Interpreter','latex');
	legend('r-r_{PPP}')
	subplot(3,1,2);
	plot(t,errENU_IGC(:,2),'.-');
	grid on; axis(limites_graficarENU(2,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_N$ [m]','Interpreter','latex');
	subplot(3,1,3);
	plot(t,errENU_IGC(:,3),'.-');
	grid on; axis(limites_graficarENU(3,:)); hold on; set(gca, 'Fontsize',13);
	ylabel('$\Delta r_U$ [m]','Interpreter','latex');
	xlabel('Time [h]','Interpreter','latex');
end
%-------------------------------------------------------------------------------


%----- Error de posicin horizontal respecto a SINEX - Diagrama scatter --------
if flag_graficarHOR
	figure; colormap jet
	sz = 25;
	c = linspace(0,24,KK);
	scatter(errENU_IGS(:,1).*100,errENU_IGS(:,2).*100,sz,c,'filled');
	grid on; axis(limites_graficarHOR,'square'); box on; set(gca, 'Fontsize',13); 
	h_cb = colorbar; ylabel(h_cb, 'Time [h]')
	line([-25 25],[0 0],'Color',[.4 .4 .4],'LineWidth',0.75); 
	line([0 0],[-25 25],'Color',[.4 .4 .4],'LineWidth',0.75);
	title([titulo_graficarHOR ' - IGS']);
	ylabel('$\Delta r_N$ [cm]','Interpreter','latex');
	xlabel('$\Delta r_E$ [cm]','Interpreter','latex');
	
	
	figure; colormap jet
	sz = 25;
	c = linspace(0,24,KK);
	scatter(errENU_EPH(:,1).*100,errENU_EPH(:,2).*100,sz,c,'filled');
	grid on; axis(limites_graficarHOR,'square'); box on; set(gca, 'Fontsize',13); 
	h_cb = colorbar; ylabel(h_cb, 'Time [h]')
	line([-25 25],[0 0],'Color',[.4 .4 .4],'LineWidth',0.75); 
	line([0 0],[-25 25],'Color',[.4 .4 .4],'LineWidth',0.75);
	title([titulo_graficarHOR ' - EPH']);
	ylabel('$\Delta r_N$ [cm]','Interpreter','latex');
	xlabel('$\Delta r_E$ [cm]','Interpreter','latex');
	
	
	figure; colormap jet
	sz = 25;
	c = linspace(0,24,KK);
	scatter(errENU_IGC(:,1).*100,errENU_IGC(:,2).*100,sz,c,'filled');
	grid on; axis(limites_graficarHOR,'square'); box on; set(gca, 'Fontsize',13); 
	h_cb = colorbar; ylabel(h_cb, 'Time [h]')
	line([-25 25],[0 0],'Color',[.4 .4 .4],'LineWidth',0.75); 
	line([0 0],[-25 25],'Color',[.4 .4 .4],'LineWidth',0.75);
	title([titulo_graficarHOR ' - IGC']);
	ylabel('$\Delta r_N$ [cm]','Interpreter','latex');
	xlabel('$\Delta r_E$ [cm]','Interpreter','latex');
end
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
if flag_graficar3D
	figure;
	plot(t,errPos3D_EPH,'-.','LineWidth',1.8); hold on; set(gca, 'Fontsize',13);
	plot(t,errPos3D_IGC,'-.','LineWidth',1.8);
	plot(t,errPos3D_IGS,'k.-');
	axis(limites_graficar3D);
	title(titulo_graficar3D);
	legend('Ephemeris','Real-time Products','Final products');
	ylabel('$\Delta r_{3D}$ [m]','Interpreter','latex');
	xlabel('Time [h]','Interpreter','latex');
	
	
	figure;
	plot(t,errPos3D_EPH,'--','LineWidth',1.8); hold on; set(gca, 'Fontsize',13);
	plot(t,errPos3D_IGC,'--','LineWidth',1.8);
	plot(t,errPos3D_IGS,'k.-');
	plot(t,errPosHor_EPH,':','LineWidth',1.2,'Color',colors(1,:));
	plot(t,errPosHor_IGC,':','LineWidth',1.2,'Color',colors(2,:));
	plot(t,errPosHor_IGS,'k:');
	plot(t,errPosVer_EPH,'-.','LineWidth',1.2,'Color',colors(1,:));
	plot(t,errPosVer_IGC,'-.','LineWidth',1.2,'Color',colors(2,:));
	plot(t,errPosVer_IGS,'k-.');
	axis(limites_graficar3D);
	title(titulo_graficar3D);
	legend('Ephemeris (3D)','Real-time Products (3D)','Final products (3D)', ...
		   'Ephemeris (Hor)','Real-time Products (Hor)','Final products (Hor)', ...
		   'Ephemeris (Ver)','Real-time Products (Ver)','Final products (Ver)');
	ylabel('$\Delta r_{3D}$ [m]','Interpreter','latex');
	xlabel('Time [h]','Interpreter','latex');
	
	
	figure;
	subplot(2,1,1);
	plot(t,errPosHor_EPH,'-.','LineWidth',1.5,'Color',colors(1,:)); hold on; set(gca, 'Fontsize',13);
	plot(t,errPosHor_IGC,'-.','LineWidth',1.5,'Color',colors(2,:));
	plot(t,errPosHor_IGS,'k--','LineWidth',1.5);
	ylabel('$\Delta r_{Hor}$ [m]','Interpreter','latex');
	legend('Ephemeris','Real-time Prod.','Final Prod.');
	axis(limites_graficar3D);
	title(titulo_graficarHorVer);
	
	subplot(2,1,2)
	plot(t,errPosVer_EPH,'-.','LineWidth',1.5,'Color',colors(1,:)); hold on; set(gca, 'Fontsize',13);
	plot(t,errPosVer_IGC,'-.','LineWidth',1.5,'Color',colors(2,:));
	plot(t,errPosVer_IGS,'k--','LineWidth',1.5);
	ylabel('$\Delta r_{Ver}$ [m]','Interpreter','latex');
	legend('Ephemeris','Real-time Prod.','Final Prod.');
	axis(limites_graficar3D);
	
	xlabel('Time [h]','Interpreter','latex');
end
end

