% Step 1: Set number of criteria, alternatives, and experts
criterias = 4;        % Number of criteria
alternatives = 4;     % Number of alternatives
experts = 15;         % Number of experts

%------------------------------------------------------------

% Step 2: Set the values of the criteria according to the experts
weights = zeros(criterias, experts);   % Initialize the weights matrix
for i = 1:experts
    for j = 1:criterias
        % Simulate the experts' ratings by assigning random values to the criteria
        % Values range between 10 and 100
        weights(j, i) = randi([10, 100]);
    end
end

%-------------------------------------------------------------

% Step 3: Normalization of the weights
normalized_weights = zeros(criterias, experts);   % Initialize the normalized weights matrix
for i = 1:experts
    total_weight = sum(weights(:, i));   % Calculate the total weight for each expert
    for j = 1:criterias
        % Normalize each weight by dividing it by the total weight of the expert
        normalized_weights(j, i) = weights(j, i) / total_weight;
    end
end

%---------------------------------------------------------------

% Step 4: Set the performance of the alternatives per criteria per expert
performances = zeros(criterias, alternatives, experts);   % Initialize the performances matrix
for i = 1:experts
    for j = 1:alternatives
        for k = 1:criterias
            % Simulate the performance ratings by assigning random values
            % Values range between 10 and 100
            performances(k, j, i) = randi([10, 100]);
        end
    end
end

%-----------------------------------------------------------------

% Step 5: Calculate the utility value of the alternatives
util_value = zeros(alternatives, 1);     % Initialize the utility values array
mean_weights = zeros(criterias, 1);      % Initialize the mean weights array
mean_performances = zeros(criterias, 1); % Initialize the mean performances array

% Calculate the mean weights for each criterion
for i = 1:criterias
    mean_weights(i) = mean(normalized_weights(i, :));
end

% Calculate the utility values for each alternative
for i = 1:alternatives
    for j = 1:criterias
        % Calculate the mean performance of each alternative for each criterion
        mean_performances(j) = mean(performances(j, i, :));
    end
    % Calculate the utility value of the alternative as the weighted sum of mean performances
    util_value(i) = sum(mean_weights .* mean_performances);
end

%------------------------------------------------------------------

% Step 6: Sort the alternatives
[sorted_util_value, sorted_indices] = sort(util_value, 'descend');   % Sort the utility values in descending order

% Display the sorted utility values and corresponding alternatives
disp('Sorted Utility Values and Corresponding Alternatives:');
for i = 1:alternatives
    fprintf('Alternative %d: Utility Value = %.2f\n', sorted_indices(i), sorted_util_value(i));
end
