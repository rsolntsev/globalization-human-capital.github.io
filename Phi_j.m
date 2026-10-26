function [Phi, p, P] = calculateEconomicVariables(T, c, d, theta, Gamma, omega, eta, B, xi, TJ1, cJ1)
    % Inputs:
    % T - Technology (N×T×J array)
    % c - Cost (N×T×J array)
    % d - Trade costs (N×N×T×J array)
    % theta - Elasticity parameter
    % Gamma - Constant for price calculation
    % omega - Sector weights (J×1 vector)
    % eta - Elasticity of substitution
    % B - Country-specific constant (N×1 vector)
    % xi - Consumption share (N×T matrix)
    % TJ1 - Technology for J+1 sector (N×T matrix)
    % cJ1 - Cost for J+1 sector (N×T matrix)
    
    [N, T, J] = size(c);
    
    % Initialize arrays
    Phi = zeros(N, T, J+1);  % Phi for J sectors + 1 additional sector
    p = zeros(N, T, J+1);    % Prices for all sectors
    P = zeros(N, T);         % Aggregate price index
    
    % Calculate Phi for sectors j = 1..J
    for n = 1:N
        for t = 1:T
            for j = 1:J
                % Sum over all countries i
                sum_term = 0;
                for i = 1:N
                    sum_term = sum_term + T(i,t,j) * (c(i,t,j) * d(n,i,t,j))^(-theta);
                end
                Phi(n,t,j) = sum_term;
            end
        end
    end
    
    % Calculate Phi for sector J+1
    for n = 1:N
        for t = 1:T
            Phi(n,t,J+1) = TJ1(n,t) * (cJ1(n,t))^(-theta);
        end
    end
    
    % Calculate prices p
    for n = 1:N
        for t = 1:T
            for j = 1:J+1
                p(n,t,j) = Gamma * (Phi(n,t,j))^(-1/theta);
            end
        end
    end
    
    % Calculate aggregate price index P
    for n = 1:N
        for t = 1:T
            % Sum over sectors j = 1..J
            sum_term = 0;
            for j = 1:J
                sum_term = sum_term + omega(j) * (p(n,t,j))^(1-eta);
            end
            
            P(n,t) = B(n) * (sum_term)^(1/(1-eta))^xi(n,t) * (p(n,t,J+1))^(1-xi(n,t));
        end
    end
end