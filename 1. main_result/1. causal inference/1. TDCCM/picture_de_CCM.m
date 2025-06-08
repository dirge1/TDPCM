clear; clc; close all
load result_de_CCM_E4.mat
fosize = 16;
n_var = size(data, 2);
o = 0;
figure
for i = 1:n_var
    for j = [1:i-1, i+1:n_var]
        o = o + 1;
        % �������������е�subplotλ��
        row = mod((o-1), 7) + 1; % ������λ��
        col = ceil(o / 7);       % ������λ��
        % �����к��м���subplotλ��
        position = (row - 1) * 8 + col;
        ax = subplot(7, 8, position);

        % ��ȡ����
        x_data = -P;
        y_data = matrix_causal_delay{i}(:, j);

        % ��������
        plot(x_data, y_data, 'LineWidth', 2)
        hold on

        % �ҵ����ֵ����λ��
        [max_value, max_idx] = max(y_data);
        max_x = x_data(max_idx);

        % �ж��Ƿ���ʾ���ֵ�����ڳ���0.2ʱ��
        if max_value > 0
            % ������ֵ
            plot(max_x, max_value, 'ro', 'MarkerSize', 6, 'LineWidth', 2) % ��ɫԲȦ���

            % �ж�ƫ����ƫ�ң�������ע����
            if max_x >= 0  % ƫ�ң���ʾ�����½�
                offset_x = -1;      % ����һ��
                offset_y = -0.02;   % ����һ��
                text(max_x + offset_x, max_value + offset_y, sprintf(' (%.2f, %.2f)', max_x, max_value), ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
                    'FontSize', fosize - 4, 'FontName', 'Times New Roman', 'Color', 'black')
            else  % ƫ����ʾ�����½�
                offset_x = 1;       % ����һ��
                offset_y = -0.02;   % ����һ��
                text(max_x + offset_x, max_value + offset_y, sprintf(' (%.2f, %.2f)', max_x, max_value), ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
                    'FontSize', fosize - 4, 'FontName', 'Times New Roman', 'Color', 'black')
            end
        end

        % �������һ����ʾx��
        if row == 7
            xlabel('Time Delay', 'FontName', 'Times New Roman')
        else
            set(gca, 'XTickLabel', []); % ����x���ǩ
        end
        
        % y���ǩֻ�ڵ�һ����ʾ
        if col == 1
            ylabel('CCM', 'FontName', 'Times New Roman')
        end

        % ��ӱ���
        title(sprintf('U%d��U%d', j, i), 'FontName', 'Times New Roman')
        set(gca, 'fontsize', fosize, 'fontname', 'Times New Roman');
        grid on
        set(gca, 'GridLineStyle', '--')
        set(ax, 'LooseInset', max(get(ax, 'TightInset'), 0.02));  % �̶��߾�
    end
end
set(gcf, 'unit', 'centimeters', 'position', [0 0 160 360]);
