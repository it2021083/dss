% Number of criteria, alternatives, and experts
criterias = 4;
alternatives = 4;
experts = 15;

% Number of Monte Carlo simulations
N = 10000;

% Perturbation strengths
s_values = 0.2:0.1:0.6;

% Generate random weights for criteria (normalized)
weights = zeros(criterias, experts);
for i = 1:experts
    weights(:, i) = rand(criterias, 1);
end

% Normalize weights to sum to 1 for each expert
normalized_weights = zeros(criterias, experts);
for i = 1:experts
    total_weight = sum(weights(:, i));
    normalized_weights(:, i) = weights(:, i) / total_weight;
end

% Generate random performances for alternatives (each expert rates each alternative on each criterion)
performances = zeros(criterias, alternatives, experts);
for i = 1:experts
    for j = 1:alternatives
        performances(:, j, i) = rand(criterias, 1) * 100;
    end
end

% Initial utility value calculation (before perturbations)
initial_util_value = zeros(alternatives, 1);
mean_weights = mean(normalized_weights, 2);

for i = 1:alternatives
    mean_performance = mean(performances(:, i, :), 3);
    initial_util_value(i) = sum(mean_weights .* mean_performance);
end

% Sort initial utilities to determine initial ranking
[initial_sorted_util_value, initial_sorted_indices] = sort(initial_util_value, 'descend');

% Preallocate array for storing PRR values
PRR = zeros(length(s_values), alternatives);

% Preallocate arrays for total perturbations and rank reversals
total_perturbations = N * length(s_values);
rank_reversals = zeros(alternatives, 1);

% Monte Carlo simulation for sensitivity analysis
for idx = 1:length(s_values)
    s = s_values(idx);
    reversals_count = zeros(alternatives, 1);  % Track reversals for this perturbation strength

    for n = 1:N
        % Perturb the weights
        perturbed_weights = normalized_weights + s * randn(size(normalized_weights));

        % Ensure no negative weights and re-normalize
        perturbed_weights(perturbed_weights < 0) = 0;
        for i = 1:experts
            perturbed_weights(:, i) = perturbed_weights(:, i) / sum(perturbed_weights(:, i));
        end

        % Calculate utility values with perturbed weights
        perturbed_util_value = zeros(alternatives, 1);
        mean_perturbed_weights = mean(perturbed_weights, 2);

        for i = 1:alternatives
            mean_performance = mean(performances(:, i, :), 3);
            perturbed_util_value(i) = sum(mean_perturbed_weights .* mean_performance);
        end

        % Determine new ranking
        [perturbed_sorted_util_value, perturbed_sorted_indices] = sort(perturbed_util_value, 'descend');

        % Count rank reversals compared to initial ranking
        for i = 1:alternatives
            if perturbed_sorted_indices(i) ~= initial_sorted_indices(i)
                reversals_count(initial_sorted_indices(i)) += 1;
            end
        end
    end

    % Calculate PRR for this perturbation strength
    PRR(idx, :) = reversals_count / N;

    % Update total rank reversals
    rank_reversals += reversals_count;
end

% Calculate the probability of rank reversal for each perturbation strength
PRR_percentage = (PRR * 100);

% Display PRR percentages
disp('PRR (%) for each alternative and perturbation strength:');
disp(PRR_percentage);

% Display total rank reversals
disp('Total rank reversals for each alternative:');
disp(rank_reversals);

% Display total perturbations
disp('Total number of perturbations:');
disp(total_perturbations);

% Plotting the PRR as a function of perturbation strength
figure;
hold on;
colors = {'r', 'g', 'b', 'k'};  % Different colors for each alternative
markers = {'o', 's', 'd', '^'}; % Different markers for each alternative
for i = 1:alternatives
    plot(s_values, PRR(:, i), '-o', 'Color', colors{i}, 'Marker', markers{i}, 'LineWidth', 1.5, ...
         'MarkerSize', 6, 'DisplayName', sprintf('Alternative %d', i));
end
xlabel('Perturbation Strength (s)');
ylabel('Probability of Rank Reversal (PRR)');
title('Sensitivity Analysis using Monte Carlo Simulation');
legend('Location', 'Best');
xlim([min(s_values)-0.1, max(s_values)+0.1]);  % Adjust x-axis limits slightly
ylim([0, 1]);  % Ensure y-axis goes from 0 to 1 (probability range)
grid on;
hold off;

% Display PRR values for debugging
disp('PRR values for each alternative and perturbation strength:');
disp(PRR);

