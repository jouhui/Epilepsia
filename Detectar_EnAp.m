% function Detectar_Ener_EnAp(Umbral_aux, Pacientes, Carpetas, input, pac)

Umbral_aux = 0.5:0.05:0.95;%

% %% Definir los parametros para cada registro
Pacientes = [{'p1_2'} {'p1_1'} {'p3'} {'p9'}  {'p4'} {'p8_A'} {'p12_A_1'} {'p12_A_2'} {'p1_A'} {'p11'} {'p6_A_1'}];

% %                 CONJUNTO ENTRENAMIENTO
% %
% %
% %

% %                 CONJUNTO PRUEBA
% %{'p6'} {'p15_A_1'} {'p2_1'} {'p1_B_1'} {'p1_B_2'}

Carpetas = [{'Adulto/p1_2'} {'Adulto/p1_1'} {'Adulto/p3'} {'Adulto/p9'} {'Pediatria/p4'} {'Pediatria/p8_A'} {'Adulto/p12_A_1'} {'Adulto/p12_A_2'} {'Pediatria/p1_A'} {'Pediatria/p11'} {'Pediatria/p6_A_1'}];

% %
% %

% %                 CONJUNTO PRUEBA
% %{'Adulto/p6'} {'Pediatria/p15_A_1'} {'Pediatria/p2_1'} {'Pediatria/p1_B_1'} {'Pediatria/p1_B_2'}
%

% Umbrales y parametros estandar como tamano de las ventanas
Lar_Pac = length(Pacientes);
Ventana_VO = 1;
Ventana_KB = 20;
Distancia = 30;

Umbral_AAE_Fijo = 50000; % Listo
Umbral_AAA_Fijo = 50;
Umbral_AAE = 5; %Listo antes 8
Umbral_AAF = 0.1; %Listo
Umbral_AAA = 5;

Umb_Can_Deriv = 0.9;%0.7;
Umb_Can_min = 15;


RA_Escalera = [0 0 0.02 0.02 0.04 0.04 0.06];

Umbral_Fuzz = 0.5;
Umbral_Prop = 1.1;
Umbral_CAmp = 0.5;
Umbral_Corr = 3.5;
Paso = 1;

Feat = 7;
Ener_Detec = 0;
EnAp_Detec = 0;



%% Donde se encuentran cada caracteristica
% Energia total en la banda (posicion 1 a la 6)
% Proporción de Energía en las 6 Bandas (posicion 7 a la 12)
% Energia total de las bandas 2 a 14 (es la poscicion 13)
% Energia entre las bandas 15 a 30 (posicion 14)
% Energia alta frecuencia (Posicion 15)
% Energia total total (posicion 16)
% La amplitud_VO se determina con la senal original y una ventana de 1 Seg

%% Conjuntos de Clasificaci�n
VerPos = zeros(Lar_Pac,length(Umbral_aux));
FalPos = zeros(Lar_Pac,length(Umbral_aux));
FalNeg = zeros(Lar_Pac,length(Umbral_aux));
VerNeg = zeros(Lar_Pac,length(Umbral_aux));
FPHora = zeros(Lar_Pac,length(Umbral_aux));
Crisis = zeros(Lar_Pac,length(Umbral_aux));

VerPos10 = zeros(Lar_Pac,length(Umbral_aux));
FalPos10 = zeros(Lar_Pac,length(Umbral_aux));
FalNeg10 = zeros(Lar_Pac,length(Umbral_aux));
VerNeg10 = zeros(Lar_Pac,length(Umbral_aux));
FPHora10 = zeros(Lar_Pac,length(Umbral_aux));
Crisis10 = zeros(Lar_Pac,length(Umbral_aux));

VerPos_M1 = zeros(Lar_Pac,length(Umbral_aux));
FalPos_M1 = zeros(Lar_Pac,length(Umbral_aux));
FalNeg_M1 = zeros(Lar_Pac,length(Umbral_aux));
VerNeg_M1 = zeros(Lar_Pac,length(Umbral_aux));
FPHora_M1 = zeros(Lar_Pac,length(Umbral_aux));
Crisis_M1 = zeros(Lar_Pac,length(Umbral_aux));

VerPos10_M1 = zeros(Lar_Pac,length(Umbral_aux));
FalPos10_M1 = zeros(Lar_Pac,length(Umbral_aux));
FalNeg10_M1 = zeros(Lar_Pac,length(Umbral_aux));
VerNeg10_M1 = zeros(Lar_Pac,length(Umbral_aux));
FPHora10_M1 = zeros(Lar_Pac,length(Umbral_aux));
Crisis10_M1 = zeros(Lar_Pac,length(Umbral_aux));

% load('Tasas.mat')
Tiempo = zeros(10,Lar_Pac,length(Umbral_aux));
%% Determinar inicios y fin de las crisis
for pac = 1:Lar_Pac
    Pacientes(pac)
    if pac > 0
        clear Umb_UMin Banda_Afectada Posiciones Canals_Af Para_KB Posiciones Canals_Af Para_KB Deteccion Deteccion2 Deteccion_AAE FA Suavizado_Fil_Ener
        
        %% Se cargan las caracteristicas y los labes, ademas se crea una carpeta
        % con el nombre del paciente para guardar los resultados
        
        Cargar = strcat(Carpetas(pac),'_Caract_Fil_Suav.mat');
        load(char(Cargar))
        Cargar_alfa = strcat(Pacientes(pac),'_Ener_Alfa.mat');
        load(char(Cargar_alfa))
        Cargar_theta = strcat(Pacientes(pac),'_Ener_AlTh.mat');
        load(char(Cargar_theta))
        Entrada = strcat(Pacientes(pac), '_Datos.mat');
        load(char(Entrada))
        Label = strcat(Pacientes(pac),'_marcas_Finales.mat');
        load(char(Label))
        Nombre_dir = strcat('ResultadosN/ResultadoFIN', Pacientes(pac));
        mkdir(char(Nombre_dir))
        
        %Datos = input;
        Datos_Ener = Energia_VO_Suav(:,:,1:Feat);
        Datos_EnAp = Entropia_VO_Fil_Suav(:,:);
        
        Energia_Theta = Energia_VO_AlTh_Suav(:,:,3:4);
        Energia_Alfa = Energia_VO_Alfa_Suav(:,:,6:10);
        Energia_Total = Energia_VO_Suav(:,:,Feat*2 + 2);
        Energia_BA_Total = Energia_VO_Suav(:,:,Feat*2 + 1);
        Energia_AltaFre = Energia_VO_Suav(:,:,Feat*2+3);
        Proporcion = Energia_VO_Suav(:,:,Feat+1:Feat*2);
        
        [Deteccion_AAA, CocA] = Gotman_Artefactos(Amplitud_VO_Fil, Umbral_AAA, Umbral_AAA_Fijo, 20, 30, Paso, Umb_Can_Deriv);%
        [Deteccion_AAE, CocE] = Gotman_Artefactos(Energia_Total, Umbral_AAE, Umbral_AAE_Fijo, 20, 30, Paso, Umb_Can_Deriv);%
        [Deteccion_AAF] = Artefactos_Preprocesamiento(Energia_AltaFre, Umbral_AAF, Umb_Can_Deriv);%
        
        CocA = 1;
        
        
        Umb = 1;
        %% Se varia el umbral para encontrar las mejores tasas
        for U = Umbral_aux
            
            clear Umbral_Sis_EnAp Umbral_Sis_Ener Posiciones Canals_Af Banda_Afectada
            Umb_UMin(1,:) = ones(1,18);
            Retoma_Ener = 0;
            Retoma_EnAp = 0;
            
            Umbral_Alfa = 0.17*ones(1,7) - RA_Escalera;
            
            Cabus_Ant_EnAp = median(Entropia_VO_Fil_Suav(11:30,:));
            Estado_Normal_EnAp = 0;
            Sumador_Es_EnAp = zeros(1,18);
            
            %% Se Setean en cero todos los parametros, como el sumador, las tasas de aprendizaje
            % Los umbrales adaptativos, la posicion inicial del cabus y la VO
            
            Sumador_EnAp = zeros(18,1);
            Sumador_PO = zeros(18,1);
            
            LR_UETM_Ant = 0.95*ones(1,18);
            LR_Sistema_EnAp = ones(18,1)*0.95;
            
            
            Umbral_EnAp = U*ones(18,1);
            Umbral_PO = 0.7;
            
            Umbral_Sis_EnAp(1,:) = ones(18,1);
            Umbral_Sis_Ener(1,:,:) = ones(18,Feat);
            
            Posiciones(1,:) = ones(1,2);
            Canals_Af(1,:) = ones(1,18);
            Banda_Afectada(1) = 0;
            
            Nombre_arch = strcat(Nombre_dir, '/U',num2str(U),'.mat');
            
            %Proporcion = Energia_VO_Suav(:,:,16:32);
            
            Canal_EnAp = 1;
            BandaEnAp = 1;
            
            Pos_VO_Ener = Distancia + 2 + Ventana_KB;
            Pos_KB_Ener = 2;
            Pos_VO_EnAp = Distancia + 2 + Ventana_KB;
            Pos_KB_EnAp = 2;
            Pos_VO_PO = 10;
            State_Seiz_Ener = 0;
            State_Seiz_EnAp = 0;
            
            UETM_Ant = ones(1,18)*min(min(Energia_Total(15:65,:)));
            
            A = 0;
            B = 0;
            k = 1;
            
            clear Detectados
            
            Detectados(1,1) = {'Posicion'};
            Detectados(1,2) = {'Sistema'};
            Detectados(1,3) = {'Umbral'};
            Detectados(1,4) = {'Banda'};
            Detectados(1,5) = {'Canales'};
            
            Deteccion = zeros(length(Amplitud_VO_Fil(:,1)),18);
            
            Deteccion2 = zeros(length(Amplitud_VO_Fil(:,1)),18);
            
            %% Se realiza el Preprocesamiento de artefatos
            % Donde los artefactos son de alta Energia, alta frecuencia y alta
            % Amplitud.
            
            [Artefactos_Prepro] = Suma_Artefactos(Deteccion_AAE, Deteccion_AAF);
            [Artefactos_Prepro1] = Suma_Artefactos(Artefactos_Prepro, Deteccion_AAA);
            [Artefactos_Prepro2] = Canales_AMC(Artefactos_Prepro1, Umb_Can_min);
            
            VO_EnAp = zeros(length(Datos_EnAp(:,1)),18);
            Cabus_EnAp = zeros(length(Datos_EnAp(:,1)),18);
            Ubi_KB_EnAp = zeros(length(Datos_EnAp(:,1)),1);
            Umb_EnAp = zeros(length(Datos_EnAp(:,1)),18 );
            %% Se realiza el ciclo de la deteccion de crisis
            
            while true
                %% Se ingresan los dato al detector de crisis
                % Cuando encuentre una sospecha, se obtendran los datos de esta
                % como su canal, su banda dominante, etc.
                
                tic
                [Posicion_EnAp, Pto_anterior_VO_EnAp, Pto_anterior_KB_EnAp, Afectados_EnAp, Largo_Sei_EnAp, Sumado_EnAp, VO_EnAp, Cabus_EnAp, Ubi_KB_EnAp, Umb_EnAp, Canal_EnAp, Umbral_post_EnAp, New_LR_EnAp, Cabus_Ant_EnAp, Estado_Normal_EnAp, Sumador_Es_EnAp] = Sis_Umb_EnAp_VO_Ext_ConKB_PostProc(Datos_EnAp, Umbral_EnAp, Ventana_KB, Distancia, Pos_VO_EnAp, Pos_KB_EnAp, Sumador_EnAp, Retoma_EnAp, Artefactos_Prepro2, VO_EnAp, Cabus_EnAp, Ubi_KB_EnAp, Umb_EnAp, LR_Sistema_EnAp, Cabus_Ant_EnAp, Estado_Normal_EnAp, Sumador_Es_EnAp, Canal_EnAp);
                Tiempo(1,pac,Umb) = Tiempo(1,pac,Umb) + toc;
                
                for h = 1:length(Afectados_EnAp)
                    if Afectados_EnAp(h) == 1
                        Deteccion2(Posicion_EnAp(1,1) - 1:Posicion_EnAp(1,2) - 1,h) = Afectados_EnAp(h);
                    end
                end
                Pto_anterior_VO_Ener = Pos_VO_Ener;
                Indicador_para = 2;
                
                % Si la ventana de VO es igual a el largo de los datos, se debe
                % romper el ciclo ya que se recorrio el registro completo
                
                Canales_EnAp = Afectados_EnAp;
                
                if Pto_anterior_VO_EnAp == length(Datos_EnAp(:,1))
                    break;
                end
                
                
                
                %% Se aplica el post procesamiento, donde se tratan de eliminar los FP
                
                Retoma_EnAp = 1;
                EnAp_Detec = 0;
                
                % Detecciones para Entropia
                
                
                if sum(Posicion_EnAp) ~= 0
                    [Trabaja_EnAp, Canales_EnAp] = Frecuencia_para_EnAp(Proporcion, Posicion_EnAp, Canales_EnAp, Pto_anterior_KB_EnAp);
                    [BandaEnAp] = Banda_Entropia(Proporcion, Posicion_EnAp, Canales_EnAp, Pto_anterior_KB_EnAp);
                    % %                     Tiempo(8,pac,Umb) = Tiempo(2,pac,Umb) + toc;
                    
                    if Trabaja_EnAp == 1
                        [Criterio_Ritmos_Alfa] = Evaluacion_Ritmos_Alfa(Energia_Alfa,Energia_Theta, Canales_EnAp, Posicion_EnAp, Umbral_Alfa, BandaEnAp);%
                        
                        if Criterio_Ritmos_Alfa == 1
                            % %                         % Deteccion por Energia minima
                            % %                         tic
                            [Deteccion_UEMT_EnAp, UETM_Act, LR_UETM_Act, Canales_EnAp] = Minima_Energia(Energia_BA_Total, Posicion_EnAp, Canales_EnAp, UETM_Ant, LR_UETM_Ant);
                            % %                         Tiempo(2,pac,Umb) = Tiempo(2,pac,Umb) + toc;
                            % %
                            if Deteccion_UEMT_EnAp == 1
                                % %                             % Deteccion por correlacion entre canales
                                % %                             tic
                                [Deteccion_Corr_EnAp, Canales_EnAp] = Deteccion_correlacion(Correlation_VO_Suav, Canales_EnAp, Posicion_EnAp, Pto_anterior_KB_EnAp, Umbral_Corr);%
                                % %                             Tiempo(3,pac,Umb) = Tiempo(3,pac,Umb) + toc;
                                % %
                                if Deteccion_Corr_EnAp == 1
                                    % %                                 %La amplitud de los vecinos debe ser mayor al cincuenta
                                    % %                                 tic
                                    [Criterio_Amplitud_EnAp, Canales_EnAp] = Criterio_Amplitud(Amplitud_VO_Fil_Suav, Posicion_EnAp, Canales_EnAp, Umbral_CAmp);%
                                    % %                                 Tiempo(6,pac,Umb) = Tiempo(6,pac,Umb) + toc;
                                    
                                    if Criterio_Amplitud_EnAp == 1
                                        % %                                     tic
                                        %                                     %                                 if Pto_anterior_KB_EnAp > 5*60 + 10
                                        Entropia_Prom_EnAp = median(Datos_EnAp(Pto_anterior_KB_EnAp:Pto_anterior_KB_EnAp + 19,:));
                                        Energia_Prom_EnAp = median(Datos_Ener(Pto_anterior_KB_EnAp:Pto_anterior_KB_EnAp + 19,:,:));
                                        [Deteccion_Fuzzy_EnAp, Canales_EnAp] = Modulo_Difuso(Datos_Ener, Datos_EnAp, Energia_BA_Total, Posicion_EnAp, Canales_EnAp, Energia_Prom_EnAp, Entropia_Prom_EnAp, BandaEnAp, Umbral_Fuzz, Pos_KB_EnAp);%
                                        %                                     Tiempo(7,pac,Umb) = Tiempo(7,pac,Umb) + toc;
                                        if Deteccion_Fuzzy_EnAp == 1
                                            EnAp_Detec = 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                
                B = B + 1;
                
                %% Si se cumplen las condiciones de ritmicidad y energía minima, se actualizan los umbrales
                
                
                Posiciones(k,:) = Posicion_EnAp;
                Canals_Af(k,:) = Canales_EnAp;
                Banda_Afectada(k) =  BandaEnAp;
                
                Umbral_Sis_EnAp(k,:) = Umbral_EnAp;
                
                % Umbral Sistema
                Umbral_EnAp = Umbral_post_EnAp;
                LR_Sistema_EnAp = New_LR_EnAp;
                
                Umb_UMin(k,:) = UETM_Ant;
                
                A = A + 1;
                for h = 1:length(Afectados_EnAp)
                    if Canales_EnAp(h) == 1
                        Deteccion(Posicion_EnAp(1,1) - 1:Posicion_EnAp(1,2) - 1,h) = Canales_EnAp(h);
                    end
                end
                Detectados(k + 1,1) = { Posicion_EnAp };
                Detectados(k + 1,2) = {'Entropia'};
                Detectados(k + 1,3) = { Umbral_EnAp };
                Detectados(k + 1,4) = {BandaEnAp};
                Detectados(k + 1,5) = {Canales_EnAp};
                
                k = k + 1;
                %% Se actualizan los datos para ingresarlos de nuevo al algortimo de deteccion de sospechas
                
                Pos_VO_EnAp = Pto_anterior_VO_EnAp;
                Pos_KB_EnAp = Pto_anterior_KB_EnAp;
                Sumador_EnAp = Sumado_EnAp - Largo_Sei_EnAp;
                State_Seiz_EnAp = 1;
            end
            
            %% Determinar las tasas
            [Deteccion_Sistema_M2] = Filtro_Campo(Deteccion, 11);
            [Deteccion_Sistema_M1] = Filtro_Campo(Deteccion2, 11);
            [Vector_GT] = generarGT(labelSet, Deteccion', 0, 1);
            [VP, FP, FN, VN, Esp, Sen, TFPh] = Matriz_Conf_Train2(Vector_GT,Deteccion_Sistema_M2);
            [VP_M1, FP_M1, FN_M1, VN_M1, Esp_M1, Sen_M1, TFPh_M1] = Matriz_Conf_Train2(Vector_GT,Deteccion_Sistema_M1);
            [VP10, FP10, FN10, VN10, Esp10, Sen10] = Matriz_Conf_Train(Vector_GT,Deteccion_Sistema_M2,11);
            [VP10_M1, FP10_M1, FN10_M1, VN10_M1, Esp10_M1, Sen10_M1] = Matriz_Conf_Train(Vector_GT,Deteccion_Sistema_M1,11);
            
            %             [Deteccion_Sistema_M2] = Filtro_Campo(Deteccion, 11);
            %             VeP = 0;
            %             TOT = 0;
            %             ASUI = Vector_GT.*Deteccion_Sistema_M2;
            %             for i = 1:length(ASUI)-1
            %                 if Deteccion_Sistema_M2(i) < Deteccion_Sistema_M2(i+1)
            %                     TOT = TOT + 1;
            %                 end
            %                 if ASUI(i) < ASUI(i+1)
            %                     VeP = VeP + 1;
            %                 end
            %             end
            %             FaP = TOT-VeP;
            
            
            VerPos_M1(pac,Umb) = VP_M1;
            VerNeg_M1(pac,Umb) = VN_M1;
            FalPos_M1(pac,Umb) = FP_M1;
            FalNeg_M1(pac,Umb) = FN_M1;
            FPHora_M1(pac,Umb) = TFPh_M1;
            Crisis_M1(pac,Umb) = length(labelSet(:,1));
            
            VerPos10_M1(pac,Umb) = VP10_M1;
            VerNeg10_M1(pac,Umb) = VN10_M1;
            FalPos10_M1(pac,Umb) = FP10_M1;
            FalNeg10_M1(pac,Umb) = FN10_M1;
            Crisis10_M1(pac,Umb) = length(labelSet(:,1));
            
            VerPos(pac,Umb) = VP;
            VerNeg(pac,Umb) = VN;
            FalPos(pac,Umb) = FP;
            FalNeg(pac,Umb) = FN;
            FPHora(pac,Umb) = TFPh;
            Crisis(pac,Umb) = length(labelSet(:,1));
            
            VerPos10(pac,Umb) = VP10;
            VerNeg10(pac,Umb) = VN10;
            FalPos10(pac,Umb) = FP10;
            FalNeg10(pac,Umb) = FN10;
            Crisis10(pac,Umb) = length(labelSet(:,1));
            
            
            
            %Name_Save = strcat(char(Pacientes(pac)),'_Resultados_Ener.mat');
            Name_Save = Nombre_arch;
            save(char(Name_Save),'Detectados','VP','VP_M1', 'FP','FP_M1', 'VN','VN_M1', 'FN','FN_M1','Sen','Esp', 'TFPh','TFPh_M1', 'Energia_VO_Suav','Amplitud_VO_Fil', 'Entropia_VO_Fil_Suav', 'Posiciones','Canals_Af','Deteccion','Deteccion2', 'Deteccion_AAE', 'Deteccion_AAF', 'Deteccion_AAA', 'Artefactos_Prepro2', 'labelSet', 'A','B', 'Umbral_AAE', 'Umbral_AAA', 'Umbral_AAF', 'VO_EnAp','Cabus_EnAp', 'Umb_EnAp','Umb_UMin','Ubi_KB_EnAp', 'Banda_Afectada','Vector_GT', 'Umbral_Sis_EnAp','CocA', 'CocE', 'LR_Sistema_EnAp');
            
            
            Umb  = Umb + 1;
        end
    end
end
%
save('ResultadosN/Tasas.mat','Tiempo' , 'VerPos', 'VerPos_M1', 'VerNeg','VerNeg_M1','FalPos','FalPos_M1','FalNeg','FalNeg_M1','FPHora','FPHora_M1','VerPos10','VerPos10_M1', 'VerNeg10', 'VerNeg10_M1','FalPos10', 'FalPos10_M1','FalNeg10','FalNeg10_M1', 'Crisis','Umbral_aux','Pacientes');
VerPGen = sum(VerPos);
FalPGen = sum(FalPos);
FalNGen = sum(FalNeg);
VerNGen = sum(VerNeg);
B =VerPGen+FalPGen;
A = VerPGen+FalNGen;
Sen = VerPGen./A;
Esp = 1-FalPGen./B;

VerPGenM1 = sum(VerPos_M1);
FalPGenM1 = sum(FalPos_M1);
FalNGenM1 = sum(FalNeg_M1);
VerNGenM1 = sum(VerNeg_M1);
B_M1 =VerPGenM1+FalPGenM1;
A_M1 = VerPGenM1+FalNGenM1;
Sen_M1 = VerPGenM1./A_M1;
Esp_M1 = 1-FalPGenM1./B_M1;


%
% figure,plot(1-Esp,Sen)
% axis([0 1 0 1])
% xlabel('Tasa de falsos positivos')
% ylabel('Tasa de Verdaderos positivos')
% title('Curva ROC de clasificacion')
%
