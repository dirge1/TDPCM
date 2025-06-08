function [Y_estimate2,Y2,R2]=CCM(UV,origin_v,target_v,matrix_tau,matrix_E,data)
    if UV<=0
        data_delay_1=data(1-UV:end,:);
        N = size(data_delay_1,1);
        num_matrix = zeros(N - (matrix_E - 1) * matrix_tau, matrix_E);
        for i = 1:size(num_matrix, 1)
            for j = 1:matrix_E
                num_matrix(i, j) = i + (j - 1) * matrix_tau;
            end
        end
        num_matrix=num_matrix-UV;
        
        for r1=1:length(matrix_tau)
            for r2=1:length(matrix_E)
                Y_estimate2=[];
                Y2=[];
                for p=origin_v
                    
                    variable = data_delay_1(:, p);
                    
                    % 设置嵌入维数和时间延迟
                    embedding_dim =matrix_E(r2);
                    
                    % 计算时间序列长度
                    
                    tau = 1;
                    reconstructed_space = zeros(N - (embedding_dim - 1) * tau, embedding_dim);
                    % 给定时间延迟和最大嵌入维数，给出重构向量
                    for i = 1:embedding_dim
                        reconstructed_space(:, i) = variable((1:N - (embedding_dim - 1) * tau) + (i - 1) * tau);
                    end
                    
                    for q=target_v
                        variable2 = data_delay_1(:, q);
                        for o=1:size(reconstructed_space,1)
                            Distance = pdist2(reconstructed_space, reconstructed_space(o,:), 'euclidean')+1e-20;
                            [~,D_sort] = sort(Distance(1:end));
                            index_nearest = D_sort(2:embedding_dim+2);
                            u = exp(-Distance(index_nearest)/Distance(index_nearest(1)));
                            w = u/sum(u);
                            %临近点的最后时刻+时间延迟U（UV<0）对应的数据
                            Nearest_neigobor_source = data(num_matrix(index_nearest,end)+UV, q);
                            weighted_neighbor_source = Nearest_neigobor_source.*w;
                            Y_estimate2(o,:) = sum(weighted_neighbor_source);
                            Y2(o,:) = data(num_matrix(o,end)+UV, q);
                            R2=corr(Y_estimate2,Y2)';
                        end
                    end
                end
            end
        end
    else
        N = size(data,1);
        num_matrix = zeros(N - (matrix_E - 1) * matrix_tau, matrix_E);
        for i = 1:size(num_matrix, 1)
            for j = 1:matrix_E
                num_matrix(i, j) = i + (j - 1) * matrix_tau;
            end
        end
        
        for r1=1:length(matrix_tau)
            for r2=1:length(matrix_E)
                Y_estimate2=[];
                Y2=[];
                for p=origin_v
                    
                    variable = data(:, p);
                    
                    % 设置嵌入维数和时间延迟
                    embedding_dim =matrix_E(r2);
                    
                    % 计算时间序列长度
                    
                    tau = 1;
                    reconstructed_space = zeros(N - (embedding_dim - 1) * tau, embedding_dim);
                    % 给定时间延迟和最大嵌入维数，给出重构向量
                    for i = 1:embedding_dim
                        reconstructed_space(:, i) = variable((1:N - (embedding_dim - 1) * tau) + (i - 1) * tau);
                    end
                    
                    for q=target_v
                        
                        variable2 = data(:, q);
                        
                        for o=1:size(reconstructed_space,1)-UV
                            Distance = pdist2(reconstructed_space, reconstructed_space(o,:), 'euclidean')+1e-20;
                            [~,D_sort] = sort(Distance(1:end-UV));
                            index_nearest = D_sort(2:embedding_dim+2);
                            u = exp(-Distance(index_nearest)/Distance(index_nearest(1)));
                            w = u/sum(u);
                            %临近点的最后时刻+时间延迟U（UV>0）对应的数据
                            Nearest_neigobor_source = data(num_matrix(index_nearest,end)+UV, q);
                            weighted_neighbor_source = Nearest_neigobor_source.*w;
                            Y_estimate2(o,:) = sum(weighted_neighbor_source);
                            Y2(o,:) = data(num_matrix(o,end)+UV, q);
                            R2=corr(Y_estimate2,Y2)';
                        end
                    end
                end
            end
        end
    end
end