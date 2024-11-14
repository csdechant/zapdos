clear
clc

file_name = '2D_Coupling_Electons_Potential_Ions_MeanEnergy_Refinement';

refine_00 = csvread(string(file_name)+'00_out.csv',1,0);

h_refine_00 = refine_00(end-1,3);
h_avg_refine_00 = sum(h_refine_00)/length(h_refine_00);
em_refine_00 = refine_00(end-1,2);
em_avg_refine_00 = sum(em_refine_00)/length(em_refine_00);
ion_refine_00 = refine_00(end-1,4);
ion_avg_refine_00 = sum(ion_refine_00)/length(ion_refine_00);
pot_refine_00 = refine_00(end-1,6);
pot_avg_refine_00 = sum(pot_refine_00)/length(pot_refine_00);
mean_refine_00 = refine_00(end-1,5);
mean_avg_refine_00 = sum(mean_refine_00)/length(mean_refine_00);



refine_01 = csvread(string(file_name)+'01_out.csv',1,0);

h_refine_01 = refine_01(end-1,3);
h_avg_refine_01 = sum(h_refine_01)/length(h_refine_01);
em_refine_01 = refine_01(end-1,2);
em_avg_refine_01 = sum(em_refine_01)/length(em_refine_01);
ion_refine_01 = refine_01(end-1,4);
ion_avg_refine_01 = sum(ion_refine_01)/length(ion_refine_01);
pot_refine_01 = refine_01(end-1,6);
pot_avg_refine_01 = sum(pot_refine_01)/length(pot_refine_01);
mean_refine_01 = refine_01(end-1,5);
mean_avg_refine_01 = sum(mean_refine_01)/length(mean_refine_01);

refine_02 = csvread(string(file_name)+'02_out.csv',1,0);

h_refine_02 = refine_02(end-1,3);
h_avg_refine_02 = sum(h_refine_02)/length(h_refine_02);
em_refine_02 = refine_02(end-1,2);
em_avg_refine_02 = sum(em_refine_02)/length(em_refine_02);
ion_refine_02 = refine_02(end-1,4);
ion_avg_refine_02 = sum(ion_refine_02)/length(ion_refine_02);
pot_refine_02 = refine_02(end-1,6);
pot_avg_refine_02 = sum(pot_refine_02)/length(pot_refine_02);
mean_refine_02 = refine_02(end-1,5);
mean_avg_refine_02 = sum(mean_refine_02)/length(mean_refine_02);

h = [h_avg_refine_00, h_avg_refine_01, h_avg_refine_02];
em = [em_avg_refine_00, em_avg_refine_01, em_avg_refine_02];
ion = [ion_avg_refine_00, ion_avg_refine_01, ion_avg_refine_02];
pot = [pot_avg_refine_00, pot_avg_refine_01, pot_avg_refine_02];
mean = [mean_avg_refine_00, mean_avg_refine_01, mean_avg_refine_02];

figure
loglog(h,em,'-r*')
hold on
plot(h,ion,'-b*')
hold on
plot(h,pot,'-k*')
hold on
plot(h,mean,'-g*')
hold off

em_s = polyfit(log(h),log(em),1)
ion_s = polyfit(log(h),log(ion),1)
pot_s = polyfit(log(h),log(pot),1)
mean_s = polyfit(log(h),log(mean),1)

text = 'next'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


file_name = 'FV_2D_Coupling_Electons_Potential_Ions_MeanEnergy_Refinement';

refine_00 = csvread(string(file_name)+'00_out.csv',1,0);

h_refine_00 = refine_00(end-1,3);
h_avg_refine_00 = sum(h_refine_00)/length(h_refine_00);
em_refine_00 = refine_00(end-1,2);
em_avg_refine_00 = sum(em_refine_00)/length(em_refine_00);
ion_refine_00 = refine_00(end-1,4);
ion_avg_refine_00 = sum(ion_refine_00)/length(ion_refine_00);
pot_refine_00 = refine_00(end-1,6);
pot_avg_refine_00 = sum(pot_refine_00)/length(pot_refine_00);
mean_refine_00 = refine_00(end-1,5);
mean_avg_refine_00 = sum(mean_refine_00)/length(mean_refine_00);



refine_01 = csvread(string(file_name)+'01_out.csv',1,0);

h_refine_01 = refine_01(end-1,3);
h_avg_refine_01 = sum(h_refine_01)/length(h_refine_01);
em_refine_01 = refine_01(end-1,2);
em_avg_refine_01 = sum(em_refine_01)/length(em_refine_01);
ion_refine_01 = refine_01(end-1,4);
ion_avg_refine_01 = sum(ion_refine_01)/length(ion_refine_01);
pot_refine_01 = refine_01(end-1,6);
pot_avg_refine_01 = sum(pot_refine_01)/length(pot_refine_01);
mean_refine_01 = refine_01(end-1,5);
mean_avg_refine_01 = sum(mean_refine_01)/length(mean_refine_01);

refine_02 = csvread(string(file_name)+'02_out.csv',1,0);

h_refine_02 = refine_02(end-1,3);
h_avg_refine_02 = sum(h_refine_02)/length(h_refine_02);
em_refine_02 = refine_02(end-1,2);
em_avg_refine_02 = sum(em_refine_02)/length(em_refine_02);
ion_refine_02 = refine_02(end-1,4);
ion_avg_refine_02 = sum(ion_refine_02)/length(ion_refine_02);
pot_refine_02 = refine_02(end-1,6);
pot_avg_refine_02 = sum(pot_refine_02)/length(pot_refine_02);
mean_refine_02 = refine_02(end-1,5);
mean_avg_refine_02 = sum(mean_refine_02)/length(mean_refine_02);

h = [h_avg_refine_00, h_avg_refine_01, h_avg_refine_02];
em = [em_avg_refine_00, em_avg_refine_01, em_avg_refine_02];
ion = [ion_avg_refine_00, ion_avg_refine_01, ion_avg_refine_02];
pot = [pot_avg_refine_00, pot_avg_refine_01, pot_avg_refine_02];
mean = [mean_avg_refine_00, mean_avg_refine_01, mean_avg_refine_02];

figure
loglog(h,em,'-r*')
hold on
plot(h,ion,'-b*')
hold on
plot(h,pot,'-k*')
hold on
plot(h,mean,'-g*')
hold off

em_s = polyfit(log(h),log(em),1)
ion_s = polyfit(log(h),log(ion),1)
pot_s = polyfit(log(h),log(pot),1)
mean_s = polyfit(log(h),log(mean),1)

text = 'next'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


file_name = 'FV-FE_2D_Coupling_Electons_Potential_Ions_MeanEnergy_Refinement';

refine_00 = csvread(string(file_name)+'00_out.csv',1,0);

h_refine_00 = refine_00(end-1,3);
h_avg_refine_00 = sum(h_refine_00)/length(h_refine_00);
em_refine_00 = refine_00(end-1,2);
em_avg_refine_00 = sum(em_refine_00)/length(em_refine_00);
ion_refine_00 = refine_00(end-1,4);
ion_avg_refine_00 = sum(ion_refine_00)/length(ion_refine_00);
pot_refine_00 = refine_00(end-1,6);
pot_avg_refine_00 = sum(pot_refine_00)/length(pot_refine_00);
mean_refine_00 = refine_00(end-1,5);
mean_avg_refine_00 = sum(mean_refine_00)/length(mean_refine_00);



refine_01 = csvread(string(file_name)+'01_out.csv',1,0);

h_refine_01 = refine_01(end-1,3);
h_avg_refine_01 = sum(h_refine_01)/length(h_refine_01);
em_refine_01 = refine_01(end-1,2);
em_avg_refine_01 = sum(em_refine_01)/length(em_refine_01);
ion_refine_01 = refine_01(end-1,4);
ion_avg_refine_01 = sum(ion_refine_01)/length(ion_refine_01);
pot_refine_01 = refine_01(end-1,6);
pot_avg_refine_01 = sum(pot_refine_01)/length(pot_refine_01);
mean_refine_01 = refine_01(end-1,5);
mean_avg_refine_01 = sum(mean_refine_01)/length(mean_refine_01);

refine_02 = csvread(string(file_name)+'02_out.csv',1,0);

h_refine_02 = refine_02(end-1,3);
h_avg_refine_02 = sum(h_refine_02)/length(h_refine_02);
em_refine_02 = refine_02(end-1,2);
em_avg_refine_02 = sum(em_refine_02)/length(em_refine_02);
ion_refine_02 = refine_02(end-1,4);
ion_avg_refine_02 = sum(ion_refine_02)/length(ion_refine_02);
pot_refine_02 = refine_02(end-1,6);
pot_avg_refine_02 = sum(pot_refine_02)/length(pot_refine_02);
mean_refine_02 = refine_02(end-1,5);
mean_avg_refine_02 = sum(mean_refine_02)/length(mean_refine_02);

h = [h_avg_refine_00, h_avg_refine_01, h_avg_refine_02];
em = [em_avg_refine_00, em_avg_refine_01, em_avg_refine_02];
ion = [ion_avg_refine_00, ion_avg_refine_01, ion_avg_refine_02];
pot = [pot_avg_refine_00, pot_avg_refine_01, pot_avg_refine_02];
mean = [mean_avg_refine_00, mean_avg_refine_01, mean_avg_refine_02];

figure
loglog(h,em,'-r*')
hold on
plot(h,ion,'-b*')
hold on
plot(h,pot,'-k*')
hold on
plot(h,mean,'-g*')
hold off

em_s = polyfit(log(h),log(em),1)
ion_s = polyfit(log(h),log(ion),1)
pot_s = polyfit(log(h),log(pot),1)
mean_s = polyfit(log(h),log(mean),1)

text = 'next'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


file_name = 'FV_2D_Coupling_Electons_Potential_Ions_MeanEnergy_Refinement';

refine_00 = csvread(string(file_name)+'01_out.csv',1,0);

h_refine_00 = refine_00(end-1,3);
h_avg_refine_00 = sum(h_refine_00)/length(h_refine_00);
em_refine_00 = refine_00(end-1,2);
em_avg_refine_00 = sum(em_refine_00)/length(em_refine_00);
ion_refine_00 = refine_00(end-1,4);
ion_avg_refine_00 = sum(ion_refine_00)/length(ion_refine_00);
pot_refine_00 = refine_00(end-1,6);
pot_avg_refine_00 = sum(pot_refine_00)/length(pot_refine_00);
mean_refine_00 = refine_00(end-1,5);
mean_avg_refine_00 = sum(mean_refine_00)/length(mean_refine_00);



refine_01 = csvread(string(file_name)+'02_out.csv',1,0);

h_refine_01 = refine_01(end-1,3);
h_avg_refine_01 = sum(h_refine_01)/length(h_refine_01);
em_refine_01 = refine_01(end-1,2);
em_avg_refine_01 = sum(em_refine_01)/length(em_refine_01);
ion_refine_01 = refine_01(end-1,4);
ion_avg_refine_01 = sum(ion_refine_01)/length(ion_refine_01);
pot_refine_01 = refine_01(end-1,6);
pot_avg_refine_01 = sum(pot_refine_01)/length(pot_refine_01);
mean_refine_01 = refine_01(end-1,5);
mean_avg_refine_01 = sum(mean_refine_01)/length(mean_refine_01);

refine_02 = csvread(string(file_name)+'03_out.csv',1,0);

h_refine_02 = refine_02(end-1,3);
h_avg_refine_02 = sum(h_refine_02)/length(h_refine_02);
em_refine_02 = refine_02(end-1,2);
em_avg_refine_02 = sum(em_refine_02)/length(em_refine_02);
ion_refine_02 = refine_02(end-1,4);
ion_avg_refine_02 = sum(ion_refine_02)/length(ion_refine_02);
pot_refine_02 = refine_02(end-1,6);
pot_avg_refine_02 = sum(pot_refine_02)/length(pot_refine_02);
mean_refine_02 = refine_02(end-1,5);
mean_avg_refine_02 = sum(mean_refine_02)/length(mean_refine_02);

h = [h_avg_refine_01, h_avg_refine_02];
em = [em_avg_refine_01, em_avg_refine_02];
ion = [ion_avg_refine_01, ion_avg_refine_02];
pot = [pot_avg_refine_01, pot_avg_refine_02];
mean = [mean_avg_refine_01, mean_avg_refine_02];

figure
loglog(h,em,'-r*')
hold on
plot(h,ion,'-b*')
hold on
plot(h,pot,'-k*')
hold on
plot(h,mean,'-g*')
hold off

em_s = polyfit(log(h),log(em),1)
ion_s = polyfit(log(h),log(ion),1)
pot_s = polyfit(log(h),log(pot),1)
mean_s = polyfit(log(h),log(mean),1)

text = 'refine01-next'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


file_name = 'FV-FE_2D_Coupling_Electons_Potential_Ions_MeanEnergy_Refinement';

refine_00 = csvread(string(file_name)+'01_out.csv',1,0);

h_refine_00 = refine_00(end-1,3);
h_avg_refine_00 = sum(h_refine_00)/length(h_refine_00);
em_refine_00 = refine_00(end-1,2);
em_avg_refine_00 = sum(em_refine_00)/length(em_refine_00);
ion_refine_00 = refine_00(end-1,4);
ion_avg_refine_00 = sum(ion_refine_00)/length(ion_refine_00);
pot_refine_00 = refine_00(end-1,6);
pot_avg_refine_00 = sum(pot_refine_00)/length(pot_refine_00);
mean_refine_00 = refine_00(end-1,5);
mean_avg_refine_00 = sum(mean_refine_00)/length(mean_refine_00);



refine_01 = csvread(string(file_name)+'02_out.csv',1,0);

h_refine_01 = refine_01(end-1,3);
h_avg_refine_01 = sum(h_refine_01)/length(h_refine_01);
em_refine_01 = refine_01(end-1,2);
em_avg_refine_01 = sum(em_refine_01)/length(em_refine_01);
ion_refine_01 = refine_01(end-1,4);
ion_avg_refine_01 = sum(ion_refine_01)/length(ion_refine_01);
pot_refine_01 = refine_01(end-1,6);
pot_avg_refine_01 = sum(pot_refine_01)/length(pot_refine_01);
mean_refine_01 = refine_01(end-1,5);
mean_avg_refine_01 = sum(mean_refine_01)/length(mean_refine_01);

refine_02 = csvread(string(file_name)+'03_out.csv',1,0);

h_refine_02 = refine_02(end-1,3);
h_avg_refine_02 = sum(h_refine_02)/length(h_refine_02);
em_refine_02 = refine_02(end-1,2);
em_avg_refine_02 = sum(em_refine_02)/length(em_refine_02);
ion_refine_02 = refine_02(end-1,4);
ion_avg_refine_02 = sum(ion_refine_02)/length(ion_refine_02);
pot_refine_02 = refine_02(end-1,6);
pot_avg_refine_02 = sum(pot_refine_02)/length(pot_refine_02);
mean_refine_02 = refine_02(end-1,5);
mean_avg_refine_02 = sum(mean_refine_02)/length(mean_refine_02);

h = [h_avg_refine_01, h_avg_refine_02];
em = [em_avg_refine_01, em_avg_refine_02];
ion = [ion_avg_refine_01, ion_avg_refine_02];
pot = [pot_avg_refine_01, pot_avg_refine_02];
mean = [mean_avg_refine_01, mean_avg_refine_02];

figure
loglog(h,em,'-r*')
hold on
plot(h,ion,'-b*')
hold on
plot(h,pot,'-k*')
hold on
plot(h,mean,'-g*')
hold off

em_s = polyfit(log(h),log(em),1)
ion_s = polyfit(log(h),log(ion),1)
pot_s = polyfit(log(h),log(pot),1)
mean_s = polyfit(log(h),log(mean),1)

text = 'refine01-next'
