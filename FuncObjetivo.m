function f = FuncObjetivo(x, ci, bi, ai, ng)
    Pg = zeros(ng, 1);
    Pg(1:ng) = x(1:ng);

    f = sum(ci + bi.*Pg + ai.*(Pg.^2));
end