function [dim] = daysInMonth(YYYY,MM)
%DAYSINMONTH Retorna el numero de días en el mes especificado

lp = leapyear(YYYY);

switch MM
	case 1
		dim = 31;
	case 2 
		if lp == 1
			dim = 29;
		else
			dim = 28;
		end
	case 3
		dim = 31;
	case 4
		dim = 30;
	case 5
		dim = 31;
	case 6
		dim = 30;
	case 7 
		dim = 31;
	case 8
		dim = 31;
	case 9 
		dim = 30;
	case 10 
		dim = 31;
	case 11 
		dim = 30;
	case 12
		dim = 31;
	otherwise
		error('Mes erroneo');
		
end

end