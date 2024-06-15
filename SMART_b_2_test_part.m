% Step 1: Set number of criteria, alternatives, and experts
criterias = 4;
alternatives = 4;
experts = 15;

%------------------------------------------------------------

% Step 2: Set the values of the criteria according to the experts
weights = zeros(criterias, experts);
for i = 1:experts
    for j = 1:criterias
        % Simulate some missing values (let's assume 10% missing)
        if rand() < 0.1
            weights(j, i) = NaN;  % Missing value
        else
            % Put random values to the criteria to simulate the experts
            weights(j, i) = randi([10, 100]);
        end
    end
end

%-------------------------------------------------------------

% Step 3: Handle missing values (replace NaNs with the mean of the non-NaN values)
for j = 1:criterias
    for i = 1:experts
        if isnan(weights(j, i))
            % Use the mean of non-NaN values for the criterion
            valid_weights = weights(j, ~isnan(weights(j, :)));
            if ~isempty(valid_weights)
                weights(j, i) = mean(valid_weights);
            else
                weights(j, i) = 1; % Default value if no valid weights are available
            end
        end
    end
end

% Normalize the weights after handling missing values
normalized_weights = zeros(criterias, experts);
for i = 1:experts
    total_weight = sum(weights(:, i));
    for j = 1:criterias
        normalized_weights(j, i) = weights(j, i) / total_weight;
    end
end

%---------------------------------------------------------------

% Step 4: Set the performance of the alternatives per criteria per expert
performances = zeros(criterias, alternatives, experts);
for i = 1:experts
    for j = 1:alternatives
        for k = 1:criterias
            performances(k, j, i) = randi([10, 100]);
        end
    end
end

%-----------------------------------------------------------------

% Step 5: Calculate the utility value of the alternatives
util_value = zeros(alternatives, 1);
mean_weights = zeros(criterias, 1);
mean_performances = zeros(criterias, 1);

for i = 1:criterias
    mean_weights(i) = mean(normalized_weights(i, :));
end

for i = 1:alternatives
    for j = 1:criterias
        mean_performances(j) = mean(performances(j, i, :));
    end
    util_value(i) = sum(mean_weights .* mean_performances);
end

%------------------------------------------------------------------

% Step 6: Sort the alternatives
[sorted_util_value, sorted_indices] = sort(util_value, 'descend');

% Display the sorted utility values and corresponding alternatives
disp('Sorted Utility Values and Corresponding Alternatives:');
for i = 1:alternatives
    fprintf('Alternative %d: Utility Value = %.2f\n', sorted_indices(i), sorted_util_value(i));
end
