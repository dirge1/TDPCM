clear; clc; close all
load debutanizer_dataset.mat

sample_sizes = 10*19:19:1596;  % 要观察的样本长度
matrix_tau = 1;
matrix_E = 4;
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
num_targets = size(configs, 1);
optimal_delay=[6 27 10 23 7 9 10]; % E4
for i=1:num_targets
    adjust_delay(i)=configs{i,4}+optimal_delay(i);
end
% 预分配 matrix 保存 PCM 结果：行是样本长度，列是 target_v
PCM_W0_matrix = zeros(length(sample_sizes), num_targets);

parfor ss = 1:length(sample_sizes)
    current_len = sample_sizes(ss);
    data_subset = data(1:current_len, :);  % 当前样本数的数据

    for i = 1:num_targets
        target_v = configs{i,1};
        control_vars = configs{i,2};
        control_delays = configs{i,3};
        U_main = configs{i,4};

        W = adjust_delay(i);  % 只计算 WW=0
        UV = -min(control_delays) - W;
        U = U_main - W;

        control_matrix = [];
        [Y_estimate_main, ~, ~] = CCM(U, origin_v, target_v, matrix_tau, matrix_E, data_subset);

        Y_est_controls = cell(1, length(control_vars));
        for k = 1:length(control_vars)
            delay_k = control_delays(k);
            U_control = -delay_k - W;
            [Y_est_controls{k}, ~, ~] = CCM(U_control, control_vars(k), target_v, matrix_tau, matrix_E, data_subset);
        end

        if UV > 0
            YX = data_subset(2 + UV:end, target_v);
            YY = Y_estimate_main(1 + UV:end, 1);
            YZ = cell(1, length(control_vars));
            for k = 1:length(control_vars)
                if control_delays(k) > min(control_delays)
                    YZ{k} = Y_est_controls{k}(1 + UV:end, 1);
                else
                    YZ{k} = Y_est_controls{k};
                end
            end
        else
            YX = data_subset(2:end, target_v);
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

        PCM_W0_matrix(ss, i) = partialcorr(YX, YY, control_matrix);
    end
end

% 保存为文件
save(sprintf('result_PCM_E%d_W0.mat', matrix_E));
