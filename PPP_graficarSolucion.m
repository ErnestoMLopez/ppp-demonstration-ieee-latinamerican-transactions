function datosPPP = PPP_graficarSolucion(datosPPP,flag_graficarENU,flag_graficarHOR,flag_graficarCLK,r0)
%PPP_GRAFICARSOLUCION Graficos generales de la solución PPP

KK = length(datosPPP.tR);

t = (datosPPP.tR - datosPPP.tR(1))./3600;

% Si tengo posición referencia calculo el error de la solución respecto ella
if ~isempty(r0)
	errXYZ = NaN(KK,3);
	errENU = NaN(KK,3);
	stdENU = datosPPP.stdENU;
	for kk = 1:KK
		errXYZ(kk,:) = datosPPP.solXYZ(kk,:) - r0';
		errENU(kk,:) = (ecefdif2enu(datosPPP.solXYZ(kk,:)',r0))';
	end
	
	titulo_graficarENU = [datosPPP.Estacion ' - Error posición ENU vs. Estimado final PPP'];
	titulo_graficarHOR = [datosPPP.Estacion ' - Error posición horizontal vs. Estimado final PPP'];
	
	limites_graficarENU = [-inf inf -0.5 +0.5; ...
						   -inf inf -0.5 +0.5; ...
						   -inf inf -0.5 +0.5];
	limites_graficarHOR = [-50 +50 -50 +50];
	
else
	errENU = datosPPP.errENU;
	stdENU = datosPPP.stdENU;
	
	titulo_graficarENU = [datosPPP.Estacion ' - Error posición ENU vs. RINEX a-priori'];
	titulo_graficarHOR = [datosPPP.Estacion ' - Error posición horizontal vs. RINEX a-priori'];
	
	limites_graficarENU = [-inf inf errENU(end,1)-0.5 errENU(end,1)+0.5; ...
						   -inf inf errENU(end,2)-0.5 errENU(end,2)+0.5; ...
						   -inf inf errENU(end,3)-0.5 errENU(end,3)+0.5];
					   
	limites_graficarHOR = [100*errENU(end,1)-50 100*errENU(end,1)+50 100*errENU(end,2)-50 100*errENU(end,2)+50];
end


%----- Gráfico error de posición ENU respecto a RINEX a priori -----------------
if flag_graficarENU
	figure;
	subplot(3,1,1);
	plot(t,errENU(:,1),'.-');
	title(titulo_graficarENU);
	grid on; axis(limites_graficarENU(1,:)); hold on; set(gca, 'Fontsize',13);
	plot(t,errENU(:,1)+3.*stdENU(:,1),':r','LineWidth',1.25);
	plot(t,errENU(:,1)-3.*stdENU(:,1),':r','LineWidth',1.25);
	ylabel('$\Delta r_E$ [m]','Interpreter','latex');
	legend('r_{PPP}-r_{RNX}','\pm3\sigma_r','\pm 5cm')
	subplot(3,1,2);
	plot(t,errENU(:,2),'.-');
	grid on; axis(limites_graficarENU(2,:)); hold on; set(gca, 'Fontsize',13);
	plot(t,errENU(:,2)+3.*stdENU(:,2),':r','LineWidth',1.25);
	plot(t,errENU(:,2)-3.*stdENU(:,2),':r','LineWidth',1.25);
	ylabel('$\Delta r_N$ [m]','Interpreter','latex');
	subplot(3,1,3);
	plot(t,errENU(:,3),'.-');
	grid on; axis(limites_graficarENU(3,:)); hold on; set(gca, 'Fontsize',13);
	plot(t,errENU(:,3)+3.*stdENU(:,3),':r','LineWidth',1.25);
	plot(t,errENU(:,3)-3.*stdENU(:,3),':r','LineWidth',1.25);
	ylabel('$\Delta r_U$ [m]','Interpreter','latex');
	xlabel('Tiempo [h]','Interpreter','latex');
end
%-------------------------------------------------------------------------------


%----- Error de posicin horizontal respecto a SINEX - Diagrama scatter --------
if flag_graficarHOR
	figure; colormap jet
	sz = 25;
	c = linspace(0,24,KK);
	scatter(errENU(:,1).*100,errENU(:,2).*100,sz,c,'filled');
	grid on; axis(limites_graficarHOR,'square'); box on; set(gca, 'Fontsize',13); 
	h_cb = colorbar; ylabel(h_cb, 'Tiempo [h]')
	line([-25 25],[0 0],'Color',[.4 .4 .4],'LineWidth',0.75); 
	line([0 0],[-25 25],'Color',[.4 .4 .4],'LineWidth',0.75);
	title(titulo_graficarHOR);
	ylabel('$\Delta r_N$ [cm]','Interpreter','latex');
	xlabel('$\Delta r_E$ [cm]','Interpreter','latex');
end
%-------------------------------------------------------------------------------


%----- Grfico estimacin sesgo de reloj y correccin ZTD wet ------------------
if flag_graficarCLK
	
	% Calculo los ZTD
	ZTD = NaN(KK,1);
	for kk = 1:KK
		ZTD(kk) = calcularRetardoTroposfericoZenital(datosPPP.tR(kk),datosPPP.solXYZ(kk,:)',datosPPP.solDZTDw(kk));
	end
	
	figure;
	subplot(2,1,1);
	plot(t,1E6.*datosPPP.solClk,'.-');
	title([datosPPP.Estacion ' - Sesgo de reloj de receptor estimado']);
	grid on; axis tight; set(gca, 'Fontsize',13);
	ylabel('$\delta t_r$ [$\mu$s]','Interpreter','latex');
	subplot(2,1,2);
	plot(t,ZTD,'.-');
	grid on; axis tight; set(gca, 'Fontsize',13);
	title([datosPPP.Estacion ' - Retardo troposfrico zenital']);
	ylabel('$ZTD$ [m]','Interpreter','latex');
	xlabel('Tiempo [h]','Interpreter','latex');
end
%-------------------------------------------------------------------------------

end

