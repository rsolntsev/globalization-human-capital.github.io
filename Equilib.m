function [excess_L, excess_H, excess_K, w_l_new, w_h_new,r_new,  Y] = Equilib(beta_J1,s,K,beta,r,eps,t,N,J,theta,eta,xi,omega,L,H,w_l,w_h,alpha,alpha_J1,T_data,T_serv_data, d_data)

%ALPHA SKILL INTENSITY
% Initialize the cost array (N countries × T periods × J sectors)
c = zeros(N,  J);

% Populate the cost array
for n = 1:N
    for j = 1:J
        c(n,  j) = (((w_h(n))^alpha(j)) * ((w_l(n)))^(1 - alpha(j)))^beta(j)*(r(n)^(1-beta(j)));

    end
    c_J1 = 1;%%%% CORRRRECT
end

Phi_j_num = F_Phi_j(T_data, c, d_data, theta);
Phi_J1_num = F_Phi_J1(T_serv_data, c_J1, theta);
p = Prices(eps,Phi_j_num,theta);
p_serv = Prices(eps,Phi_J1_num,theta);
Y_man = demand(r,w_l,w_h,L,H,K,p,omega,eta,xi);

for n = 1:N
    % Compute right-hand side
    Y_serv(n) = (1 - xi(n)) * (w_l(n) * L(n) + w_h(n) * H(n))/p_serv(n);

end

for n = 1:N
    for i = 1:N
        for j = 1:J
            pi_nitj(i, n, j) = (T_data(i, j) * (c(i, j) * d_data(n, i))^(-theta)) / Phi_j_num(n, j);%i, first - exporter
        end
    end
end
%diagElements = zeros(size(pi_nitj,1), size(pi_nitj,3));  % Preallocate (3x2 in this case)
%for k = 1:size(pi_nitj,3)
%    diagElements(:,k) = diag(pi_nitj(:,:,k));
%end
%
%%%%%%%% Factor Prices
L_man = zeros(N,J);
H_man = zeros(N,J);
K_man = zeros(N,J);
for i = 1:N
    for j = 1:J
        L_man(i, j) = beta(j)*(1-alpha(j)) * sum(pi_nitj(i, :, j) .* (p(:, j) .* Y_man(:, j))') / w_l(i);
        H_man(i,j) = (beta(j)*alpha(j)) * sum(pi_nitj(i, :, j) .* (p(:, j) .* Y_man(:, j))') / w_h(i);
        K_man(i,j) = (1-beta(j)) * sum(pi_nitj(i, :, j) .* (p(:, j) .* Y_man(:, j))') / r(i);
    end
    L_serv(i) = beta_J1*(1-alpha_J1)*Y_serv(i)*p_serv(i)/w_l(i);
    H_serv(i) = beta_J1*(alpha_J1)*Y_serv(i)*p_serv(i)/w_h(i);
    K_serv(i) = (1-beta_J1) * Y_serv(i)*p_serv(i) / r(i);
end

L_man_total = sum(L_man, 2);  % Sum over columns (sectors), result is N×1
H_man_total = sum(H_man, 2);  % Sum over columns (sectors), result is N×1
K_man_total = sum(K_man, 2);
excess_L = (L - L_man_total - L_serv');  % N×1 vector
excess_H = (H - H_man_total - H_serv');  % N×1 vector
excess_K = (K - K_man_total - K_serv');
w_l_new = w_l .* (1- 0.2*excess_L ./ L);  % N×1 vector
w_h_new = w_h .* (1- 0.2*excess_H ./ H); % N×1 vector
r_new = r .* ((1- 0.2*excess_K ./ K)); 
Y = ((sum(omega.^(1/eta) .* Y_man.^((eta-1)/eta), 2)).^(eta/(eta-1)));

%result = zeros(N,J);
%for k = 1:J
%    result(:,k) = diag(pi_nitj(:,:,k));
%end

end