clear;clc;close all
load result_PCM_E4_W0.mat
fosize = 14;
titles = {'U1','U2','U3','U4','U5','U6','U7'};
% 绘制子图
figure;
for i = 1:7
    subplot(2,4,i); % 2行4列布局（最后一个空着）
    plot(sample_sizes, PCM_W0_matrix(:,i), 'LineWidth', 2);
    title(['' titles{i} '']);
    xlabel('Sample Size');
    ylabel('PCM');
    grid on;
    set(gca, 'GridLineStyle', '--')
    
    % 设置x轴刻度
    xticks([0 1000]);
    
    set(gca, 'fontsize', fosize, 'fontname', 'Times New Roman');
    ylim([-0.1,1])
end

set(gcf, 'unit', 'centimeters', 'position', [0 0 20 9]);
