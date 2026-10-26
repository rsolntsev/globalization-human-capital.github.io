%% ================================================================

% General equilibrium 
% - Multi-country (N) and multi-sector (J) model
% - Solves for equilibrium prices (r, w_l, w_h) and output (Y) given
%   technology, trade costs, endowments, and production parameters
% - Updates human capital allocation (H vs L) and capital accumulation (K)

%% ================================================================

clear all

%% -------------------- Parameters / dimensions --------------------
eps   = 3;        % (Not used below) elasticity / preference parameter placeholder
N     = 42;       % number of countries/regions
J     = 158;      % number of sectors
theta = 8.28;     % trade elasticity / dispersion parameter
eta   = 4;        % (passed into solver) aggregator/elasticity parameter
chi   = 1;        % education/skill choice curvature parameter

%% -------------------- Data inputs --------------------
fe  = readmatrix('2015_a.csv');        % skill/education cost shifter (by country)
gdp = readmatrix('2015_rgdp.csv');     % GDP level for normalization / scaling

xi  = ones(N,1);                       % auxiliary vector (e.g., productivity shifter), set to 1

% Factor prices (initial guesses / data-based starting values)
w_l = readmatrix('2015_wage.csv');     % low-skill wage
r   = readmatrix('2015_r.csv');        % rental rate / interest rate
w_h = readmatrix('2015_wage_h.csv');   % high-skill wage

%% -------------------- Price normalization --------------------
% Normalize all factor prices by low-skill wage in reference country (index 40)
r   = r   / w_l(40);
w_h = w_h / w_l(40);
w_l = w_l / w_l(40);

%% -------------------- Technology and production parameters --------------------

T_data      = readmatrix('2015_tech.csv');   % sectoral technology (NxJ)
T_serv_data = ones(N,1);                    % services technology (placeholder = 1)

alpha_J1 = 0.99;                             % Services (TBA)
beta_J1  = 0.99;                             % Services (TBA)

prod_param = readmatrix('2015naics.csv')';   % production parameters by sector
alpha = prod_param(2,:)';                    % capital share (by sector)
beta  = prod_param(3,:)';                    % skill share / intermediate share (by sector)

%% -------------------- Depreciation / savings / investment rule --------------------

delt = readmatrix('2015_d.csv');             % depreciation rate by country
s    = readmatrix('2015_s.csv');             % savings or investment propensity (raw)
s    = delt .* 5;                            % imposed rule: savings proportional to depreciation

%% -------------------- Preference weights / omega --------------------

omega = readmatrix('2015_omega.csv');        % taste weights (possibly NxJ or Nx1)
omega = ones(size(omega,1),1) * mean(omega,1); % replace heterogeneity with common mean weights

%% -------------------- Endowments: labor and capital --------------------

data  = readmatrix('2015_popul.csv');
H     = data(:,1);                           % initial high-skill share (percent or level)
L_tot = data(:,2);                           % total labor force

% Convert initial H into levels of H and L (interpreting H as percent of total)

L = L_tot - H.*L_tot/100;                    % low-skill labor level
H = L_tot - L;                               % high-skill labor level (consistent with above)

K = readmatrix('2015_K.csv');                % initial capital stock by country

%% -------------------- Trade costs --------------------

d_data = readmatrix('2015trade_cost_matrix.csv'); % iceberg trade costs (NxN)
d_data = (d_data).^(7.056/theta);                 % map to model-consistent costs
identity_mask = eye(N) == 1;                      % enforce no domestic trade cost
d_data(identity_mask) = 1;

%% -------------------- Optional tests (all ones) --------------------

% Useful for debugging: removes heterogeneity/trade frictions
% T_data = ones(N,J); d_data = ones(N,N); L = ones(N,1); H = ones(N,1);
% K = ones(N,1); w_l = ones(N,1); w_h = ones(N,1)/5; r = ones(N,1);
% s = ones(N,1)/2;

%% -------------------- Initial equilibrium solve --------------------

% Search() is the GE solver: returns equilibrium factor prices and output
[r,w_l,w_h,Y] = Search(beta_J1,s,K,beta,r,eta,w_l,w_h,N,J,theta,eta,xi,omega, ...
                       L,H,alpha,alpha_J1,T_data,T_serv_data,d_data);

%% -------------------- Output normalization --------------------


% Scale model output to match data GDP (or load externally computed scaling)
normalization = gdp ./ Y;
normalization = readmatrix('Normalization.csv');  % overwrite with saved normalization

%% -------------------- Tracking variables / initialization --------------------

t = 1;
w_hl(t) = w_h(N)/w_l(N);          % skill premium in reference country (index N)
help = w_h ./ w_l;                % cross-country skill premia

% Fix initial high-skill level for one country (index 34), and pin H(9) later
Hs(1) = H(34);

% Re-normalize prices (guard against solver drift in numeraire)
r   = r   / w_l(40);
w_h = w_h / w_l(40);
w_l = w_l / w_l(40);

ChA = L(9)*0.6;                   % exogenous pinned high-skill level for country 9
help = w_h ./ w_l;

%% -------------------- Transition / iterative update loop --------------------

% Each iteration:
% 1) solve GE prices/output
% 2) compute investment from savings * (scaled output)
% 3) update skill composition (H vs L) via a reduced-form schooling choice
% 4) update capital via law of motion
while t < 3100

    [r,w_l,w_h,Y] = Search(beta_J1,s,K,beta,r,eta,w_l,w_h,N,J,theta,eta,xi,omega, ...
                           L,H,alpha,alpha_J1,T_data,T_serv_data,d_data);

    inv = s .* (Y .* normalization);     % investment implied by savings and scaled output

    % Maintain numeraire normalization each iteration
    r   = r   / w_l(40);
    w_h = w_h / w_l(40);
    w_l = w_l / w_l(40);

    for i = 1:N
        % Smooth update of high-skill labor:
        % desired H share depends on relative wages and schooling/entry cost fe(i)
        H(i) = H(i) * 0.95 + 0.05 * (H(i) + L(i)) / (1 + (fe(i)/(w_h(i)/w_l(i)))^(1/chi));

        % Pin country 9 human capital exogenously (policy experiment / calibration target)
        H(9) = ChA;

        % Low-skill labor is residual given total labor
        L(i) = L_tot(i) - H(i);

        % Capital accumulation with depreciation
        K(i) = inv(i) + (1 - delt(i))*K(i);
    end

    t                    % print iteration counter
    t = t + 1;
end

%% -------------------- Post-processing / plots --------------------
K_termsY = K ./ normalization;     % capital scaled by normalization (units comparable)


x = 1;
