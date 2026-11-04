function build_GES20kW()
%BUILD_GES20KW Automatically create and simulate a 20-kW PV functional diagram.
% MATLAB R2024a + Simulink only.
%
% IMPORTANT ENGINEERING LIMITATION:
% This is an averaged ACTIVE-POWER SIGNAL-FLOW teaching model.
% It is NOT a switching Simscape Electrical circuit, and its MPPT,
% boost stage, PWM, DC-link, inverter, LCL filter, transformer and breaker
% are simplified representations. Do not use for hardware sizing,
% fault studies, protection settings or grid-code validation.
%
% Run from the GitHub repository folder:
%   build_GES20kW

    assert(~isempty(ver('simulink')), ...
        'Simulink is required. Install or license Simulink first.');
    folder = fileparts(mfilename('fullpath'));
    model = 'GES20kW_SignalFlow_v1';
    destination = fullfile(folder,[model '.slx']);

    if exist(destination,'file')
        fprintf('Existing model opened (will not overwrite): %s\n',destination);
        open_system(destination);
        return
    end
    if bdIsLoaded(model)
        close_system(model,0);
    end
    new_system(model);
    set_param(model,'StopTime','1','Solver','ode45');
    fprintf('Creating 20 kW grid-connected PV functional model...\n');

    % PV system: 40 x 500 W (10 series x 4 parallel), 20 kW STC.
    % Vmp(panel) ~41 V, Imp(panel) ~12.2 A (illustrative).
    % Vmp(string) ~410 V; ideal boost duty ~1-410/700=0.414.
    % Grid-side: 400 V L-L, 50 Hz, unity power-factor abstraction.
    % Transformer: conceptual 0.4/11 kV, efficiency 98.5%.

    add_block('simulink/Sources/Step',[model '/Irradiance_G_Wm2'], ...
        'Time','0.4','Before','1000','After','600', ...
        'Position',[30 65 105 95]);
    add_block('simulink/Sources/Step',[model '/Temperature_C'], ...
        'Time','0.7','Before','25','After','35', ...
        'Position',[30 145 105 175]);

    pv = [model '/PV Array - 20kW'];
    add_block('simulink/Ports & Subsystems/Subsystem',pv, ...
        'Position',[190 75 335 175]);
    resetSubsystem(pv);
    portIn(pv,'Irradiance',1,45);
    portIn(pv,'Temperature',2,145);
    portOut(pv,'Ppv_W',1,100);
    add_block('simulink/Math Operations/Gain',[pv '/G_div_1000'], ...
        'Gain','1/1000','Position',[140 32 205 65]);
    add_block('simulink/Sources/Constant',[pv '/Tref_25C'], ...
        'Value','25','Position',[140 188 197 218]);
    add_block('simulink/Math Operations/Sum',[pv '/T_minus_25'], ...
        'Inputs','+-','Position',[255 141 280 181]);
    add_block('simulink/Math Operations/Gain',[pv '/temp_coefficient'], ...
        'Gain','-0.004','Position',[315 143 390 178]);
    add_block('simulink/Sources/Constant',[pv '/One'], ...
        'Value','1','Position',[315 205 371 233]);
    add_block('simulink/Math Operations/Sum',[pv '/temp_factor'], ...
        'Inputs','++','Position',[426 147 451 185]);
    add_block('simulink/Math Operations/Product',[pv '/G_times_Tfactor'], ...
        'Position',[500 66 535 119]);
    add_block('simulink/Math Operations/Gain',[pv '/Pstc_20000'], ...
        'Gain','20000','Position',[578 75 656 112]);
    add_block('simulink/Discontinuities/Saturation',[pv '/PV_Limits'], ...
        'UpperLimit','20000','LowerLimit','0', ...
        'Position',[685 75 745 110]);
    L(pv,'Irradiance/1','G_div_1000/1');
    L(pv,'Temperature/1','T_minus_25/1');
    L(pv,'Tref_25C/1','T_minus_25/2');
    L(pv,'T_minus_25/1','temp_coefficient/1');
    L(pv,'temp_coefficient/1','temp_factor/1');
    L(pv,'One/1','temp_factor/2');
    L(pv,'G_div_1000/1','G_times_Tfactor/1');
    L(pv,'temp_factor/1','G_times_Tfactor/2');
    L(pv,'G_times_Tfactor/1','Pstc_20000/1');
    L(pv,'Pstc_20000/1','PV_Limits/1');
    L(pv,'PV_Limits/1','Ppv_W/1');

    makeGain(model,'MPPT Controller - idealized', ...
        [410 91 570 159],0.99);
    makeGain(model,'DC-DC Boost Converter - avg', ...
        [645 91 827 159],0.97);

    dc = [model '/DC Link Capacitor - avg'];
    add_block('simulink/Ports & Subsystems/Subsystem',dc, ...
        'Position',[904 91 1090 159]);
    resetSubsystem(dc);
    portIn(dc,'Pdc_in',1,80); portOut(dc,'Pdc_out',1,80);
    add_block('simulink/Continuous/Transfer Fcn',[dc '/DC_link_smoothing'], ...
        'Numerator','[1]','Denominator','[0.02 1]', ...
        'Position',[130 55 290 110]);
    L(dc,'Pdc_in/1','DC_link_smoothing/1');
    L(dc,'DC_link_smoothing/1','Pdc_out/1');

    makeGain(model,'Three-phase Inverter - avg', ...
        [1185 75 1375 172],0.965,true);
    makeGain(model,'LCL Filter - avg', ...
        [1455 92 1605 160],0.995);
    makeGain(model,'Circuit Breaker and Protection - avg', ...
        [1695 75 1882 172],1,true);
    makeMeter(model,[1960 70 2150 184]);

    add_block('simulink/Sources/Constant',[model '/Grid_Healthy_1'], ...
        'Value','1','Position',[1655 260 1710 286]);
    add_block('simulink/Sources/Constant',[model '/Local_Load_5000W'], ...
        'Value','5000','Position',[2070 270 2150 302]);
    add_block('simulink/Math Operations/Sum',[model '/P_grid_exchange'], ...
        'Inputs','+-','Position',[2230 99 2260 150]);
    makeGain(model,'Step-up Transformer 0p4-11kV - avg', ...
        [2315 92 2540 161],0.985);
    makeGain(model,'Utility Grid 11kV - exchange', ...
        [2620 92 2815 161],1);

    % Reference waveforms ONLY, not actual PWM switching/gate signals.
    w = [model '/PWM Control - reference only'];
    add_block('simulink/Ports & Subsystems/Subsystem',w, ...
        'Position',[920 335 1130 405]);
    resetSubsystem(w);
    portOut(w,'Vabc_reference',1,100);
    phase = {'0','-2*pi/3','2*pi/3'};
    for j=1:3
        blk = [w '/Phase_' num2str(j)];
        add_block('simulink/Sources/Sine Wave',blk, ...
            'Amplitude','400*sqrt(2/3)', ...
            'Frequency','2*pi*50', ...
            'Phase',phase{j},'SampleTime','0', ...
            'Position',[120 30+70*j 205 65+70*j]);
    end
    add_block('simulink/Signal Routing/Mux',[w '/Mux_abc'], ...
        'Inputs','3','Position',[280 140 300 260]);
    for j=1:3
        L(w,['Phase_' num2str(j) '/1'],['Mux_abc/' num2str(j)]);
    end
    L(w,'Mux_abc/1','Vabc_reference/1');

    add_block('simulink/Signal Routing/Mux',[model '/Power_Mux'], ...
        'Inputs','3','Position',[2815 385 2840 480]);
    add_block('simulink/Sinks/Scope',[model '/Power_20kW_Scope'], ...
        'Position',[2900 407 2970 457]);
    add_block('simulink/Sinks/Scope',[model '/ThreePhase_Reference_Scope'], ...
        'Position',[1210 345 1300 390]);

    add_block('simulink/Signal Routing/Mux',[model '/Measurement_Mux'], ...
        'Inputs','4','Position',[2200 345 2225 475]);
    add_block('simulink/Sinks/Scope',[model '/PCC_Measurements_Scope'], ...
        'Position',[2290 380 2370 428]);

    add_block('simulink/Sinks/To Workspace',[model '/Log_Ppv_W'], ...
        'VariableName','GES_Ppv_W','SaveFormat','Array', ...
        'Position',[500 305 600 341]);
    add_block('simulink/Sinks/To Workspace',[model '/Log_Pinv_W'], ...
        'VariableName','GES_Pinv_W','SaveFormat','Array', ...
        'Position',[1320 290 1410 330]);
    add_block('simulink/Sinks/To Workspace',[model '/Log_Pexport_W'], ...
        'VariableName','GES_Pexport_W','SaveFormat','Array', ...
        'Position',[2630 280 2755 320]);

    % Topology connections (active power in watts)
    L(model,'Irradiance_G_Wm2/1','PV Array - 20kW/1');
    L(model,'Temperature_C/1','PV Array - 20kW/2');
    L(model,'PV Array - 20kW/1','MPPT Controller - idealized/1');
    L(model,'MPPT Controller - idealized/1','DC-DC Boost Converter - avg/1');
    L(model,'DC-DC Boost Converter - avg/1','DC Link Capacitor - avg/1');
    L(model,'DC Link Capacitor - avg/1','Three-phase Inverter - avg/1');
    L(model,'PWM Control - reference only/1','Three-phase Inverter - avg/2');
    L(model,'Three-phase Inverter - avg/1','LCL Filter - avg/1');
    L(model,'LCL Filter - avg/1','Circuit Breaker and Protection - avg/1');
    L(model,'Grid_Healthy_1/1','Circuit Breaker and Protection - avg/2');
    L(model,'Circuit Breaker and Protection - avg/1','Voltage Current Power Measurement/1');
    L(model,'Voltage Current Power Measurement/1','P_grid_exchange/1');
    L(model,'Local_Load_5000W/1','P_grid_exchange/2');
    L(model,'P_grid_exchange/1','Step-up Transformer 0p4-11kV - avg/1');
    L(model,'Step-up Transformer 0p4-11kV - avg/1','Utility Grid 11kV - exchange/1');
    L(model,'PWM Control - reference only/1','ThreePhase_Reference_Scope/1');
    L(model,'PV Array - 20kW/1','Log_Ppv_W/1');
    L(model,'Three-phase Inverter - avg/1','Log_Pinv_W/1');
    L(model,'Utility Grid 11kV - exchange/1','Log_Pexport_W/1');
    L(model,'PV Array - 20kW/1','Power_Mux/1');
    L(model,'Three-phase Inverter - avg/1','Power_Mux/2');
    L(model,'Utility Grid 11kV - exchange/1','Power_Mux/3');
    L(model,'Power_Mux/1','Power_20kW_Scope/1');
    for j=1:4
        L(model,['Voltage Current Power Measurement/' num2str(j)],...
            ['Measurement_Mux/' num2str(j)]);
    end
    L(model,'Measurement_Mux/1','PCC_Measurements_Scope/1');

    set_param(model,'SimulationCommand','update');
    save_system(model,destination);
    open_system(model);
    fprintf('MODEL SAVED: %s\n',destination);
    fprintf('20 kW: 40 panels (10S x 4P), 400 Vac / 50 Hz, 11 kV grid.\n');
    fprintf('Average model only. NO physical Simscape switching circuit.\n');
    try
        sim(model);
        fprintf('SIMULATION SUCCESS (1 s). Open the Scope blocks.\n');
    catch ME
        fprintf(2,'Simulation failed; model is saved. Details:\n%s\n',ME.message);
        rethrow(ME);
    end
end

function resetSubsystem(ss)
    blocks = find_system(ss,'SearchDepth',1,'Type','Block');
    for n=numel(blocks):-1:1
        if ~strcmp(blocks{n},ss)
            delete_block(blocks{n});
        end
    end
end
function portIn(ss,name,n,y)
    add_block('simulink/Ports & Subsystems/In1',[ss '/' name], ...
        'Port',num2str(n),'Position',[25 y 65 y+20]);
end
function portOut(ss,name,n,y)
    add_block('simulink/Ports & Subsystems/Out1',[ss '/' name], ...
        'Port',num2str(n),'Position',[400 y 440 y+20]);
end
function L(sys,src,dst)
    add_line(sys,src,dst,'autorouting','on');
end
function makeGain(model,name,pos,gainValue,twoInput)
    if nargin<5; twoInput=false; end
    path=[model '/' name];
    add_block('simulink/Ports & Subsystems/Subsystem',path,'Position',pos);
    resetSubsystem(path);
    portIn(path,'P_in',1,75); portOut(path,'P_out',1,75);
    if twoInput
        portIn(path,'Control_reference',2,190);
        add_block('simulink/Sinks/Terminator',[path '/Control_not_used_in_avg'], ...
            'Position',[250 188 270 210]);
        L(path,'Control_reference/1','Control_not_used_in_avg/1');
    end
    add_block('simulink/Math Operations/Gain',[path '/Efficiency_or_gain'], ...
        'Gain',num2str(gainValue,12), 'Position',[180 62 270 107]);
    L(path,'P_in/1','Efficiency_or_gain/1');
    L(path,'Efficiency_or_gain/1','P_out/1');
end
function makeMeter(model,pos)
    p=[model '/Voltage Current Power Measurement'];
    add_block('simulink/Ports & Subsystems/Subsystem',p,'Position',pos);
    resetSubsystem(p);
    portIn(p,'P_ac_W',1,65);
    portOut(p,'P_W',1,45);
    portOut(p,'V_line_RMS',2,100);
    portOut(p,'I_line_RMS',3,165);
    portOut(p,'Frequency_Hz',4,230);
    add_block('simulink/Sources/Constant',[p '/V400'], ...
        'Value','400','Position',[170 96 220 126]);
    add_block('simulink/Sources/Constant',[p '/F50'], ...
        'Value','50','Position',[170 222 220 250]);
    add_block('simulink/Math Operations/Gain',[p '/P_to_I_3phase'], ...
        'Gain','1/(sqrt(3)*400)', ...
        'Position',[175 145 280 187]);
    L(p,'P_ac_W/1','P_W/1');
    L(p,'P_ac_W/1','P_to_I_3phase/1');
    L(p,'P_to_I_3phase/1','I_line_RMS/1');
    L(p,'V400/1','V_line_RMS/1');
    L(p,'F50/1','Frequency_Hz/1');
end
