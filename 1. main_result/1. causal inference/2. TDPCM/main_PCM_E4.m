clear; clc; close all
load debutanizer_dataset.mat
data = data(1:1596,:);

matrix_tau = 1;
matrix_E = 4;  % 设置你当前的E值
origin_v = 8;

configs = {
    % target_v, control_vars,       control_delays,      U_start
    1,        [3 4],              [3 3],               -8;
    2,        [1 3 4],              [12 2 8],              -16;
    3,        [5 7],              [1 1],               -11;
    4,        [1 3 5 6],          [25 20 26 8],       -31;
    5,        [1 3 4 7],            [1 1 0 0],           -9;
    6,        [2 3 5 7],        [19 2 1 1],     -26;
    7,        [2 3 4 5 6],          [19 2 19 2 2],        -24;
    };

U_targets = -1:-1:-100;  % U_eff = U - W ∈ [-1, -100]
num_targets = size(configs,1);
matrix_causal_delay_partial = zeros(length(U_targets), num_targets);  % 每列一个 target_v 的结果

for i = 1:num_targets
    target_v = configs{i,1};
    control_vars = configs{i,2};
    control_delays = configs{i,3};
    U_main = configs{i,4};
    
    delay_min = min(control_delays);
    WW = U_main - U_targets;
    R_partial = zeros(1, length(WW));
    
    parfor oo = 1:length(WW)
        W = WW(oo);
        UV = -delay_min - W;
        U = U_main - W;
        
        control_matrix = [];
        [Y_estimate_main, ~, ~] = CCM(U, origin_v, target_v, matrix_tau, matrix_E, data);
        
        Y_est_controls = cell(1, length(control_vars));
        for k = 1:length(control_vars)
            delay_k = control_delays(k);
            U_control = -delay_k - W;
            [Y_est_controls{k}, ~, ~] = CCM(U_control, control_vars(k), target_v, matrix_tau, matrix_E, data);
        end
        
        if UV > 0
            YX = data(matrix_E + UV:end, target_v);
            YY = Y_estimate_main(1 + UV:end, 1);
            YZ = cell(1, length(control_vars));
            for k = 1:length(control_vars)
                if control_delays(k) > delay_min
                    YZ{k} = Y_est_controls{k}(1 + UV:end, 1);
                else
                    YZ{k} = Y_est_controls{k};
                end
            end
        else
            YX = data(matrix_E:end, target_v);
            YY = Y_estimate_main;
            YZ = Y_est_controls;
        end
        
        min_size = min([length(YX), length(YY), cellfun(@length, YZ)]);
        YX = YX(1:min_size);
        YY = YY(1:min_size);
        for k = 1:length(YZ)
            YZ{k} = YZ{k}(1:min_size);
            control_matrix(:,k) = YZ{k};
        end
        R_partial(oo) = partialcorr(YX, YY, control_matrix)';
    end
    
    matrix_causal_delay_partial(:,i) = R_partial(:);
end

% 保存所有结果为一个文件
save(sprintf('result_de_PCM_E%d.mat', matrix_E), 'matrix_causal_delay_partial')
