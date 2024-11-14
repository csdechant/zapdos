clc
clear

data = csvread('FV-FE_2D_Coupling_Electons_Potential_Ions.csv',1,0);

h = data(:,2);
em = data(:,3);
ion = data(:,4);
pot = data(:,5);

figure
loglog(h,em,'--x')
hold on
loglog(h,ion,'--x')
hold on
loglog(h,pot,'--x')
hold off

p_em = polyfit(h,em,1)
p_ion = polyfit(h,ion,1)
p_pot = polyfit(h,pot,1)