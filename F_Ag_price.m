function P = F_Ag_price(p, omega, eta, B, xi)
    % Calculates aggregate price index P_{nt}
    % Inputs:
    % p - Prices (N×T×(J+1) array)
    % omega - Sector weights (J×1 vector)
    % eta - Elasticity of substitution
    % B - Country-specific constant (N×1 vector)
    % xi - Consumption share (N×T matrix)
    
    [N, T, J_plus_1] = size(p);
    J = J_plus_1 - 1;
    
    % Initialize output
    P = zeros(N, T);
    
    for n = 1:N
        for t = 1:T
            % Sum over sectors j = 1..J
            sum_term = 0;
            for j = 1:J
                sum_term = sum_term + omega(j) * (p(n,t,j))^(1-eta);
            end
            
            P(n,t) = B(n) * (sum_term^(1/(1-eta)))^xi(n,t) * (p(n,t,J+1))^(1-xi(n,t));
        end
    end
end