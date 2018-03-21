%% Eduardo Montilva 12-10089
% Script el cual tiene como funcion armar imprimir los resultados del flujo
% de carga
function F = PrintFCO(theta, Pgen, Pload, Pneta, Pik, Pflowmax, Total_cost, LINEDATA, nb, nl)

    head = ['    Bus  Voltage  Angle    ------Load------    ---Generation---    ---P y Q Netos---   Injected'
            '    No.  Mag.      Rad      (p.u)   (p.u)       (p.u)    (p.u)       (p.u)    (p.u)     (p.u)  '
            '                                                                                               '];

    disp(head)

    for i = 1:nb
         fprintf(' %5g', i), fprintf(' %7.4f', 1), fprintf(' %8.4f', theta(i)), fprintf(' %9.4f', abs(Pload(i))), fprintf(' %9.4f', 0), fprintf(' %9.4f', Pgen(i)), fprintf(' %9.4f ', 0), fprintf(' %9.4f', Pneta(i)), fprintf(' %9.4f', 0), fprintf(' %8.4f\n', 0)
    end
        fprintf('      \n'), fprintf('    Total              '), fprintf(' %9.4f', abs(sum(Pload))), fprintf(' %9.4f', 0), fprintf(' %9.4f', sum(Pgen)), fprintf(' %9.4f', 0), fprintf(' %9.4f', sum(Pneta)), fprintf(' %9.4f', 0), fprintf(' %9.4f\n\n', 0)
        fprintf('    Perdidas totales:           '), fprintf(' P: %9.4f ', 0), fprintf(' Q: %9.4f', 0)
        fprintf('\n\n');
        
        
        head_line = ['       Flujos en lineas      '
                     '    Linea  Pik       MWmax   '
                     '                             '];
        disp(head_line);
        for l = 1:nl
            i = LINEDATA(l, 1);
            k = LINEDATA(l, 2);
            fprintf('    %i-%i', i, k), fprintf(' %9.4f', Pik(l)), fprintf(' %9.4f', Pflowmax(l))
            fprintf('\n');
        end
        
        fprintf('\n\n    Costo:       '), fprintf(' %9.4f $/h ', Total_cost)
        fprintf('\n');
end