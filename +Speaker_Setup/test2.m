clc;
clear;
%close all;
tic;

%%
room_width = 3.200; %m
rad = ( room_width - 2*0.115 - 2*0.085 ) / 2;

speech_layout = {'brightzone_pos_angle',        -90, ...
                 'quietzone_pos_angle',         90, ...
                 'brightzone_source_angle',     0};
masker_layout = {'brightzone_pos_angle',        -90, ...
                 'quietzone_pos_angle',         90, ...
                 'brightzone_source_angle',     -45};
             
setup = Speaker_Setup.createSetup({...
            'frequency',                    4000, ...
            speech_layout{:}, ...
            'resolution',                   100, ... % Minimum resolution of approx 50 for 8kHz signal to satisfy nyquist theorem. We choose 100 for good measure.
            'reproduction_radius',          1.0, ...
            'bright_weight',                1.0, ...
            'quiet_weight',                 1e4, ...
            'unattended_weight',            0.05, ...
            'brightzone_radius',            0.3, ...
            'brightzone_pos_distance',      0.6, ...
            'quietzone_radius',             0.3, ...
            'quietzone_pos_distance',       0.6, ...
            'numberof_loudspeakers',        22, ...
            'loudspeaker_radius',           1.5, ...
            'maximum_frequency',            8000, ...
            'angleto_firstloudspeaker',     90, ...
            'angleof_loudspeakerarc',       180, ...
            'loudspeaker_model',            'Genelec 8010A', ...
            'angleof_loudspeakerarrcentre', 180, ...
            'loudspeaker_spacing',          0.01, ...
            'speaker_array_type',           'line'});
        
%%
setup.Multizone_Soundfield = setup.Multizone_Soundfield.createSoundfield('DEBUG');
 
 setup = setup.calc_Loudspeaker_Weights();
 setup = setup.reproduceSoundfield('DEBUG');

 
 %%
 figure(1);
 realistic = false;
 setup.plotSoundfield( (setup.Soundfield_reproduced), 'default', realistic);

 
%%
tEnd = toc;
fprintf('Execution time: %dmin(s) %fsec(s)\n', floor(tEnd/60), rem(tEnd,60)); %Time taken to execute this script