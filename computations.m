function dy=computations(hi_pass,ho_try,red)

% mill info
sig_0 = 69;             % MPa
sig_UTS = 180;          % MPa
R = 0.449;              % m (work roll diameter)
R0 = 0.449;             % m (work roll diameter)
mu = 0.00045;            % coefficient of friction
E = 59;                 % GPa, Elastic modulus
nu = 0.35;               % Poisson's ratio
g = 9.8;                % acceleration due to gravity

% operational data
sheet_width = 1.2;      % m
tension_Payoff = 6200;  % Kg
tension_Rewind = 4800;  % Kg

h = (hi_pass+ho_try)/2;
delh = hi_pass-ho_try; % m

% computation
sig_dash = ((red/2)^0.5)*(2.66*sig_UTS-2*sig_0); % MPa
sig_Ft = tension_Rewind*g/(sheet_width*ho_try)/1e6; % MPa
sig_Bt = tension_Payoff*g/(sheet_width*hi_pass)/1e6;
tension_Rewind = sig_Ft/(g/(sheet_width*ho_try)/1e6);
Rewind_power = tension_Rewind * 9.81 * 200/60/1000;
tension_Payoff = sig_Bt/(g/(sheet_width*hi_pass)/1e6);
if sig_Ft-sig_UTS>0 
    sig_Ft=180;
    tension_Rewind = sig_Ft/(g/(sheet_width*ho_try)/1e6);
    Rewind_power = tension_Rewind * 9.81 * (200/60)/1000;
end
% if sig_Bt-sig_UTS>0
%     const = (ho_try*sig_Ft + sig_dash*((R*(acosd(1-(delh/(2*R))))^2)- delh))/hi_pass;
%     if const>180
%         sig_Bt=180;
%     else
%         sig_Bt=const;
%     end

alpha_b=deg2rad(acosd(1-(delh/(2*R))));
tension_Payoff = tension_Rewind + (sig_dash*sheet_width/g)*((R*(alpha_b)^2)- delh);
Payoff_power = tension_Payoff * 9.81 * (200/60)/1000;
sig_Bt = tension_Payoff*g/(sheet_width*hi_pass)/1e6;
sig_PS = sig_dash - (sig_Bt+sig_Ft)/2;

if sig_PS<0
    sig_PS = 0;
    sig_Bt = 2*sig_dash - sig_Ft; 
    tension_Payoff = sig_Bt/(g/(sheet_width*hi_pass)/1e6);
end
   
L = (R*delh)^0.5;       % m
Pav = h/mu/L*(exp(mu*L/h)-1)*sig_PS; % MPa
Power_main_ideal = Pav*1000*L*sheet_width*L*(200/60)/(R);
Power_main = Power_main_ideal/0.8;
dy(1)=tension_Payoff;
dy(2)=Payoff_power;
dy(3)=tension_Rewind;
dy(4)=Rewind_power;
dy(5)=sig_Bt;
dy(6)=sig_Ft;
dy(7)=Power_main;
dy(8)=Pav;
dy(9)=L;
dy(10)=sig_dash;
dy(11)=sig_PS;
end