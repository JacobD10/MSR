SYS = Current_Systems.loadCurrentSRsystem;
SYS.signal_info.method = SYS.signal_info.methods_list{1};
spkrPath = Broadband_Tools.getLoudspeakerSignalPath( ...
    SYS.Main_Setup(1), ...
    SYS.signal_info, ...
    SYS.system_info.LUT_resolution, ...
    SYS.system_info.Drive);
spkrFiles = Tools.getAllFiles(spkrPath);
spkrSigs = audioread(spkrFiles{1});