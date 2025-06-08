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

    % 底色区域
    initial = optimal_delay(i);
    delay = delay_range(i);
    fill_x_range = [initial, delay];
    h1 = fill([fill_x_range(1) fill_x_range(2) fill_x_range(2) fill_x_range(1)], ...
         [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], ...
         [1 0.9 0.9], 'EdgeColor', 'none', 'DisplayName', 'Time Range');
    hold on;

    % 蓝色 PCM 主曲线
    h2 = plot(x_data, y_data, '-.', 'Color', [0 0.4470 0.7410], ...
         'LineWidth', 2, 'DisplayName', 'Causal strength');

    % 橙色高亮区域
    idx_highlight = index{i};
    h2b = [];
    if ~isempty(idx_highlight)
        d = diff(idx_highlight);
        split_idx = [0, find(d > 1), length(idx_highlight)];
        for k = 1:length(split_idx)-1
            seg = idx_highlight(split_idx(k)+1 : split_idx(k+1));
            h = plot(x_data(seg), y_data(seg), '-', ...
                'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);
            if isempty(h2b)
                h2b = h;
                set(h2b, 'DisplayName', 'Highlighted');
            end
        end
    end

    % 紫色区域
    idx_purple = index_purple{i};
    h5 = [];
    if ~isempty(idx_purple)
        d_p = diff(idx_purple);
        split_idx_p = [0, find(d_p > 1), length(idx_purple)];
        for k = 1:length(split_idx_p)-1
            seg_p = idx_purple(split_idx_p(k)+1 : split_idx_p(k+1));
            h = plot(x_data(seg_p), y_data(seg_p), '-', ...
                'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2.5);
            if isempty(h5)
                h5 = h;
                set(h5, 'DisplayName', 'Purple Highlight');
            end
        end
    end

    % 阈值红线
    h3 = yline(threshold, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Threshold');

    % 标签与标题
    xlabel('Time Delay', 'FontName', 'Times New Roman')
    ylabel('PCM', 'FontName', 'Times New Roman')
    title(sprintf('U%d \\rightarrow U8', i), 'FontName', 'Times New Roman')

    % 图例（仅第5个子图）
    if i == 5
        legend_items = [h1, h3, h2];
        legend_labels = {'Optimized time range', 'Optimized threshold', 'Non-selected features'};
        if ~isempty(h2b)
            legend_items = [legend_items, h2b];
            legend_labels{end+1} = 'Selected features';
        end
        if ~isempty(h5)
            legend_items = [legend_items, h5];
            legend_labels{end+1} = 'Supplemented features';
        end
        legend(legend_items, legend_labels, 'Location', 'northeast', 'FontSize', 14);
    end

    % 坐标轴设置
    set(gca, 'fontsize', fosize, 'fontname', 'Times New Roman');
    grid on
    set(gca, 'GridLineStyle', '--')
    ylim(y_lim)
    xlim([0,100])

   
end

set(gcf, 'unit', 'centimeters', 'position', [0 0 28 13]);
