%clc;
clear;
%close all;
tic;

%%
% SYS = Current_Systems.loadCurrentSRsystem;

SYS = Current_Systems.IEEETransactions_System_G;

%%
f = 1000;
%  f = Broadband_Tools.getAliasingFrequency(SYS.Main_Setup(2))*343/2/pi;
c = 343;
% Freqs = 200:100:3000;
C=[];E=[];
%  for f = Freqs
% fprintf('%.0f\n',f);
%%
setup = [SYS.Main_Setup(:);SYS.Masker_Setup(:)];

for s = 1:numel(setup)
    
%         setup(s).Multizone_Soundfield.Radius = 0.91;
%     setup(s).Multizone_Soundfield.UnattendedZ_Weight = 0;
    
%     setup(s).Multizone_Soundfield.Quiet_Zone = ...
%         setup(s).Multizone_Soundfield.Quiet_Zone.setDesiredSoundfield(true, f, 'suppress_output');
%     setup(s).Multizone_Soundfield.Bright_Zone = ...
%         setup(s).Multizone_Soundfield.Bright_Zone.setDesiredSoundfield(true, f, 'suppress_output');
%     setup(s).Multizone_Soundfield = setup(s).Multizone_Soundfield.setN( -1 ); %Auto set
%     setup(s).Multizone_Soundfield = setup(s).Multizone_Soundfield.createEmptySoundfield('DEBUG');
%     if setup(s).Loudspeaker_Count>1
        setup(s).Multizone_Soundfield = setup(s).Multizone_Soundfield.createSoundfield('DEBUG');
%     end
    
    setup(s) = setup(s).calc_Loudspeaker_Weights();
%     if s == 2
%        setup(s).Radius = (setup(s-1).Loudspeaker_Dimensions(1)*setup(s-1).Loudspeaker_Count/2)/2;
% 
%        setup(s).Multizone_Soundfield.Radius = setup(s).Radius;
%    end
    setup(s) = setup(s).reproduceSoundfield('DEBUG');
    
end


%%
% try close('111'); catch; end

figNums = [101,102,103];
realistic = false;
details.DrawDetails = false;
details.zoneLineWid = 1.5;
details.arrowLineWid = 0.4;
details.arrowLength = 3;
details.arrowAngle = 30;
details.arrowBuffer = 2;
details.lblFontSize = 12;

for s = 1:numel(setup)
 pk(s) = max(abs((setup(s).Bright_Samples(:))))*setup(s).res;
 
 F{s} = setup(s).Soundfield_reproduced*setup(s).res;
end

gainNorm = 1/max(pk); % Normalise to the maximum of all bright peaks

clipFact = 2;
for s = 1:numel(setup)
    F{s} = F{s}*gainNorm; pk(s) = pk(s)*gainNorm;
    
    F{s}(abs(F{s})>clipFact*pk(s))=nan;
end


% close all;
fH = figure('Name',SYS.publication_info.FigureName);
ha = tightPlots( ...
    SYS.publication_info.subPlotDims(1), ...
    SYS.publication_info.subPlotDims(2), ...
    SYS.publication_info.figure_width, ...
    SYS.publication_info.axis_aspect_ratio, ...
    SYS.publication_info.axes_gap, ...
    SYS.publication_info.axes_margins_height, ...
    SYS.publication_info.axes_margins_width, ...
    'centimeters');
FontSize = 16;
FontName = 'Times';

axes(ha(1));
ax=gca;
setup(1).plotSoundfield( (Z1), 'scientific_D1', realistic, details);
text(10,size(Z1,1)-FontSize-10,1e3,'(A)',...
    'BackgroundColor',[1 1 1 0.7],'FontName',FontName,'FontSize',FontSize)
ax.Title.String = '';%'Pressure Soundfield of Talker';
% ax.XLabel = [];
% ax.XTickLabel = [];
clim_=[-1 1].*pk(1);
ax.CLim = clim_;
colorbar off

axes(ha(2))
ax=gca;
setup(1).plotSoundfield( Z2, 'scientific_D1', realistic, details);
text(10,size(Z2,1)-FontSize-10,1e3,'(B)',...
    'BackgroundColor',[1 1 1 0.7],'FontName',FontName,'FontSize',FontSize)
ax.Title=[];
% ax.XLabel = [];
% ax.XTickLabel = [];
% ax.YLabel = [];
% ax.YTickLabel = [];
ax.CLim=clim_;
% colorbar off
hCB = colorbar(ax); 
hCB.Visible = 'off';

% axes(ha(3))
% ax=gca;
% setup(1).plotSoundfield( Z3-Z1, 'scientific_D1', realistic, details);
% text(10,size(Z2,1)-FontSize-10,1e3,'(C)',...
%     'BackgroundColor',[1 1 1 0.7],'FontName',FontName,'FontSize',FontSize)
% ax.Title=[];
% ax.CLim=clim_;
% colorbar off
% 
% 
% axes(ha(4))
% ax=gca;
% setup(1).plotSoundfield( abs(Z3-Z1), 'scientific_L9', realistic, details);
% text(10,size(Z2,1)-FontSize-10,1e3,'(D)',...
%     'BackgroundColor',[1 1 1 0.7],'FontName',FontName,'FontSize',FontSize)
% ax.Title=[];
% ax.YLabel = [];
% ax.YTickLabel = [];
% ax.CLim=[-60 0];
% colorbar off;
% % tightfig;
% 
% hCB = colorbar; hCB.Units = 'points';
% hCB.Ticks = interp1(1:length(caxis),caxis,linspace(1,length(caxis),5));
% hCB.TickLabels = num2str(linspace( ax.CLim(1), ax.CLim(2),5)' );
% hCB.Label.String = 'Magnitude (dB)';
% 
% set(fH.Children, 'Units','Points')
% for c = 1:numel(fH.Children)
%  fH.Children(c).Position(2) = fH.Children(c).Position(2)+20;
% end



% figure(figNums(2)); hold off
% setup.plotSoundfield( Z2, 'scientific_L9', realistic, details);
% figure(figNums(3)); hold off
% setup.plotSoundfield( Z3, 'scientific_L9', realistic, details);



% for fn = 1:numel(figNums)
%     figure(figNums(fn));
%     if setup.Loudspeaker_Count > 1
%         R = [0 1].*size(Z,1) ; xlim(R);ylim(R);
%     else
%         R = [0 1].*size(Z,1) - size(Z,1) - x_*setup.res; xlim(R);ylim(R);
%     end
% end
%  caxis([-30, 0] );


%title('Small Zone Weight');

%  hold on;

%  Z = setup.Soundfield_reproduced;
%  %Z_ = -QualityGuidedUnwrap2D_r1(Z);
%  Z_ = GoldsteinUnwrap2D_r1(Z);
%
%  Zs = abs(Z);
%  Zs = Zs(1:10:end,1:10:end);
%  Z__ = Z_(1:10:end,1:10:end);
%
%  [U,V] = gradient( Z__(2:end-1,2:end-1) );
%  [X,Y] = meshgrid( 1:size(Z,1) , 1:size(Z,2) );
%  X = X(1:10:end,1:10:end);
%  Y = Y(1:10:end,1:10:end);
%  X = X(2:end-1,2:end-1);
%  Y = Y(2:end-1,2:end-1);
%  quiver3( X , Y, ones(size(U))*4, U .* abs(Zs(2:end-1,2:end-1)) , V .* abs(Zs(2:end-1,2:end-1)), zeros(size(U)), 1, 'k' );
%quiver3( X , Y, ones(size(U))*4, U  , V , zeros(size(U)), 1, 'k' );
%

C(end+1) = pow2db(setup(1).Acoustic_Contrast);
E(end+1) = mag2db(setup(1).MSE_Bright);

% end
%%
% figure(1010)
% hold on;
% plot(Freqs,-C/2); hold off; ylim([-60 0]); set(gca,'XScale','log'); grid on; grid minor;
% figure(1011)
% hold on;
% plot(Freqs,E); hold off
%%
disp(['   Contrast: ' num2str(pow2db(setup(1).Acoustic_Contrast)) 'dB']);
disp(['        MSE: ' num2str(mag2db(setup(1).MSE_Bright)) 'dB']);
disp(['Attenuation: ' num2str(setup(1).Attenuation_dB(1)) 'dB (�' num2str(setup(1).Attenuation_dB(2)) 'dB)']);
% mean(mag2db(abs(Z3(:)-Z1(:))))
%%
%fprintf(Speaker_Setup.printSetupDetails(setup));

%%
tEnd = toc;
fprintf('Execution time: %dmin(s) %fsec(s)\n', floor(tEnd/60), rem(tEnd,60)); %Time taken to execute this script