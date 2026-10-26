function [Y, Y_C] = demand(r,w_l, w_h, L, H, K, p,  omega, eta, xi)
    % Calculates sectoral output Y^{j}_{n} (ignoring time dimension)
    % Inputs:
    % w - Wages (N×1 vector)
    % r - Rental rates (N×1 vector)
    % L - Labor (N×1 vector)
    % K - Capital (N×1 vector)
    % p - Prices (N×J matrix)
    % omega - Sector weights (J×1 vector)
    % eta - Elasticity of substitution
    % xi - Consumption share (N×1 vector)
    
    [N, J] = size(p);
    Y = zeros(N, J);
    
    for n = 1:N
        % Calculate denominator (sum over sectors k=1..J)
        denominator = 0;
        for k = 1:J
            denominator = denominator + omega(n,k) * (p(n,k))^(1-eta);
        end
        
        % Calculate numerator terms
        income = w_l(n) * L(n) + w_h(n) * H(n)+r(n)*K(n);
        xi_n = xi(n);
        
        for j = 1:J
            numerator = omega(n,j) * (p(n,j))^(1-eta);
            Y(n,j) = xi_n * (income / p(n,j)) * (numerator / denominator);
        end

    end

end