tic;
sys='sample';
new_system(sys);

%Set initial position parameters for x, y, height, width
x = 60;
y = 60;
w = 120;
h = 80;
offset = 120;

%Inputs by user
ns=input('Enter the number of cells in series : ');
bypass_diode = input('Enter the number of bypass diodes to be added : ');
nosc = input('Enter the number of shaded shells : ');
Irrmin = input('Enter partial irradiance : ');
Irrmax = input('Enter the max irradiance : ');

str=strings(ns,1);

%Code for Dynamic Irradiance
posIrr = [x+offset*2 (y-offset)+h/4 x+offset*2+w (y-offset)+h*.75];
posIrr2 = [x (y-offset)+h/4 x+w (y-offset)+h*.75];
Irr=add_block('fl_lib/Physical Signals/Sources/PS Constant',['sample' '/irr'],'Position',posIrr);
set_param('sample/irr','Constant',strcat('',num2str(Irrmax)));
Irr1=add_block('fl_lib/Physical Signals/Sources/PS Constant',['sample' '/irr2'],'Position',posIrr2);
set_param('sample/irr2','Constant',strcat('',num2str(Irrmin)));
port3 = get_param('sample/irr','PortHandles');
portminirr = get_param('sample/irr2','PortHandles');

for k=1:1:ns    
    
    if(k~=1)
        h1=h2;
    end
    
    pos = [x+(offset*k) y+h/4 x+(offset*k)+w y+h*.75];
    temp=strcat('sample/Sol',num2str(k));
    h2=add_block('elec_lib/Sources/Solar Cell',[temp],'Position',pos);
    port1=get_param(strcat('sample/Sol',num2str(k)),'PortHandles');
    set_param(strcat('sample/Sol',num2str(k)),'Rs','0');
    if k~=1
        port2=get_param(strcat('sample/Sol',num2str(k-1)),'PortHandles');
        add_line('sample',port1.LConn(2),port2.RConn(1),'autorouting','on');
    end
    
    if(k<=nosc)
        add_line('sample',portminirr.RConn(1),port1.LConn(1),'autorouting','on');
    else
        add_line('sample',port3.RConn(1),port1.LConn(1),'autorouting','on');
    end
    
end

portSol1 = get_param('sample/Sol1','PortHandles');

%Code for adding by pass diodes
offsetbpd = (offset*k)/bypass_diode;
for i = 1:1:bypass_diode
    posbpd = [x+(offsetbpd*(i-1/2)) y+offset+h/4 x+(offsetbpd*(i-1/2))+w y+offset+h*.75];
    temp=strcat('sample/bpd',num2str(i));
    add_block('fl_lib/Electrical/Electrical Elements/Diode',[temp],'Position',posbpd);
    port_bd = get_param(temp,'PortHandles');
    set_param([temp],'Orientation','left');
    temp1 = strcat('sample/Sol',num2str(1+(ns/bypass_diode)*(i-1)));
    temp2 = strcat('sample/Sol',num2str((ns/bypass_diode)*i));
    temp_param1 = get_param(temp1 , 'PortHandles');
    temp_param2 = get_param(temp2 , 'PortHandles');
    add_line('sample',port_bd.RConn(1),temp_param1.LConn(2));
    add_line('sample',port_bd.LConn(1),temp_param2.RConn(1));
end



%Code for adding Solver Configuration
pos_solverconfig = [(x-offset*4) (y+offset*0.5)+h/4 (x-offset*4)+w (y+offset*0.5)+h*.75];
add_block('nesl_utility/Solver Configuration',['sample' '/solverconfig'],'Position',pos_solverconfig);
port_solverconfig = get_param('sample/solverconfig','PortHandles');
add_line('sample',portSol1.LConn(2),port_solverconfig.RConn(1),'autorouting','on');

%For adding Variable Resistor
posvar_res = [(x+(ns/2)*offset) (y+offset*2)+h/4 (x+(ns/2)*offset)+w (y+offset*2)+h*.75];
add_block('fl_lib/Electrical/Electrical Elements/Variable Resistor', ['sample' '/var_res'],'Position',posvar_res);
port4 = get_param('sample/var_res','PortHandles');
%add_line('sample',port4.RConn(1),port1.RConn(1),'autorouting','on');
add_line('sample',portSol1.LConn(2),port4.LConn(2),'autorouting','on');


%Code for adding ramp
pos_ramp = [(x-offset*4) (y+offset*2)+h/4 (x-offset*4)+w (y+offset*2)+h*.75];
add_block('simulink/Sources/Ramp',['sample' '/ramp'],'Position',pos_ramp);
port_ramp = get_param('sample/ramp','PortHandles');
set_param('sample/ramp','Slope','10');

%Code for adding s-ps converter
pos_rampconv = [(x-offset*2) (y+offset*2)+h/4 (x-offset*2)+w (y+offset*2)+h*.75];
add_block('nesl_utility/Simulink-PS Converter',['sample' '/rampconv'],'Position',pos_rampconv);
port_rampconv = get_param('sample/rampconv','PortHandles');
%Code for connecting ramp and rampconv
add_line('sample',port_ramp.Outport(1),port_rampconv.Inport(1),'autorouting','on');
%Code for connecting rampconv and varres
add_line('sample',port_rampconv.RConn(1),port4.LConn(1),'autorouting','on');

%Code for Volatge Sensor
pos_vs = [(x+(ns/2)*offset) (y+offset*3)+h/4 (x+(ns/2)*offset)+w (y+offset*3)+h*.75];
add_block('fl_lib/Electrical/Electrical Sensors/Voltage Sensor',['sample' '/vs'],'Position',pos_vs);
port_vs = get_param('sample/vs','PortHandles');
add_line('sample',port4.RConn(1),port_vs.RConn(2),'autorouting','on');

%Code for adding PS-S Converter for Voltage Sensor
pos_vsconv = [(x+(ns/2)*offset+offset*2) (y+offset*3)+h/4 (x+offset*2+(ns/2)*offset)+w (y+offset*3)+h*.75];
add_block('nesl_utility/PS-Simulink Converter',['sample' '/vsconv'],'Position',pos_vsconv);
port_vsconv = get_param('sample/vsconv','PortHandles');
%add_line('sample',port_vsconv.LConn(1),port_vs.LConn(2));
add_line('sample',port4.LConn(2),port_vs.LConn(1),'autorouting','on');

%Code for adding line for vs and vs_conv
add_line('sample',port_vs.RConn(1),port_vsconv.LConn(1),'autorouting','on');

%Code for adding workspace out for volatge sensor
pos_vswspc = [(x+(ns/2)*offset+offset*4) (y+offset*3)+h/4 (x+offset*4+(ns/2)*offset)+w (y+offset*3)+h*.75];
add_block('simulink/Sinks/To Workspace',['sample' '/vswspc'],'Position',pos_vswspc);
port_vswspc = get_param('sample/vswspc','PortHandles');
add_line('sample',port_vsconv.Outport(1),port_vswspc.Inport(1));
set_param('sample/vswspc', 'VariableName', 'Voltage')
set_param('sample/vswspc', 'SaveFormat', 'Array');

%Code for adding current sensor 
pos_cs = [(x+(ns-1)*offset) (y+offset)+h/4 (x+(ns-1)*offset)+w (y+offset)+h*.75];
add_block('fl_lib/Electrical/Electrical Sensors/Current Sensor',['sample' '/cs'],'Position',pos_cs);
port_cs = get_param('sample/cs','PortHandles');
add_line('sample',port_cs.LConn(1),port4.RConn(1),'autorouting','on');
add_line('sample',port_cs.RConn(2),port1.RConn(1),'autorouting','on');

%Code for adding csconv
pos_csconv = [(x+(ns+1)*offset) (y+offset)+h/4 (x+(ns+1)*offset)+w (y+offset)+h*.75];
add_block('nesl_utility/PS-Simulink Converter',['sample' '/csconv'],'Position',pos_csconv);
port_csconv = get_param('sample/csconv','PortHandles');
add_line('sample',port_cs.RConn(1),port_csconv.LConn(1),'autorouting','on');

%Code for adding workspace for cs
pos_cswspc = [(x+(ns+3)*offset) (y+offset)+h/4 (x+(ns+3)*offset)+w (y+offset)+h*.75];
add_block('simulink/Sinks/To Workspace',['sample' '/cswspc'],'Position',pos_cswspc);
port_vswspc = get_param('sample/cswspc','PortHandles');
add_line('sample',port_csconv.Outport(1),port_vswspc.Inport(1));
set_param('sample/cswspc', 'VariableName', 'Current');
set_param('sample/cswspc', 'SaveFormat', 'Array');

%Code for electrical reference
pos_ref = [x+(offset*k) (y+offset*2.5)+h/4 x+(offset*k)+w (y+offset*2.5)+h*.75];
add_block('fl_lib/Electrical/Electrical Elements/Electrical Reference',['sample' '/elecref'],'Position',pos_ref);
port_ref = get_param('sample/elecref','PortHandles');
add_line('sample',port1.RConn(1),port_ref.LConn(1),'autorouting','on');

open_system(sys);

toc;