function [r,w_l, w_h,Y] = Search(beta_J1,s,K,beta,r,eps,w_l,w_h,N,J,theta,eta,xi,omega,L,H,alpha,alpha_J1,T_data,T_serv_data, d_data)

%TEST%




%%%%%%%%%%%%%%%%%%%%%
diff = 500000;
difflast = diff;
g = 0;
kjk = 0;
rr = 0;

tol = 10;
t = 1;
while diff > tol
    [excess_L, excess_H, excess_K, w_l_new, w_h_new, r_new, Y] = Equilib(beta_J1,s,K,beta,r,eps,t,N,J,theta,eta,xi,omega,L,H,w_l,w_h,alpha,alpha_J1,T_data,T_serv_data, d_data) ;
    r_new = r_new/w_l_new(2);
    w_h_new = w_h_new/w_l_new(2);
    w_l_new = w_l_new/w_l_new(2);

    diff = sqrt(sum((excess_L).^2+(excess_H).^2+(excess_K/1000).^2));
    w_l = w_l_new;
    w_h = w_h_new;
    rlast = r;
    r = r_new;

    diff;


    if diff < 700000
        t = 1;
    end
end
end