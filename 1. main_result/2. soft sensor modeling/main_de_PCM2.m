clear; clc; close all;
rng(1107)
load('debutanizer_dataset.mat');
load ('result_de_PCM_E4.mat','matrix_causal_delay_partial')

% range of threshold
I=linspace(0,max(max(matrix_causal_delay_partial)),100);
I=[I max(matrix_causal_delay_partial)];
% optimal_delay=[8 45 9 46 9 10 83]; % E2
% optimal_delay=[6 33 9 25 8 17 10]; % E3
optimal_delay=[9 29 11 26 10 9 7]; % E4
% optimal_delay=[5 26 6 23 7 10 9]; % E5
% optimal_delay=[4 40 8 23 6 24 94]; % E6

% optimal_delay=[52 29 8 20 5 8 6]; % tao2
% optimal_delay=[82 36 3 58 5 100 100]; % tao3
% optimal_delay=[84 36 1 58 2 100 100]; % tao4
% maximum time delay
DD=100;

size_data=size(data,1);

%     q
max_delay=DD+1;
train_length=1350;
val_length=146;
test_length=size_data-train_length-val_length-DD;


train_indices = 1:train_length;
val_indices = (train_length+1):(train_length+val_length);
test_indices = (train_length+val_length+1):(size_data-DD);

for wq=1:length(I)
    wq
    
    % number of variable
    
    % initial time delay
    delay_range=DD*ones(1,7);
    
    for i = 1
        for j = 1:size(matrix_causal_delay_partial,2)
            W = matrix_causal_delay_partial(:,j);
            Intensity{j} = W(1:delay_range(j));
        end
    end
    
    index = cell(size(Intensity, 1), 1);
    
    for i = 1:length(Intensity)
    index{i} = find(Intensity{i} >= I(wq));
    index{i}(index{i} < optimal_delay(i)) = [];
    
    % 加入连续性筛选
    if ~isempty(index{i})
        diffs = diff(index{i});
        discontinuity = find(diffs ~= 1, 1); % 找到第一个不连续的位置
        if ~isempty(discontinuity)
            index{i} = index{i}(1:discontinuity); % 截断到第一个不连续点
        end
    end
end
    
    X=[];
    Y=[];
    o=1;
    for i=1:size(data,2)-1
        for j=1:length(index{i})
            X(:,o)=data(max_delay-index{i}(j):end-index{i}(j), i);
            o=o+1;
        end
    end
    Y = data(max_delay:end, 8);
    try
        % 根据随机索引划分数据
        X_train = X(train_indices, :);
        Y_train = Y(train_indices);
        
        X_val = X(val_indices, :);
        Y_val = Y(val_indices);
        
        numComponents = 3;
        [XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, numComponents);
        
        Y_pred = [ones(size(X_val, 1), 1) X_val] * beta;
        Y_pred=Y_pred';
        
        rmse(wq)  = sqrt(mean((Y_val' - Y_pred).^2));
        mae(wq) = mean(abs(Y_val' - Y_pred));
        r2(wq)  = 1 - sum((Y_val' - Y_pred).^2) / sum((Y_val' - mean(Y_val')).^2);
    catch
        mae(wq) =inf;
        r2(wq) =-inf;
        rmse(wq) =inf;
        
    end
end


[~,best_val]=min(rmse);
threshold=I(best_val);

for i = 1
    for j = 1:size(matrix_causal_delay_partial,2)
        W = matrix_causal_delay_partial(:,j);
        Intensity{j} = W(1:delay_range(j));
    end
end
index = cell(size(Intensity, 1), 1);

for i = 1:length(Intensity)
    index{i} = find(Intensity{i} >= I(best_val));
    index{i}(index{i} < optimal_delay(i)) = [];
    
    % 加入连续性筛选
    if ~isempty(index{i})
        diffs = diff(index{i});
        discontinuity = find(diffs ~= 1, 1); % 找到第一个不连续的位置
        if ~isempty(discontinuity)
            index{i} = index{i}(1:discontinuity); % 截断到第一个不连续点
        end
    end
end

X=[];
Y=[];
o=1;
for i=1:size(data,2)-1
    for j=1:length(index{i})
        X(:,o)=data(max_delay-index{i}(j):end-index{i}(j), i);
        o=o+1;
    end
end
Y = data(max_delay:end, 8);

X_train = X([train_indices], :);
Y_train = Y([train_indices]);

X_val = X(val_indices, :);
Y_val = Y(val_indices);

X_test = X(test_indices, :);
Y_test = Y(test_indices);

numComponents = 3;
[XL, YL, XS, YS, beta, PCTVAR, MSE, stats] = plsregress(X_train, Y_train, numComponents);

Y_pred = [ones(size(X_val, 1), 1) X_val] * beta;
Y_pred=Y_pred';
rmse_val  = sqrt(mean((Y_val' - Y_pred).^2));
mae_val = mean(abs(Y_val' - Y_pred));
r2_val = 1 - sum((Y_val' - Y_pred).^2) / sum((Y_val' - mean(Y_val')).^2);

Y_pred_test = [ones(size(X_test, 1), 1) X_test] * beta;
Y_pred_test=Y_pred_test';

rmse_test = sqrt(mean((Y_test' - Y_pred_test).^2));
mae_test = mean(abs(Y_test' - Y_pred_test));
r2_test = 1 - sum((Y_test' - Y_pred_test).^2) / sum((Y_test' - mean(Y_test')).^2);
save('result_model_de_PCM_E4.mat','index','matrix_causal_delay_partial','optimal_delay','threshold','Y_test','Y_pred_test')