function dfx = fun_compute_load(x)
% function to solve nonlinear equation relating load to mill task

global hi_pass ho_try sig_Ft sig_Bt sig_dash sig_PS
sheet_width=1.2;
g=9.8;
E = 70;                 % GPa, Elastic modulus
nu = 0.35;               % Poisson's ratio
Fs = x(1); % T
R = x(2); % m
sig_UTS=180;
sig_0=69;
R0=0.449;
speed = 400/60;
mu = 0.00045;            % coefficient of friction
% unit conversion

% calculations
h = (hi_pass+ho_try)/2; % m
delh = hi_pass-ho_try; % m
L=(R*delh)^0.5;       % m
Pav = h/mu/L*(exp(mu*L/h)-1)*sig_PS; % MPa


dfx(1) = Fs - (Pav*L*sheet_width*1e3)/g; % kN
dfx(2) = R - (R0/1)*(1+16*(Fs*1e3*g)/(pi*(E/(1-nu^2))*1e9*delh*sheet_width)); % m
