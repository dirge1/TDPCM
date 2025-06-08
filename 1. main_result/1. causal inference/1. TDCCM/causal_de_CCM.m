clear;clc;close all
load debutanizer_dataset.mat

data=data(1:1596,:);
%%
tic
P=100:-1:-100;
parfor oo=1:length(P)
    oo
    U=P(oo);
    
    %
    
    matrix_tau=1;
    matrix_E=4;
    
    if U>=0
        N = size(data,1);
        num_matrix = zeros(N - (matrix_E - 1) * matrix_tau, matrix_E);
        for i = 1:size(num_matrix, 1)
            for j = 1:matrix_E
                num_matrix(i, j) = i + (j - 1) * matrix_tau;
            end
        end
        
        for r1=1:length(matrix_tau)
            for r2=1:length(matrix_E)
                Y_estimate=[];
                Y=[];
                for p=1:size(data,2)
                    
                    variable = data(:, p);
                    
                    % ����Ƕ��ά����ʱ���ӳ�
                    embedding_dim =matrix_E(r2);
                    
                    % ����ʱ�����г���
                    
                    tau = 1;
                    reconstructed_space = zeros(N - (embedding_dim - 1) * tau, embedding_dim);
                    % ����ʱ���ӳٺ����Ƕ��ά���������ع�����
                    for i = 1:embedding_dim
                        reconstructed_space(:, i) = variable((1:N - (embedding_dim - 1) * tau) + (i - 1) * tau);
                    end
                    
                    for q=1:size(data,2)
                        
                        variable2 = data(:, q);
                        
                        for o=1:size(reconstructed_space,1)-U
                            Distance = pdist2(reconstructed_space, reconstructed_space(o,:), 'euclidean')+1e-20;
                            [~,D_sort] = sort(Distance(1:end-U));
                            index_nearest = D_sort(2:embedding_dim+2);
                            u = exp(-Distance(index_nearest)/Distance(index_nearest(1)));
                            w = u/sum(u);
                            %�ٽ�������ʱ��+ʱ���ӳ�U��U>0����Ӧ������
                            Nearest_neigobor_source = data(num_matrix(index_nearest,end)+U, q);
                            weighted_neighbor_source = Nearest_neigobor_source.*w;
                            Y_estimate{p,q}(o,:) = sum(weighted_neighbor_source);
                            Y{p,q}(o,:) = data(num_matrix(o,end)+U, q);
                        end
                    end
                end
                %
                % �ڶ��е�һ��ΪY�ع�X���Դ�����
                vec=[];
                vec_estimate=[];
                R=[];
                for ii=1:size(Y,1)
                    for j=1:size(Y,2)
                        vec=Y{ii,j}(:,end);
                        vec_estimate=Y_estimate{ii,j}(:,end);
                        
                        %             vec_estimate=vec_estimate(:);
                        R=corr(vec_estimate,vec)';
                        R_corr{oo}(ii,j)=R;  %Ԥ���i���������������������ϵ���泤�������ı仯
                        
                        
                    end
                end
            end
        end
    else
        data2=data(1-U:end,:);
        N = size(data2,1);
        num_matrix = zeros(N - (matrix_E - 1) * matrix_tau, matrix_E);
        for i = 1:size(num_matrix, 1)
            for j = 1:matrix_E
                num_matrix(i, j) = i + (j - 1) * matrix_tau;
            end
        end
        num_matrix=num_matrix-U;
        
        for r1=1:length(matrix_tau)
            for r2=1:length(matrix_E)
                Y_estimate=[];
                Y=[];
                for p=1:size(data,2)
                    
                    variable = data2(:, p);
                    
                    % ����Ƕ��ά����ʱ���ӳ�
                    embedding_dim =matrix_E(r2);
                    
                    % ����ʱ�����г���
                    
                    tau = 1;
                    reconstructed_space = zeros(N - (embedding_dim - 1) * tau, embedding_dim);
                    % ����ʱ���ӳٺ����Ƕ��ά���������ع�����
                    for i = 1:embedding_dim
                        reconstructed_space(:, i) = variable((1:N - (embedding_dim - 1) * tau) + (i - 1) * tau);
                    end
                    
                    for q=1:size(data,2) 
                        variable2 = data2(:, q);
                        for o=1:size(reconstructed_space,1)
                            Distance = pdist2(reconstructed_space, reconstructed_space(o,:), 'euclidean')+1e-20;
                            [~,D_sort] = sort(Distance(1:end));
                            index_nearest = D_sort(2:embedding_dim+2);
                            u = exp(-Distance(index_nearest)/Distance(index_nearest(1)));
                            w = u/sum(u);
                            %�ٽ�������ʱ��+ʱ���ӳ�U��U<0����Ӧ������
                            Nearest_neigobor_source = data(num_matrix(index_nearest,end)+U, q);
                            weighted_neighbor_source = Nearest_neigobor_source.*w;
                            Y_estimate{p,q}(o,:) = sum(weighted_neighbor_source);
                            Y{p,q}(o,:) = data(num_matrix(o,end)+U, q);
                        end
                    end
                end
                %
                % �ڶ��е�һ��ΪY�ع�X���Դ�����
                vec=[];
                vec_estimate=[];
                R=[];
                for ii=1:size(Y,1)
                    for j=1:size(Y,2)
                        vec=Y{ii,j}(:,end);
                        vec_estimate=Y_estimate{ii,j}(:,end);
                        
                        R=corr(vec_estimate,vec)';
                        R_corr{oo}(ii,j)=R;  %Ԥ���i���������������������ϵ���泤�������ı仯
                    end
                end
            end
        end
    end
end
%
for i=1:length(P)
    for j=1:size(data,2)
        for k=1:size(data,2)
            matrix_causal_delay{j}(i,k)=R_corr{i}(j,k);
        end
    end
end
for i=1:length(P)
    for j=1:size(data,2)
        for k=1:size(data,2)
            max_causal_delay(j,k)=max(matrix_causal_delay{j}(:,k));
        end
    end
end