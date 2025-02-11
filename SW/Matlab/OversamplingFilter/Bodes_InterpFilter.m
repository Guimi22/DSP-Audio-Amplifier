clc; clear all;

%% Disseny Filtre CIC Interpolador
R = 16;          % Interpolation rate of upsampling
M = 1;           % Differential delay size of comb sections 
N = 5;           % Number of stages or order of the filter

cicInterp = dsp.CICInterpolator(R,M,N);

freqRange = linspace(0, 3, 2048);

[H, W] = freqz(cicInterp, freqRange);

gain_correction = 1/(R^N);

%% Diagrama de Bode Filtre CIC

figure(1);
tiledlayout;
nexttile;
plot(W/pi, 20*log10(gain_correction * abs(H)), 'b', 'LineWidth', 1.5);
ylim([-150 10]);
title('Filtre CIC Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Magnitud (dB)');

nexttile;
phaseCIC = phasez(cicInterp,freqRange);
plot(W/pi, phaseCIC, 'b', 'LineWidth', 1.5);
title('Filtre CIC Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Desfassament (rad)');

%% Disseny Filtre Compensació CIC

fs = 44100;
fPass = 20000;
fStop = 22050;
ast = 80;

CICCompInterp = dsp.CICCompensationInterpolator(cicInterp,...
    InterpolationFactor=2,PassbandFrequency=fPass, ...
    StopbandFrequency=fStop,StopbandAttenuation=ast, ...
    SampleRate=fs)

[H2, W2] = freqz(CICCompInterp, freqRange);

coeff_CompCIC = coeffs(CICCompInterp);
coeff_CompCIC.Numerator(77) = 1;
valors_CICComp = round(coeff_CompCIC.Numerator*power(2,17)-1);

%% Diagrama de Bode Filtre Compensació CIC

figure(2);
tiledlayout;
nexttile;
plot(W2/pi, 20*log10(abs(H2)), 'b', 'LineWidth', 1.5);
ylim([-100 20]);
title('Filtre Compensació Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Magnitud (dB)');

nexttile;
phaseCICComp = phasez(CICCompInterp,freqRange);
plot(W2/pi, phaseCICComp, 'b', 'LineWidth', 1.5);
title('Filtre Compensació en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Desfassament (rad)');

%%  Etapa de Filtrat Final

FC = dsp.FilterCascade(CICCompInterp, cicInterp);
[H3, W3] = freqz(FC, freqRange);

%% Diagrama de Bode de l'Etapa de filtrat.

figure(3);
tiledlayout;
nexttile;
plot(W3/pi, 20*log10((gain_correction/2) * abs(H3)), 'b', 'LineWidth', 1.5);
ylim([-150 10]);
title('Etapa de Filtrat Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Magnitud (dB)');
xlim([0 0.15]);

nexttile;
phaseFC = phasez(FC,freqRange);
plot(W3/pi, phaseFC, 'b', 'LineWidth', 1.5);
title('Etapa de Filtrat Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Desfassament (rad)');
xlim([0 0.15]);

%% Càlculs de l'Etapa de filtrat
indH = find((gain_correction/2)*abs(H3) < sqrt(1/2), 1, 'first');
slopeH = (gain_correction/2)*(abs(H3(indH)) - abs(H3(indH - 1))) / (W3(indH) - W3(indH - 1));
w_3dBH = ( sqrt(1/2) - (gain_correction/2)*abs(H3(indH - 1)) + slopeH * W3(indH - 1) )/(slopeH);

f_start = 2*pi()*20/(32*44.1e3); 
f_end = w_3dBH; 
band_idx = (W3 >= f_start & W3 <= f_end); 

% Obtener la magnitud en dB dentro de la banda de paso
mag_dB = 20*log10((gain_correction/2)*abs(H3(band_idx)));

% Calcular la variación en la banda de paso
variacion = max(mag_dB) - min(mag_dB);

% Mostrar resultados
fprintf('La variación en la banda de paso es %.2f dB\n', variacion);

%% Disseny Filtre CIC Delmat
R_d = 4;          % Interpolation rate of upsampling
M_d = 1;           % Differential delay size of comb sections 
N_d = 5;           % Number of stages or order of the filter

cicDecim = dsp.CICDecimator(R_d,M_d,N_d);

[H4, W4] = freqz(cicDecim, freqRange);

gain_correctionDec = (R_d^N_d);

%% Diagrama de Bode Filtre CIC Delmat

figure(4);
tiledlayout;
nexttile;
plot(W4/pi, 20*log10(abs(H4)), 'b', 'LineWidth', 1.5);
ylim([-150 100]);
title('Filtre CIC Delmat Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Magnitud (dB)');

nexttile;
phaseCICDec = phasez(cicDecim,freqRange);
plot(W4/pi, phaseCICDec, 'b', 'LineWidth', 1.5);
title('Filtre CIC Delmat Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Desfassament (rad)');

%% Disseny Filtre Compensació CIC Delmat

fs_d = 352800;
fPass_d = 44200;
fStop_d = 48000;
ast_d = 80;

CICCompDecim = dsp.CICCompensationDecimator(cicDecim,...
    DecimationFactor=2,PassbandFrequency=fPass_d,...
    StopbandFrequency=fStop_d,StopbandAttenuation=ast_d, ...
    SampleRate=fs_d);

[H5, W5] = freqz(CICCompDecim, freqRange);

coeff_CompCIC_Dec = coeffs(CICCompDecim);
coeff_CompCIC_Dec.Numerator(77) = 1;
valors_CICComp_Dec = round(coeff_CompCIC_Dec.Numerator*power(2,17)-1);

%% Diagrama de Bode Filtre Compensació CIC Delmat

figure(5);
tiledlayout;
nexttile;
plot(W5/pi, 20*log10(abs(H5)), 'b', 'LineWidth', 1.5);
ylim([-100 20]);
title('Filtre Compensació Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Magnitud (dB)');

nexttile;
phaseCICComp_d = phasez(CICCompDecim,freqRange);
plot(W5/pi, phaseCICComp_d, 'b', 'LineWidth', 1.5);
title('Filtre Compensació Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Desfassament (rad)');

%%  Etapa de Filtrat Final

FC_D = dsp.FilterCascade(CICCompDecim, cicDecim);
[H6, W6] = freqz(FC_D, freqRange);

%% Diagrama de Bode de l'Etapa de filtrat.

figure(6);
tiledlayout;
nexttile;
plot(W6/pi, 20*log10(abs(H6)), 'b', 'LineWidth', 1.5);
ylim([-150 100]);
title('Etapa de Filtrat Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Magnitud (dB)');

nexttile;
phaseFC_d = phasez(FC_D,freqRange);
plot(W6/pi, phaseFC_d, 'b', 'LineWidth', 1.5);
title('Etapa de Filtrat Resposta en Freqüència');
xlabel('Freqüència Normalitzada (\times\pi rad/mostra)');
ylabel('Desfassament (rad)');

