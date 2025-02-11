%%% Sigma Delta Modulator
%%% The following code is created in order to find the behavior of the
%%% implemented block in vhdl. In this case, a second order modulator
%%% is designed.

clear all; clc;

syms z w;
Ts = 708.6e-9;
z_freq_tr = cos(w*Ts) + 1i*sin(w*Ts);

%% Gain correction coefficients after delta sub-block in loop filter
a1 = 0.5;
a2 = 0.5;

%% Integrator transfer function
H = 1/(z-1);

%% Noise Transfer Function 2nd order
numNTF = 1;
den = 1 + a2*H + a1*a2*H^2;
NTF = numNTF/den;
NTF1 = collect(NTF);
[numNTF1, den1] = numden(NTF1);
polyNTF = tf(sym2poly(numNTF1), sym2poly(den1), Ts);
[HNTF, WNTF] = freqz(sym2poly(numNTF1), sym2poly(den1),2048,1/Ts);

figure(1);
tiledlayout;
nexttile;
plot(WNTF, 20*log10(abs(HNTF)), 'b', 'LineWidth', 1.5);
ylim([-50 10]);
title('Resposta Magnitud NTF en Freqüència');
xlabel('Freqüència (Hz)');
ylabel('Magnitud (dB)');

nexttile;
phaseNTF = phasez(sym2poly(numNTF1), sym2poly(den1),2048);
plot(WNTF, phaseNTF, 'b', 'LineWidth', 1.5);
title('Resposta Fase NTF en Freqüència');
xlabel('Freqüència (Hz)');
ylabel('Desfassament (rad)');

% bodeNTF = bodeplot(polyNTF);

%% Signal Transfer Function 2nd order
numSTF = a1*a2*H^2;
den2 = 1 + a2*H + a1*a2*H^2;
STF = numSTF/den2;
STF1 = collect(STF);
[numSTF1, den2_1] = numden(STF1);
polySTF = tf(sym2poly(numSTF1), sym2poly(den2_1), Ts);
[HSTF, WSTF] = freqz(sym2poly(numSTF1), sym2poly(den2_1),2048,1/Ts);

figure(2);
tiledlayout;
nexttile;
plot(WSTF, 20*log10(abs(HSTF)), 'b', 'LineWidth', 1.5);
ylim([-50 10]);
title('Resposta Magnitud STF en Freqüència');
xlabel('Freqüència (Hz)');
ylabel('Magnitud (dB)');

nexttile;
phaseSTF = phasez(sym2poly(numSTF1), sym2poly(den2_1),2048);
plot(WSTF, phaseSTF, 'b', 'LineWidth', 1.5);
title('Resposta Fase STF en Freqüència');
xlabel('Freqüència (Hz)');
ylabel('Desfassament (rad)');
% bodeSTF = bodeplot(polySTF);

%% Zero plot for NTF and STF
figure(3);
% pzmap(polyNTF);
% hold on;
% [poles1, zeros1] = pzmap(polySTF);
% [poles2, zeros2] = pzmap(polyNTF);
% for i = 1:length(zeros2)
%     plot(real(zeros2(i)), imag(zeros2(i)), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
%     text(real(zeros2(i)), imag(zeros2(i)), sprintf(' Z%d', i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'r');
% end
% 
% % Plot poles with blue crosses and label them
% for j = 1:length(poles2)
%     plot(real(poles2(j)), imag(poles2(j)), 'b', 'MarkerSize', 6, 'LineWidth', 1.5);
%     text(real(poles2(j)), imag(poles2(j)), sprintf(' P%d', j), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Color', 'b');
% end
% 
% % Set axis labels and title
% xlabel('Real Part');
% ylabel('Imaginary Part');
% title('Pole-Zero Map with Legends');
% 
% % Add grid and axis limits
% axis equal; % Keep the aspect ratio equal
% xlim([-1.1 1.1]);
% ylim([-1.1 1.1]);
% 
% % Add legend
% legend('Zeros', 'Poles', 'Location', 'best');
% 
% % Hold off to avoid overlaying future plots
% hold off;
pzmap(polySTF, 'ko', polyNTF, 'b');

%% Find poles of both NTF and STF
polesden = solve(den1, z);
stable = abs(double(polesden(1))) < 1

%% Z-domain poles map to frequency domain
pole1_freq = polesden(1) - z_freq_tr; 
pole2_freq = polesden(2) - z_freq_tr;

%% Poles in the frequency domain
wp1 = solve(pole1_freq, w);
wp2 = solve(pole2_freq, w);

%% Corner frequencies 
f01 = abs(double(wp1))/(2*pi());
f02 = abs(double(wp2))/(2*pi());

%% Damping factor
e_rara = -real(double(wp1))/(f01*2*pi());

%% Find cutoff frequency STF
ind = find(abs(HSTF) < sqrt(1/2), 1, 'first');
slope = (abs(HSTF(ind)) - abs(HSTF(ind - 1))) / (WSTF(ind) - WSTF(ind - 1));
w_3dBL = ( sqrt(1/2) - abs(HSTF(ind - 1)) + slope * WSTF(ind - 1) )/(slope);

%% Find cutoff frequency NTF
indH = find(abs(HNTF) > sqrt(1/2), 1, 'first');
slopeH = (abs(HNTF(indH)) - abs(HNTF(indH - 1))) / (WNTF(indH) - WNTF(indH - 1));
w_3dBH = ( sqrt(1/2) - abs(HNTF(indH - 1)) + slopeH * WNTF(indH - 1) )/(slopeH);