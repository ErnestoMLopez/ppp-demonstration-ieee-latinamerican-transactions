function [navSolPT] = resolverPosicionBancroft(ps,pr)
%RESOLVERPOSICIONBANCROFT Resolución de las ecuaciones de GPS
% Resuelve la posición y el sesgo de reloj de receptor a partir de las
% ecuaciones de GPS mediante el método de Bancroft, el cual no requiere
% conocimiento previo de la posición del usuario.
% 
% ARGUMENTOS:
%	ps (JJx3) - Matriz con las posiciones de los satélites de la constelación 
%				GPS visibles en el instante de observación
%	pr (JJx1) - Vector con los pseudorangos de los satélites vistos, previamente
%				corregidos por reloj de satélite, corrección relativista, 
%				ionósfera, etc.


navSolA = zeros(4,1);
navSolB = zeros(4,1);


JJ = size(ps,1);

A = zeros(JJ,4);
C = zeros(JJ,1);
R = zeros(4,4);
q1 = zeros(4,1);
q2 = zeros(4,1);
u = zeros(4,1);
v = zeros(4,1);

A = [ps pr] / 2e+007;

for jj = 1:JJ
	C(jj) = (sum(A(jj,1:3).*A(jj,1:3)) - A(jj,4).*A(jj,4)) / 2.0;
end


%	// QR de la matriz A, quedando Q en A al finalizar (por Gram-Schmidt)
%	// En la diagonal principal de R deberi'an ir unos, en su lugar se
%	// guarda la norma cuadrado de las columnas de Q.

for k = 1:4 %//k es el i'ndice de las filas de R
	
	R(k,k) = 0.0;
	
	for i = 1:JJ %//i es el i'ndice de las filas de A
		R(k,k) = R(k,k) + A(i,k) * A(i,k);
	end
	
	if(k < 4)	
		
		for j = (k+1) : 4
			
			R(k,j) = 0.0;
			
			for i = 1:JJ
				
				R(k,j) = R(k,j) + A(i,k) * A(i,j);
				
			end
			
			R(k,j) = R(k,j) / R(k,k);
			
			for i = 1:JJ
				
				A(i,j) = A(i,j) - R(k,j) * A(i,k);
				
			end
			
		end
		
	end
end



for j = 1:4
	
	q1(j) = 0.0;
	q2(j) = 0.0;
	
	for i = 1:JJ
		
		q1(j) = q1(j) + A(i,j);
		q2(j) = q2(j) + A(i,j) * C(i);
		
	end
	q1(j) = q1(j) / R(j,j);
	q2(j) = q2(j) / R(j,j);
	
end


%// CÃ¡lculo de u y v por retrosustituciÃ³n.
for i = 4:-1:1
	
	u(i) = q1(i);
	v(i) = q2(i);
	
	if(i < 4)
		
		for j = (i+1) : 4
			
			u(i) = u(i) - R(i,j) * u(j);
			v(i) = v(i) - R(i,j) * v(j);
			
		end
		
	end
	
end

%u
%v
%// DesnormalizaciÃ³n de u y v.
for j = 1:4
	
	u(j) = u(j) / 2e+007;
	v(j) = v(j) * 2e+007;
	
end

%// CÃ¡lculo de los coef. de la ecuaciÃ³n cuadrÃ¡tica de lambda.
a = -u(4) * u(4);
b = -u(4) * v(4) - 1.0;
c = -v(4) * v(4);

for j = 1:3
	
	a = a + u(j) * u(j);
	b = b + u(j) * v(j);
	c = c + v(j) * v(j);
	
end
b = b * 2.0;

%a
%b
%c

%/* discriminante de baskara */
d = b*b - 4.0*a*c;

%/* Prevengo que calcule raÃ­z cuadrada de un nÃºmero negativo. Retorno error */
if(d < 0.0)
	FAILURE = 1;
	errorType = FAILURE;
	
	navSolPT = NaN(4,1);
	return;
	
end

d = sqrt(d);


%/* Primera solución */
lambda = (- b - d) / (a * 2.0);

for i = 1:3	
	navSolA(i) = u(i) * lambda + v(i);	
end
navSolA(4) = -u(4) *lambda - v(4);


%/* Segunda solución */
lambda = (- b + d) / (a * 2.0);

for i = 1:3	
	navSolB(i) = u(i) * lambda + v(i);	
end
navSolB(4) = -u(4) *lambda - v(4);


	

%/* Bancroft retorna ok, pero hay que ver cual de las dos soluciones es valida. */

%/* Se calculan los rangos a partir de la posiciÃ³n del satÃ©lite y cadauna de las dos
% * soluciones de bancroft */
navTestA = navCalculateMeasurementsTrueRange(ps, navSolA);
navTestB = navCalculateMeasurementsTrueRange(ps, navSolB);

%/* Utilizando los rangos se calculan los residuos totales de cada una de las soluciones */
navTestA = navCalculateMeasurementsTrueRangeResidue(pr, navSolA, navTestA);
navTestB = navCalculateMeasurementsTrueRangeResidue(pr, navSolB, navTestB);

%/* Apartir de los residuos se determina cual de las dos es la solución posta */
if(navTestA.prResSquareAccum < navTestB.prResSquareAccum)
	navSolPT = navSolA;
else
	navSolPT = navSolB;
end
	


end





%--------------------------------------------------------------------------
function navTest = navCalculateMeasurementsTrueRange(ps, navSol)

N_SVS = size(ps,1);

navTest = struct(...
    'los',              zeros(N_SVS,3),...  /* Vector de línea vista normalizado */
    'range',            zeros(N_SVS,1),...
    'drange',           zeros(N_SVS,1),...
    ...
    'prResidue',        zeros(N_SVS,1),...
    'drResidue',        zeros(N_SVS,1),...
    ...
    'prResSquareAccum', 0,...
    'drResSquareAccum', 0 ...
);

for i = 1:N_SVS
       
	% Linea de vista
	los = ps(i,:) - navSol(1:3)';
	
	% Norma del vector linea vista
	losNorm = sqrt(sum(los.^2));
	
	% Se obtiene el rango y el pseudo-rango estimado.
	navTest.range(i)	 	= losNorm;
	
	% Se obtiene el vector de linea vista normalizado
	navTest.los(i,:) 		= los./losNorm;
		
end
end


%--------------------------------------------------------------------------
function [navTest] = navCalculateMeasurementsTrueRangeResidue(pseudorangos, navSol, navTest)

N_SVS = length(pseudorangos);

resSquareAccum = 0.0;
n = 0;

for i = 1:N_SVS
	
	navTest.prResidue(i) = pseudorangos(i) - navTest.range(i) - navSol(4);
	
	resSquareAccum = resSquareAccum + navTest.prResidue(i).^2;
	
	n = n+1;
	
end

navTest.prResSquareAccum = resSquareAccum;

end