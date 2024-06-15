% Step 1 : Set number of criterias, alternatives and experts

criterias = 4;
alternatives = 4;
experts = 15;

%------------------------------------------------------------


% Step 2 : Set the values of the criterias according to the experts

weights = zeros(criterias, experts);
for (i = 1:experts)

    for(j = 1:criterias)

        %Put random values to the criteria to simulate the experts    
        weights(j,i) = randi([10,100]);

    end

end

%-------------------------------------------------------------


% Step 3 : Normalization of the weights

normalized_weights = zeros(criterias, experts);
for (i = 1:experts)

    all_weights = 0;

    for (j = 1:criterias)
    
        all_weights += weights(j,i);
        normalized_weights(j,i) = weights(j,i) / all_weights;
    
    end

end

%---------------------------------------------------------------


% Step 4 : Set the performance of the alternatives per criteria per expert

performances = zeros(criterias, alternatives, experts);
for (i = 1:experts)

    for (j = 1:alternatives)
    
        performances (j,j,i) = randi([10,100]); ;
    
    end

end

%-----------------------------------------------------------------


% Step 5 : Calculate the utility value of the alternatives

util_value = zeros(alternatives);
%mean_weights = zeros(criterias);
mean_performances = zeros(criterias);

for(i =1:alternatives)

    all_weights = 0;
    mean_performance = 0;
    all_performance = 0;

    for(j =1:criterias)
    
        for (n =1:experts)
        
            all_weights += normalized_weights(j,n);
            all_performances += performances(j,i,n);

        end

        mean_weights(j) = all_weights/experts;
        mean_performances(j) = all_performances/experts;

    end

    for (z = 1:criterias)
    
        util_value(i) += (mean_weights(j)*mean_performances(j));
    
    end

end

%------------------------------------------------------------------


% Step 6 : Sort the alternatives

[sorted_util_value, sorted_indices] = sort(util_value, 'descend');

% Display the sorted utility values and corresponding alternatives
disp('Sorted Utility Values and Corresponding Alternatives:');
for i = 1:alternatives
    fprintf('Alternative %d: Utility Value = %.2f\n', sorted_indices(i), sorted_util_value(i));
end








