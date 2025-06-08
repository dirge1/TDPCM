clear; clc; close all
load result_de_CCM_E4.mat
fosize = 16;
n_var = size(data, 2);
o = 0;
figure
for i = 1:n_var
    for j = [1:i-1, i+1:n_var]
        o = o + 1;
        % 计算列优先排列的subplot位置
        row = mod((o-1), 7) + 1; % 计算行位置
        col = ceil(o / 7);       % 计算列位置
        % 根据行和列计算subplot位置
        position = (row - 1) * 8 + col;
        ax = subplot(7, 8, position);

        % 获取数据
        x_data = -P;
        y_data = matrix_causal_delay{i}(:, j);

        % 绘制曲线
        plot(x_data, y_data, 'LineWidth', 2)
        hold on

        % 找到最大值及其位置
        [max_value, max_idx] = max(y_data);
        max_x = x_data(max_idx);

        % 判断是否显示最大值（仅在超过0.2时）
        if max_value > 0
            % 标记最大值
            plot(max_x, max_value, 'ro', 'MarkerSize', 6, 'LineWidth', 2) % 红色圆圈标记

            % 判断偏左还是偏右，决定标注方向
            if max_x >= 0  % 偏右，显示在左下角
                offset_x = -1;      % 左移一点
                offset_y = -0.02;   % 下移一点
                text(max_x + offset_x, max_value + offset_y, sprintf(' (%.2f, %.2f)', max_x, max_value), ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
                    'FontSize', fosize - 4, 'FontName', 'Times New Roman', 'Color', 'black')
            else  % 偏左，显示在右下角
                offset_x = 1;       % 右移一点
                offset_y = -0.02;   % 下移一点
                text(max_x + offset_x, max_value + offset_y, sprintf(' (%.2f, %.2f)', max_x, max_value), ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
                    'FontSize', fosize - 4, 'FontName', 'Times New Roman', 'Color', 'black')
            end
        end

        % 仅在最后一行显示x轴
        if row == 7
            xlabel('Time Delay', 'FontName', 'Times New Roman')
        else
            set(gca, 'XTickLabel', []); % 隐藏x轴标签
        end
        
        % y轴标签只在第一列显示
        if col == 1
            ylabel('CCM', 'FontName', 'Times New Roman')
        end

        % 添加标题
        title(sprintf('U%d→U%d', j, i), 'FontName', 'Times New Roman')
        set(gca, 'fontsize', fosize, 'fontname', 'Times New Roman');
        grid on
        set(gca, 'GridLineStyle', '--')
        set(ax, 'LooseInset', max(get(ax, 'TightInset'), 0.02));  % 固定边距
    end
end
set(gcf, 'unit', 'centimeters', 'position', [0 0 160 360]);
