clearvars
close all
clc
global hi_pass ho_try sig_Ft sig_Bt sig_dash sig_PS
A=readmatrix('Input_data.xlsx','Range','B1:B5');
% mill info
R=0.449;
R0 = 0.449;             % m (work roll diameter)
% operational data
sheet_width = 1.2;      % m
hi = A(1);            % m
ho = A(2);            % m
tension_Payoff = 620;  % Kg (modified values)
tension_Rewind = 480;  % Kg (modified values)

% solver
Fs0 = A(3);              % T, initial guess for load
Fs_max = A(4);
Power_max = A(5);
%R1 = 542.63;           % mm, initial guess for deformed roller radius

% pass schedule settings
N_max = 100; % maximum passes possible


% initialization
n=0; % n = no. of passes
hi_pass = hi;
HI = hi; % set of entry thickness
HO = []; % set of exit thickness
Ft = [];
Ra = [];
Bt = [];
P  = [];
TP = [];
TR = [];
PP = [];
RP = [];
L_const= [];
Pav_const=[];
sig_v=[];
sig_P=[];
%fun = @(r)hi_pass/r;   % Objective function
% r= hi/ho. r is varied to obtain minimum passes
r1 = 1;
j=1;
Fs=[];

for k = 1:N_max % loop over passes
    min = hi_pass;
    for red = 0.0001:0.0001:0.5
        tension_Payoff = 6200;  % Kg
        tension_Rewind = 4800;  % Kg
        ho_try = hi_pass*(1-red);
        dy=computations(hi_pass,ho_try,red);
        tension_Payoff=dy(1);
        Payoff_power=dy(2);
        tension_Rewind=dy(3);
        Rewind_power=dy(4);
        sig_Bt=dy(5);
        sig_Ft=dy(6);
        Power_main=dy(7);
        Pav=dy(8);
        L=dy(9);
        sig_dash=dy(10);
        sig_PS=dy(11);
        x = fsolve(@fun_compute_load,[Fs0;R0],optimoptions('fsolve','Display','off'));
        fx = fun_compute_load(x);
        FS = x(1); % T
        R = x(2); % mm
            
        if Power_main-Power_max>0 
            red = red-0.0001;
            ho_try=hi_pass*(1-red);
            dy=computations(hi_pass,ho_try,red);
            tension_Payoff=dy(1);
            Payoff_power=dy(2);
            tension_Rewind=dy(3);
            Rewind_power=dy(4);
            sig_Bt=dy(5);
            sig_Ft=dy(6);
            Power_main=dy(7);
            Pav=dy(8);
            L=dy(9);  
            sig_dash=dy(10);
            sig_PS=dy(11);
            x = fsolve(@fun_compute_load,[Fs0;R0],optimoptions('fsolve','Display','off'));
            FS= x(1);
            R = x(2);
            ho_pass=ho_try;
            break
        end
        if x(1)-Fs_max>0
            red = red-0.0001;
            ho_try=hi_pass*(1-red);
            dy=computations(hi_pass,ho_try,red);
            tension_Payoff=dy(1);
            Payoff_power=dy(2);
            tension_Rewind=dy(3);
            Rewind_power=dy(4);
            sig_Bt=dy(5);
            sig_Ft=dy(6);
            Power_main=dy(7);
            Pav=dy(8);
            L=dy(9);
            sig_dash=dy(10);
            sig_PS=dy(11);
            x = fsolve(@fun_compute_load,[Fs0;R0],optimoptions('fsolve','Display','off'));
            FS= x(1);
            R = x(2);
            ho_pass=ho_try;
            break;
        end
        if sig_dash-170.4>0
            red = red-0.0001;
            ho_try=hi_pass*(1-red);
            dy=computations(hi_pass,ho_try,red);
            tension_Payoff=dy(1);
            Payoff_power=dy(2);
            tension_Rewind=dy(3);
            Rewind_power=dy(4);
            sig_Bt=dy(5);
            sig_Ft=dy(6);
            Power_main=dy(7);
            Pav=dy(8);
            L=dy(9);
            sig_dash=dy(10);
            sig_PS=dy(11);
            x = fsolve(@fun_compute_load,[Fs0;R0],optimoptions('fsolve','Display','off'));
            FS= x(1);
            R = x(2);
            ho_pass=ho_try;
            break;
        end
            
        i=i+1;
        if min > ho_try
                min = ho_try;
        end
        ho_pass = min;
        if(ho_pass-ho) <= 0
            break;
        end
    end
    n=n+1; % number of passes
    P = [P;Power_main];
    Ft = [Ft;sig_Ft];
    Bt = [Bt;sig_Bt];
    HO = [HO;ho_pass];
    if FS<0
        FS=0;
    end
    Fs = [Fs;FS];
    Ra = [Ra;R];
    TP = [TP;tension_Payoff];
    PP = [PP;Payoff_power];
    TR = [TR;tension_Rewind];
    RP = [RP;Rewind_power];
    L_const= [L_const;L];
    Pav_const= [Pav_const;Pav];
    sig_v=[sig_v;sig_dash];
    sig_P=[sig_P;sig_PS];
    if (ho_pass-ho)<= 0
        break;
    else
        if k ~= N_max
            hi_pass=ho_pass; % next pass input
            HI = [HI;hi_pass];
        end
    end
end

% printing schedule

for i = 1:n
    disp(['Pass ' num2str(i) ':']);
    disp(['Entry gauge = ' num2str(HI(i)) ' Exit gauge = ' num2str(HO(i)) ...
        ' % reduction = ' num2str((HI(i)-HO(i))/HI(i)) ' Load  = ' num2str(Fs(i))  ...
        ' R = ' num2str(Ra(i)) ' sig_Ft = ' num2str(Ft(i)) ' sig_Bt = ' num2str(Bt(i)) ...
        ' Power = ' num2str(P(i)) ' Payoff tension = ' num2str(TP(i))...
        ' Payoff Motor Power = ' num2str(PP(i)) ' Rewind Tension = ' num2str(TR(i)) ...
        ' Rewind Motor Power = ' num2str(RP(i)) ' L = ' num2str(L_const(i)) ...
        ' Pav = ' num2str(Pav_const(i)) ' sig_v = ' num2str(sig_v(i)) ...
        ' sig_PS = ' num2str(sig_P(i))]);
    M={num2str(HI(i));num2str(HO(i));num2str((HI(i)-HO(i))/HI(i));num2str(Fs(i)); ... 
       num2str(Ra(i));num2str(Ft(i));num2str(Bt(i));num2str(P(i));num2str(TP(i)); ...
       num2str(PP(i));num2str(TR(i));num2str(RP(i));num2str(L_const(i));num2str(Pav_const(i)); ...
       num2str(sig_v(i));num2str(sig_P(i))};
    writecell(M,'Output_Data.xlsx','Sheet',i,'Range','B1:B16');
end