function Phi_J1 = F_Phi_J1(T_J1, c_J1, theta)
    % Calculates Φ_{nt}^{J+1} for the additional sector
    % Inputs:
    % T_J1 - Technology for J+1 sector (N×T matrix)
    % c_J1 - Cost for J+1 sector (N×T matrix)
    % theta - Elasticity parameter
    
    Phi_J1 = T_J1 .* (c_J1).^(-theta);
end