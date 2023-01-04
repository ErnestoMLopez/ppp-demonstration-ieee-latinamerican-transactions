function [xo] = intRK4(f,t,xi,h)
%INTRK4 Integrador numérico Runge-Kutta de orden 4
%   Realiza la integración de la función f en un paso fijo h, evaluada en
%   un tiempo t y condiciones iniciales xi.
%	Si la función es vectorial columna entonces las condiciones iniciales
%	deben ser dadas en un vector columna

I1 = f(t,		xi);
I2 = f(t+h/2,	xi+h/2*I1);
I3 = f(t+h/2,	xi+h/2*I2);
I4 = f(t+h,		xi+h*I3);

xo = xi + h/6.*(I1+2*I2+2*I3+I4);

end

