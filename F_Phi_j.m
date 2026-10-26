function Phi_j = F_Phi_j(T, c, d, theta)
    % Calculates Φ_{nt}^j for sectors j = 1..J
    % Inputs:
    % T - Technology (N×T×J array)
    % c - Cost (N×T×J array)
    % d - Trade costs (N×N×T×J array)
    % theta - Elasticity parameter
    
    [N, J] = size(c);
    Phi_j = zeros(N, J);
    
    for n = 1:N
            for j = 1:J
                sum_term = 0;
                for i = 1:N
                    sum_term = sum_term + T(i,j) * (c(i,j) * d(n,i))^(-theta);
                end
                Phi_j(n,j) = sum_term;
            end
    end
end