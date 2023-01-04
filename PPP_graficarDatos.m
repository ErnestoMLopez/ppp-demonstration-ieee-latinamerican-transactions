function h = PPP_graficarDatos(structusuario,structglab,grafico,PRN,opt)
%graficarDatosPPP Realiza distintos gráficos de interés para el usuario de PPP
%
% ARGUMENTOS:
%	structusuario -	Estructura tipo salidaPPP calculada por el usuario.
%	structglab    -	Estructura tipo salidaPPP calculada por gLAB.
%	grafico (str) -	Selecciona el grÃ¡fico a realizar de esta lista:
%	posXYZ : posicion en XYZ.			
%	errENU : error en ENU respecto a posicion a priori.
%	errXYZ : error en XYZ respecto a posicion a priori.
%	errENUscatter : error ENU en horizontal.
%	corrAPCSatelite : corrección APC + PCV para antena satelite.
%	corrAPCReceptor : corrección APC + PCV para antena receptor.
%	corrARPReceptor : correccion ARP para antena receptor.
%	corrWindUp : correccion Wind UP
%	PRN (Nx1)     - Opcional si se quiere graficar sobre un satÃ©lite
%	opt (1x1)     - Opcion de grafico comparativo o absoluto:
%					opt = 0 -> Resta de los campos de cada estructura.
%					opt = 1 -> Campo de structusuario.
%					opt = 2 -> Campo de structglab.
%					opt = 3 -> Suma de los campos de cada estructura
%
% DEVOLUCIÓN:
%	h            - Grafica el campo para el PRN seleccionado.
%

% ------------------------------- solXYZ ----------------------------------
if strcmp(grafico,'solXYZ')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Posición XYZ','NumberTitle','off');

	t1  = structusuario.tR;
	t2  = structglab.tR;
	dim = min(size(t1),size(t2));
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600;
    
    XYZUsuario = structusuario.solXYZ;
    stdUsuario = structusuario.stdXYZ;
    XYZGlab    = structglab.solXYZ;
    
    XYZUsuario = XYZUsuario(1:N,:);
    stdUsuario = stdUsuario(1:N,:);
    XYZGlab    = XYZGlab(1:N,:);
    
    
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = XYZUsuario - XYZGlab;
            tit  = 'Diferencia entre posicion en ECEF (Usuario - gLAB)';
            ejex = 't [h]';
            ejey = strsplit(('$X [m]$-$Y [m]$-$Z [m]$'),'-');
            leg  = strsplit(('\Delta X[m]-\Delta Y[m]-\Delta Z[m]'),'-');
            graficar3(x,y,tit,ejex,ejey,leg);
        case 3       % si quiero superpuestos
            y1 = XYZUsuario;
            y2 = XYZGlab;
            tit = 'Posicion en ECEF'; 
            ejex = 't [h]';
            ejey = strsplit(('$X[m]$-$Y[m]$-$Z[m]$'),'-');
            leg  = strsplit((['X Usuario[m]-Y Usuario[m]-'...
                             'Z Usuario[m]-X gLAB[m]-'...
                             'Y gLAB[m]-Z gLAB[m]']),'-');
            graficar3sup(x,y1,y2,tit,ejex,ejey,leg);
        case 1       % si quiero el campo de structusuario
            y = XYZUsuario;
            tit = 'Posicion en ECEF (Usuario)';
            ejex = 't [h]';
            ejey = strsplit(('$X [m]$-$Y [m]$-$Z [m]$'),'-');
            leg  = strsplit(('X \pm 3\sigma[m]-Y \pm 3\sigma[m]-Z \pm 3\sigma[m]'),'-');
            graficar3std(x,y,stdUsuario,tit,ejex,ejey,leg);
        case 2       % si quiero el campo de structglab
            y = XYZGlab;
            tit = 'Posicion en ECEF (gLAB)';
            ejex = 't [h]';
            ejey = strsplit(('$X [m]$-$Y [m]$-$Z [m]$'),'-');
            leg  = strsplit(('X [m]-Y [m]-Z [m]'),'-');
            graficar3(x,y,tit,ejex,ejey,leg);          
    end
      
end
% ----------------------------- FIN solXYZ --------------------------------

% ------------------------------- errXYZ ----------------------------------
if strcmp(grafico,'errXYZ')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Error posicion en XYZ respecto posicion a priori','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    XYZUsuario = structusuario.errXYZ;
    stdUsuario = structusuario.stdXYZ;
    ENUGlab    = structglab.errENU;
        
    ENUUsuario = ENUUsuario(1:N,:);
    stdUsuario = stdUsuario(1:N,:);
    ENUGlab    = ENUGlab(1:N,:);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = ENUUsuario - ENUGlab;
            tit = ['Diferencia entre errores de posicion en ENU '...
                   'respecto a posicion a priori (Usuario - gLAB)'];
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit(('err Este [m]-err Norte [m]-err Up [m]'),'-');
            graficar3(x,y,tit,ejex,ejey,leg);
        case 3       % si quiero superpuestos
            y1 = ENUUsuario;
            y2 = ENUGlab;
            tit = 'Error de posicion ENU respecto posicion a priori'; 
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit((['err Este Usuario[m]-err Norte Usuario[m]-'...
                             'err Up Usuario[m]-err Este gLAB[m]-'...
                             'err Norte gLAB[m]-err Up gLAB[m]']),'-');
            graficar3sup(x,y1,y2,tit,ejex,ejey,leg);
        case 1       % si quiero el campo de structusuario
            y = ENUUsuario;
            tit = 'Error de posicion en ENU respecto a posicion a priori (Usuario)';
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit(('err Este \pm 3\sigma[m]-err Norte \pm 3\sigma[m]-err Up \pm 3\sigma[m]'),'-');
            graficar3std(x,y,stdUsuario,tit,ejex,ejey,leg);
        case 2       % si quiero el campo de structglab
            y = ENUGlab;
            tit = 'Error de posicion en ENU respecto a posicion a priori (gLAB)';
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit(('err Este \pm 3\sigma[m]-err Norte \pm 3\sigma[m]-err Up \pm 3\sigma[m]'),'-');
            graficar3std(x,y,stdUsuario,tit,ejex,ejey,leg);
    end
      
end

% --------------------------- FIN errXYZ ----------------------------------

% ------------------------------- errENU ----------------------------------
if strcmp(grafico,'errENU')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Error posicion en ENU','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    ENUUsuario = structusuario.errENU;
    stdUsuario = structusuario.stdENU;
    ENUGlab    = structglab.errENU;
        
    ENUUsuario = ENUUsuario(1:N,:);
    stdUsuario = stdUsuario(1:N,:);
    ENUGlab    = ENUGlab(1:N,:);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = ENUUsuario - ENUGlab;
            tit = ['Diferencia entre errores de posicion en ENU '...
                   'respecto a posicion a priori (Usuario - gLAB)'];
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit(('err Este [m]-err Norte [m]-err Up [m]'),'-');
            graficar3(x,y,tit,ejex,ejey,leg);
        case 3       % si quiero superpuestos
            y1 = ENUUsuario;
            y2 = ENUGlab;
            tit = 'Error de posicion ENU respecto posicion a priori'; 
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit((['err Este Usuario[m]-err Norte Usuario[m]-'...
                             'err Up Usuario[m]-err Este gLAB[m]-'...
                             'err Norte gLAB[m]-err Up gLAB[m]']),'-');
            graficar3sup(x,y1,y2,tit,ejex,ejey,leg);
        case 1       % si quiero el campo de structusuario
            y = ENUUsuario;
            tit = 'Error de posicion en ENU respecto a posicion a priori (Usuario)';
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit(('err Este \pm 3\sigma[m]-err Norte \pm 3\sigma[m]-err Up \pm 3\sigma[m]'),'-');
            graficar3std(x,y,stdUsuario,tit,ejex,ejey,leg);
        case 2       % si quiero el campo de structglab
            y = ENUGlab;
            tit = 'Error de posicion en ENU respecto a posicion a priori (gLAB)';
            ejex = 't [h]';
            ejey = strsplit(('$\Delta  E [m]$-$\Delta  N [m]$-$\Delta  U [m]$'),'-');
            leg  = strsplit(('err Este \pm 3\sigma[m]-err Norte \pm 3\sigma[m]-err Up \pm 3\sigma[m]'),'-');
            graficar3std(x,y,stdUsuario,tit,ejex,ejey,leg);
    end
      
end

% --------------------------- FIN errENU ----------------------------------

% ------------------------ errENUscatter ----------------------------------
if strcmp(grafico,'errENUscatter')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Error Horizontal (ENU)','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    ENUsuario = structusuario.errENU(:,1:2);
    ENGlab    = structglab.errENU(:,1:2);
        
    ENUsuario = ENUsuario(1:N,1:2);
    ENGlab    = ENGlab(1:N,1:2);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = ENUsuario - ENGlab;
            tit = ['Diferencia entre errores en Horizontal '...
                   'respecto a posicion a priori (Usuario - gLAB)'];
            ejex = 'error Este [m]';
            ejey = 'error Norte [m]';
            leg  = 'Error Horizontal (Usuario - gLAB)';
            graficarscatter(y,tit,ejex,ejey,leg);
        case 3       % si quiero superpuestos
            y1 = ENUsuario;
            y2 = ENGlab;
            tit = 'Error Horizonal Usuario y gLAB'; 
            ejex = 'Este [m]';
            ejey = 'Norte [m]';
            leg  = {'Usuario','gLAB'};
            graficarscattersup(y1,y2,5,tit,ejex,ejey,leg);
        case 1       % si quiero el campo de structusuario
            y = ENUsuario;
            tit = 'Error Horizonal Usuario';
            ejex = 'error Este [m]';
            ejey = 'error Norte [m]';
            leg  = 'Error Horizontal (Usuario)';
            graficarscatter(y,tit,ejex,ejey,leg);
        case 2       % si quiero el campo de structglab
            y = ENGlab;
            tit = 'Error Horizonal gLAB';
            ejex = 'error Este [m]';
            ejey = 'error Norte [m]';
            leg  = 'Error Horizontal (gLAB)';
            graficarscatter(y,tit,ejex,ejey,leg);
    end
    
end

% ----------------------- FIN errENUscatter -------------------------------

% ----------------------- corrAPCSatelite ---------------------------------
if strcmp(grafico,'corrAPCSatelite')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Correccion APC Satelite','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    corrusuario = structusuario.gpsSat.Modelo.CorrCentroFaseAntenaSatelite(:,PRN) + ...
                  structusuario.gpsSat.Modelo.CorrVariacionCentroFaseAntenaSatelite(:,PRN);
    corrGLAB    = structglab.gpsSat.Modelo.CorrCentroFaseAntenaSatelite(:,PRN);
        
    corrusuario = corrusuario(1:N,:);
    corrGLAB    = corrGLAB(1:N,:);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = corrusuario - corrGLAB;
            tit = 'Diferencia entre correcciones (APC + PCV) satelite (Usuario - gLAB)';
            ejex = 't [h]';
            ejey = 'error APC + PCV satelite';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 3       % si quiero superpuestos
            y1 = corrusuario;
            y2 = corrGLAB;
            tit = 'Correcciones (APC + PCV) satelite Usuario y gLAB'; 
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1sup(x,y1(:,jj),y2(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 1       % si quiero el campo de structusuario
            y = corrusuario;
            tit = 'Correcciones (APC + PCV) satelite Usuario';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 2       % si quiero el campo de structglab
            y = corrGLAB;
            tit = 'Correcciones (APC + PCV) satelite gLAB';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
    end  
end    
% ---------------------- FincorrAPCSatelite -------------------------------

% ----------------------- corrAPCReceptor ---------------------------------
if strcmp(grafico,'corrAPCReceptor')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Correccion APC Receptor','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    corrusuario = structusuario.gpsSat.Modelo.CorrCentroFaseAntenaReceptor(:,PRN) + ...
                  structusuario.gpsSat.Modelo.CorrVariacionCentroFaseAntenaReceptor(:,PRN);
    corrGLAB    = structglab.gpsSat.Modelo.CorrCentroFaseAntenaReceptor(:,PRN);
        
    corrusuario = corrusuario(1:N,:);
    corrGLAB    = corrGLAB(1:N,:);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = corrusuario - corrGLAB;
            tit = 'Diferencia entre correcciones (APC + PCV) receptor (Usuario - gLAB)';
            ejex = 't [h]';
            ejey = 'error APC + PCV receptor';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 3       % si quiero superpuestos
            y1 = corrusuario;
            y2 = corrGLAB;
            tit = 'Correcciones (APC + PCV) receptor Usuario y gLAB'; 
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1sup(x,y1(:,jj),y2(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 1       % si quiero el campo de structusuario
            y = corrusuario;
            tit = 'Correcciones (APC + PCV) receptor Usuario';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 2       % si quiero el campo de structglab
            y = corrGLAB;
            tit = 'Correcciones (APC + PCV) receptor gLAB';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
    end  
end    
% ---------------------- FincorrAPCReceptor -------------------------------

% ----------------------- corrARPReceptor ---------------------------------
if strcmp(grafico,'corrARPReceptor')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Correccion ARP Receptor','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    corrusuario = structusuario.gpsSat.Modelo.CorrPuntoReferenciaAntena(:,PRN);
    corrGLAB    = structglab.gpsSat.Modelo.CorrPuntoReferenciaAntena(:,PRN);
        
    corrusuario = corrusuario(1:N,:);
    corrGLAB    = corrGLAB(1:N,:);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = corrusuario - corrGLAB;
            tit = 'Diferencia entre correcciones ARP receptor (Usuario - gLAB)';
            ejex = 't [h]';
            ejey = 'error ARP receptor';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 3       % si quiero superpuestos
            y1 = corrusuario;
            y2 = corrGLAB;
            tit = 'Correcciones ARP receptor Usuario y gLAB'; 
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1sup(x,y1(:,jj),y2(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 1       % si quiero el campo de structusuario
            y = corrusuario;
            tit = 'Correcciones ARP receptor Usuario';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 2       % si quiero el campo de structglab
            y = corrGLAB;
            tit = 'Correcciones ARP receptor gLAB';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
    end  
end    
% ---------------------- FincorrARPReceptor -------------------------------

% --------------------------- corrWindUp ----------------------------------
if strcmp(grafico,'corrWindUp')

	figure('units','normalized','outerposition',[0 0 1 1],...
		   'Name','Correccion por WindUp','NumberTitle','off');

	t1  = structusuario.tR;       % vector tR del usuario
	t2  = structglab.tR;          % vector tR del gLAB
	dim = min(size(t1),size(t2)); % me fijo cual es mas corto
	N   = dim(1);
	x   = (t1(1:N) - t1(1))/3600; % inicio t en 0 y en horas
    
    corrusuario = structusuario.gpsSat.Modelo.CorrWindUp(:,PRN);
    corrGLAB    = structglab.gpsSat.Modelo.CorrWindUp(:,PRN);
        
    corrusuario = corrusuario(1:N,:);
    corrGLAB    = corrGLAB(1:N,:);
        
    switch opt
        case 0       % si quiero la resta entre glab y matlab
            y = corrusuario - corrGLAB;
            tit = 'Diferencia entre correcciones WindUp (Usuario - gLAB)';
            ejex = 't [h]';
            ejey = 'error corr WindUp';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 3       % si quiero superpuestos
            y1 = corrusuario;
            y2 = corrGLAB;
            tit = 'Correcciones WindUp receptor Usuario y gLAB'; 
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1sup(x,y1(:,jj),y2(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 1       % si quiero el campo de structusuario
            y = corrusuario;
            tit = 'Correcciones WindUp receptor Usuario';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
        case 2       % si quiero el campo de structglab
            y = corrGLAB;
            tit = 'Correcciones WindUp receptor gLAB';
            ejex = 't [h]';
            ejey = '[m]';
            leg = ' ';
            for jj=1:length(PRN)
                Legend{jj} = strcat('PRN    ', num2str(PRN(jj)));
                graficar1(x,y(:,jj),tit,ejex,ejey,leg);hold on;
            end
            legend(Legend)
    end  
end    
% ---------------------- FincorrWindUp ------------------------------------

% funcion para graficar variable (1x1)
function graficar1(xx,yy,tit,ejex,ejey,leg)
    plot(xx,yy,'LineWidth',2);grid on;
    axis tight;set(gca, 'Fontsize',15);
    legend(leg,'Location','SouthEast');
    xlabel(ejex,'Interpreter','Latex');
    ylabel(ejey,'Interpreter','Latex');
    title(tit);
end
       
% funcion para graficar variable (1x1) superponiendo
function graficar1sup(xx,y1,y2,tit,ejex,ejey,leg)
    plot(xx,y1,'LineWidth',2);hold on;grid on;
    plot(xx,y2,'LineWidth',2);
    axis tight;set(gca, 'Fontsize',15);
    legend(leg,'Location','SouthEast');
    xlabel(ejex,'Interpreter','Latex');
    ylabel(ejey,'Interpreter','Latex');
    title(tit);
end

% funcion para graficar variables (3x1)    
function graficar3(xx,yy,tit,ejex,ejey,leg)
    colors = strsplit(['g.- ', 'b.- ', 'r.-']);
    for ii = 1:3
        subplot(3,1,ii)
        plot(xx,yy(:,ii),colors{ii});grid on;
        axis tight;set(gca, 'Fontsize',15);
        legend(leg{ii},'Location','SouthEast');
        ylabel(ejey{ii},'Interpreter','Latex');
        if ii == 1
            title(tit);
        end
        if ii == 3
            xlabel(ejex,'Interpreter','Latex');
        end            
    end
end
% funcion para graficar variables (3x1) superponiendo matlab y glab
function graficar3sup(xx,y1,y2,tit,ejex,ejey,leg)
    colors = strsplit(['g.- ', 'b.- ', 'r.- ','--ro ','--go ','--bo']);
    for ii = 1:3
        subplot(3,1,ii)
        plot(xx,y1(:,ii),colors{ii},'MarkerSize',1.5);hold on;grid on;
        plot(xx,y2(:,ii),colors{ii+3},'MarkerSize',1.5);
        axis tight;set(gca, 'Fontsize',15);
        legend(leg{ii},leg{ii+3},'Location','SouthEast');
        ylabel(ejey{ii},'Interpreter','Latex');
        if ii == 1
            title(tit);
        end
        if ii == 3
            xlabel(ejex,'Interpreter','Latex');
        end    
    end
end
% funcion para graficar variables (3x1) superponiendo intervalo confianza
function graficar3std(xx,y1,std,tit,ejex,ejey,leg)
    colors = strsplit(['g.- ', 'b.- ', 'r.- ','--ko ','--ko ','--ko']);
    for ii = 1:3
        subplot(3,1,ii)
        plot(xx,y1(:,ii),colors{ii},'MarkerSize',1.5);hold on;grid on;
        plot(xx,y1(:,ii)+3*std(:,ii),colors{ii+3},'MarkerSize',1.5);
        plot(xx,y1(:,ii)-3*std(:,ii),colors{ii+3},'MarkerSize',1.5);
        axis tight;set(gca, 'Fontsize',15);
        legend(leg{ii},'Location','SouthEast');
        ylabel(ejey{ii},'Interpreter','Latex');
        if ii == 1
            title(tit);
        end
        if ii == 3
            xlabel(ejex,'Interpreter','Latex');
        end            
    end
end
% funcion para hacer gráficos scatter (tipo constelación)
function graficarscatter(yy,tit,ejex,ejey,leg)
    c = linspace(1,500,length(yy));
    scatter(yy(:,1),yy(:,2),[],c,'o','filled');grid on;
    axis([-2 2 -2 2]);set(gca, 'Fontsize',15);
    legend(leg,'Location','SouthEast');
    title(tit);
    ylabel(ejey,'Interpreter','Latex');
    xlabel(ejex,'Interpreter','Latex');   
end
  % funcion para hacer gráficos scatter superpuestos(tipo constelación)
function graficarscattersup(yy,zz,M,tit,ejex,ejey,leg)
    c = linspace(1,500,length(yy(1:M:end,1)));
    scatter(yy(1:M:end,1),yy(1:M:end,2),[],c,'o');grid on;hold on;
    scatter(zz(1:M:end,1),zz(1:M:end,2),[],c,'x'); 
    axis equal;set(gca, 'Fontsize',15);
    legend(leg,'Location','SouthEast');
    title(tit);
    ylabel(ejey,'Interpreter','Latex');
    xlabel(ejex,'Interpreter','Latex');   
end      
        
end

