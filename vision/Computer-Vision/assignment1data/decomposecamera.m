
function [K, Rc_w, Pc, pp, pv] = decomposecamera(P)
       
    % Convenience variables for the columns of P
    p1 = P(:,1);
    p2 = P(:,2);
    p3 = P(:,3);
    p4 = P(:,4);    

    M = [p1 p2 p3];
    m3 = M(3,:)';
    
    % Camera centre, analytic solution
    X =  det([p2 p3 p4]);
    Y = -det([p1 p3 p4]);
    Z =  det([p1 p2 p4]);
    T = -det([p1 p2 p3]);    
    
    Pc = [X;Y;Z;T];  
    Pc = Pc/Pc(4);   
    Pc = Pc(1:3); 
   
    pp = M*m3;
    pp = pp/pp(3); 
    pp = pp(1:2); 
    
    pv = det(M)*m3;
    pv = pv/norm(pv);

    [K, Rc_w] = rq3(M);