
x = [-2:0.5:2];
y = -1*(x<=-1) + x.*(x>-1&x<=1) + 1*(x>1);
plot(x,y); ylim([-1.1 1.1]); grid on;

xx = [-2:0.01:2];
yint = spline(x(x~=-1 & x~=1),y(x~=-1 & x~=1),xx);
hold on;
plot(xx,yint); hold off

%%
% ff = 0:8000;
fs = 16000;

f_band = [100 2000];
fmid = 10^mean(log10(f_band));

f_edges = [10 f_band(1) fmid f_band(2) fs/2];

dbPerOct = 3; %dB
a_ = db2mag( ...
    dbPerOct/log10(2) * log10(f_edges/fmid) );
a_([1 end]) = a_([2 end-1]);

a_int = db2mag( ...
    spline(log10(f_edges([1 3 end])),mag2db(a_),log10(10:8000))  );

plot(f_edges/1e3,mag2db(a_)); hold on;
plot((10:8000)/1e3,mag2db(a_int)); hold on;
grid on; grid minor;
set(gca,'xscale','log');
xlim([0.01 10]); hold off;

%%
[num,den]=iirlpnorm(32,14,ff([14:129])'/(fs/2),ff([14 129])'/(fs/2),ff([14:129])'/(fs/2));

freqz(num,den);
set(gca,'xscale','log');


%%
clear; clc;

c = 343;                    % Sound velocity (m/s)
fs = 16000;                 % Sample frequency (samples/s)
L = [3 3 3];                % Room dimensions [x y z] (m)
n = 0.2*fs;                   % Number of samples
mtype = 'omnidirectional';  % Type of microphone
order = 1;                 % -1 equals maximum reflection order!
dim = 3;                    % Room dimension
orientation = 0;            % Microphone orientation (rad)
hp_filter = 0;              % Enable high-pass filter
rng shuffle;

betaA = (1 - [1 [1 1 1 1 1]*1]).^2;                 % Reverberation time (s)
beta1 = (1 - [0.00*1 [1 1 1 1 1]*1]).^2;                 % Reverberation time (s)

rtxN = 24;
[yy,zz] = meshgrid(linspace(0,3,rtxN)); % Planar Array
% yy = linspace(0,3,rtxN); zz = yy*0+1.5; % Linear Array

rtx = [zeros(numel(yy),1), yy(:), zz(:)];
srx = rtx;

MM=[];PP=[];
tic;
ss=0;
while true %for ss = 1:10
    ss = ss+1;
% r = [1.0 1.5 1.5];    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
% s = [1.5 1.5 1.5];              % Source position [x y z] (m)
r = rand(1,3)*3;    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
s = rand(1,3)*3;    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
% s = [rand(1,2)*3 1.5]; r = [rand(1,2)*3 1.5]; % When using linear array

hA = rir_generator(c, fs, r, s, L, betaA, n, mtype, order, dim, orientation, hp_filter);
h1 = rir_generator(c, fs, r, s, L, beta1, n, mtype, order, dim, orientation, hp_filter);
hf = h1(:)-hA(:);

stx = s;              % Source position [x y z] (m)
htx = rir_generator(c, fs, rtx, stx, L, betaA, n, mtype, order, dim, orientation, hp_filter);
rrx = r;    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
for i = 1:size(rtx,1)
    hrx(i,:) = rir_generator(c, fs, rrx, srx(i,:), L, betaA, n, mtype, order, dim, orientation, hp_filter);
end

% htx = imag(hilbert(htx));

hc = Tools.fconv(htx.',hrx.');
hc = sum(hc(1:numel(hf),:),2);
hc = Broadband_Tools.power_norm(hf,hc,fs,[250 1000]);

% figure(1);
% % plot(hA); hold on;
% plot(hf); hold on
% % plot(hi); hold on;
% plot(hc); hold on;
% hold off

figure(2);
HF = fft(hf);
HC = fft(hc);

ff = linspace(0,fs/2,n/2+1)/1e3;ff(end)=[];

MagnitudeC = abs(HC);
MagnitudeC(end/2+1:end)=[];

PhaseDifference = mod(unwrap(angle(HF)) - unwrap(angle(HC)) + pi,2*pi)/pi*180-180;
PhaseDifference(end/2+1:end)=[];

MM(:,ss) = MagnitudeC; %.*ff.'; Planar compensation %.*sqrt(ff).' % Linear compensation
PP(:,ss) = PhaseDifference;
% MM = mean([MM , MagnitudeC.*ff.' ],2);
% PP = mean([PP , PhaseDifference  ],2);


subplot(2,1,1);
plot(ff, mag2db(  MM  ),':k'); hold on;
plot(ff, mag2db(  mean(MM,2)  ),'-b','linew',1.5); hold off;
xlim([0.1 10]); %ylim([-60 0]);
grid on; grid minor; set(gca,'xscale','log');
xlabel('Frequency (kHz)');ylabel('Magnitude (dB)');

subplot(2,1,2);
plot(ff, PP ,':k'); hold on;
plot(ff, mean(PP,2) ,'-','co',.8*[1 0 0],'linew',1.5); hold off;
xlim([0.1 10]); ylim([-180 180]); yticks([-180:45:180]);
grid on; grid minor; set(gca,'xscale','log');
xlabel('Frequency (kHz)');ylabel('Phase (\circ)');

drawnow;
fprintf('%d\n',ss);
end
toc

