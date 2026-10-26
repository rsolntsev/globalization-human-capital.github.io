function p = Prices(eps,Phi, theta)
    % Calculates prices p_{nt}^j for all sectors
    % Inputs:
    % Phi - Phi values (N×T×(J+1) array)
    % Gamma - Constant
    % theta - Elasticity parameter
    
    p = gamma((theta+1-eps)/theta)^(1/(1-eps))*(Phi).^(-1/theta);
end