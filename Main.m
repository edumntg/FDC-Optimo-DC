%   Flujo de carga optimo AC mediante fmincon
%   En este flujo de carga los flujos de lineas se establecen como
%   variables

clc, clear all;

deltat = 1;

[BUSDATA, LINEDATA, GENDATA] = LoadData('DATOS_3b_3g.xlsx', 'BUS', 'RAMAS', 'GEN');
% [BUSDATA, LINEDATA, GENDATA] = LoadData('BUSDATA_Wollenberg.dat', 'RAMAS_Wollenberg.dat', 'GENDATA_Wollenberg.dat');

nb = size(BUSDATA, 1);
ng = size(GENDATA, 1);
nl = size(LINEDATA, 1);

[Ybus, Gik, Bik, gi0, bi0] = CreateYbus(LINEDATA, nb, nl);

Pload = BUSDATA(:, 6).*deltat;
Pgen = BUSDATA(:, 8);

ci = GENDATA(:, 2);
bi = GENDATA(:, 3); %Cmg
ai = GENDATA(:, 4);

Pgmin = GENDATA(:, 5).*deltat;
Pgmax = GENDATA(:, 6).*deltat;

Pflowmax = LINEDATA(:, 7).*deltat;

Pflowmax(Pflowmax >= 1e10) = Inf;       % Si se declara un maximo >= 1e10, se asigna como infinito

refang = BUSDATA(:, 3);

%%      

%       Las matrices como vectores tendran (ng + nl + nb - 1)  columnas

%       Esto corresponde a 'ng + ng Potencias generadas', 'nl' flujos en lineas y 'nb - 1 variables por
%       barra (nb - 1 angulos como incognitas de angulos)

%       La matriz Aeq tendra nb filas y (ng + nl + nb - 1) columnas
%       Pues sera una ecuacion por cada barra con generador (ecuaciones
%       lineales)

Amq = zeros(nb, ng);
Bmq = zeros(nb, nl);
Cmq = zeros(nb, nb - 1);
Dmq = zeros(nl, ng);
Emq = eye(nl, nl);
Fmq = zeros(nl, nb - 1);

for i = 1:ng
    Amq(i,i) = 1;
end

%       Llenamos la matriz Bmq con los terminos correspondientes a las
%       variables de flujos de lineas correspondientes a cada ecuacion de
%       potencia generada
%       Pgi = P12 + P12 + ... Pik + Ploadi
%       Pgi - P12 - P13 - ... Pik = Ploadi

for i = 1:nb
    for l = 1:nl
        from = LINEDATA(l, 1);
        to = LINEDATA(l, 2);
        if from ~= to % es una linea. en FCO DC no contamos los shunts
            if i == from
                Bmq(i, l) = -1; % negativo debido a que al pasar al mismo lado de la igualdad pasa con signo contrario
            end
            if i == to
                Bmq(i, l) = 1;
            end
        end
    end
end

orden_theta = zeros(nb, 1);
v = 1;
vtheta = 1;
for i = 1:nb
    if refang(i) == 0
        orden_theta(v) = vtheta;
        v = v + 1;
        vtheta = vtheta + 1;
    else
        orden_theta(v) = 0;
        v = v + 1;
    end
end

for l = 1:nl
    v = 1;
    from = LINEDATA(l, 1);
    to = LINEDATA(l, 2);
    if from ~= to % es una linea
        if refang(from) == 0
            Fmq(l, orden_theta(from)) = -Bik(from, to);
        end   

        if refang(to) == 0
            Fmq(l, orden_theta(to)) = Bik(from, to);
        end
    end
end

Aeq = [Amq Bmq Cmq
       Dmq Emq Fmq];
   
beq = zeros(nb + nl, 1);
beq(1:nb) = Pload(1:nb);
A = [];
b = [];
 
%       Se establecen los limites inferiores y superiores (lb y ub)
lb = Pgmin;
lb = vertcat(lb, -Pflowmax);

lb = vertcat(lb, -ones(nb - 1, 1).*Inf);

ub = Pgmax;
ub = vertcat(ub, Pflowmax);

ub = vertcat(ub, ones(nb - 1, 1).*Inf);

%       Vector de valores iniciales
x0 = zeros(1, (ng + nl + nb - 1));

options = optimset('display', 'on', 'algorithm', 'interior-point'); 
[x,fval,exitflag,~,lambda] = fmincon('FuncObjetivo', x0, A, b, Aeq, beq, lb, ub, [], options, ci, bi, ai, ng);
exitflag

Pg = x(1:ng);
Pgen = Pg;
Pgen(ng+1:nb) = 0;
Pik = x((ng + 1):(ng + nl));

theta = zeros(nb, 1);
v = 1;
for i = 1:nb
    if refang(i) == 0
        theta(i) = x((ng + nl) + v);
        v = v + 1;
    end
end

Pneta = Pgen' - Pload;

lamb = abs(lambda.eqlin);
% 
% %Kuhn-Tucker
eta = abs(lambda.lower);
miu = abs(lambda.upper);
% 
Costo_generacion = sum(ci + bi.*Pg' + ai.*Pg'.^2);
% Cobro_transmision = sum(eta((ng + ng + 1):(ng + ng + nl)).*Pik') + ...
%                     sum(eta((ng + ng + nl + 1):(ng + ng +nl + nl)).*Pki') + ...
%                     sum(miu((ng + ng + 1):(ng + ng + nl)).*Pik') + ...
%                     sum(miu((ng + ng + nl + 1):(ng + ng +nl + nl)).*Pki');
%                 
PrintFCO(theta, Pgen, Pload, Pneta, Pik, Pflowmax, Costo_generacion, LINEDATA, nb, nl);

% lambda.eqnonlin
% lambda.ineqlin
% lambda.upper
% lambda.lower