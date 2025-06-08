clear; clc; close all
rng(1107)
load result_model_de_PCM_E4.mat
fosize = 16;
n_var = size(matrix_causal_delay_partial, 2);
    for i=1:7
        delay_range(i) =index{i}(end);
    end

% 紫色区域
index_purple{1} = [];
index_purple{2} = [];
index_purple{3} = [];
index_purple{4} = [];
index_purple{5} = [];
index_purple{6} = [];
index_purple{7} = [];

figure
for i = 1:7
    ax(i) = subplot(2, 4, i); % 保存原坐标轴句柄

    % 获取数据
    x_data = 1:100;
    y_data = matrix_causal_delay_partial(:, i);
    y_lim = [-0.05, 0.7];

    % 蓝色 PCM 主曲线
    h2 = plot(x_data, y_data, '-.', 'Color', [0 0.4470 0.7410], ...
         'LineWidth', 2, 'DisplayName', 'Causal strength');


    % 坐标轴设置
    set(gca, 'fontsize', fosize, 'fontname', 'Times New Roman');
    grid on
    set(gca, 'GridLineStyle', '--')
    ylim(y_lim)
    xlim([0,100])

   
end

set(gcf, 'unit', 'centimeters', 'position', [0 0 28 13]);
