% Monte Carlo Simulation for Sensitivity Analysis using SMART Method

% Step 1: Initialize parameters
criterias = 4;        % Number of criteria
alternatives = 4;     % Number of alternatives
experts = 15;         % Number of experts
N = 10000;            % Number of Monte Carlo simulations
s_values = 0.2:0.1:0.6;  % Different perturbation strengths
PRR = zeros(length(s_values), alternatives);  % Initialize PRR storage

% Initial weights and performances
weights = randi([10, 100], criterias, experts);  % Random weights
performances = randi([10, 100], criterias, alternatives, experts);  % Random performances

% Normalize weights
normalized_weights = weights ./ sum(weights, 1);  % Normalize along columns

% Calculate initial utility values
mean_weights = mean(normalized_weights, 2);  % Mean weights across experts
util_values = zeros(alternatives, 1);  % Initialize utility values

% Compute initial utility values
for i = 1:alternatives
    mean_performances = mean(performances(:, i, :), 3);  % Mean performance per criterion
    util_values(i) = sum(mean_weights .* mean_performances);  % Weighted sum
end

% Initial sorting of utility values
[sorted_initial_values, initial_ranks] = sort(util_values, 'descend');

% Monte Carlo Simulation
for s_index = 1:length(s_values)
    s = s_values(s_index);  % Current perturbation strength
    rank_reversals = zeros(alternatives, 1);  % Initialize rank reversals count

    for k = 1:N
        % Add perturbation to weights and performances
        perturbed_weights = normalized_weights + s * randn(size(normalized_weights));  % Add noise
        perturbed_weights = max(perturbed_weights, 0);  % Ensure non-negative weights
        perturbed_weights = perturbed_weights ./ sum(perturbed_weights, 1);  % Re-normalize

        perturbed_performances = performances + s * randn(size(performances));  % Add noise
        perturbed_performances = max(perturbed_performances, 0);  % Ensure non-negative performances

        % Recalculate utility values with perturbed data
        mean_weights_perturbed = mean(perturbed_weights, 2);  % Mean perturbed weights
        util_values_perturbed = zeros(alternatives, 1);  % Initialize perturbed utility values

        for i = 1:alternatives
            mean_performances_perturbed = mean(perturbed_performances(:, i, :), 3);  % Mean perturbed performance
            util_values_perturbed(i) = sum(mean_weights_perturbed .* mean_performances_perturbed);  % Weighted sum
        end

        % Sort perturbed utility values
        [~, perturbed_ranks] = sort(util_values_perturbed, 'descend');

        % Check for rank reversals
        for i = 1:alternatives
            if perturbed_ranks(i) ~= initial_ranks(i)
                rank_reversals(i) = rank_reversals(i) + 1;
            end
        end
    end

    % Calculate PRR
    PRR(s_index, :) = rank_reversals / N;  % Probability of Rank Reversal
end

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

