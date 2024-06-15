% Βήμα 1: Ορισμός κριτηρίων και εναλλακτικών

criteria_count = 4;
alternatives_count = 4;
experts_count = 15;

%-----------------------------------------------------
% Βήμα 2: Καταγραφή βαρών από ειδικούς

weights = randi([10, 100], experts_count, criteria_count); % Τυχαία βάρη για παράδειγμα
disp('Μη κανονικοποιημένα βάρη:');
%Tα εχω βαλει για να δεις οτι λειτουργει η σθναρτηση
weights(2,4)=NaN;
weights(3,4)=NaN;
disp(weights);
%συμπλήρωση στοιχειων με βαση το μεσο ορο
function [correct_weights] = fill_missing_values(weights)
    [r, c] = size(weights);

    % Έλεγχος για εντελώς κενές στήλες
    for j = 1:c
        if all(isnan(weights(:, j)))
            error(['Στήλη ', num2str(j), ' είναι κενή. Αναπλήρωση δεν είναι δυνατή.']);
        end
    end

    %Οι δείκτες non_nan_idx δημιουργούνται για να εντοπίσουν τις μη-NaN τιμές σε κάθε στήλη του πίνακα weights.

%----------------------------------------------------------
%Παρεμβολή:

%Χρησιμοποιώντας τη συνάρτηση interp1, γίνεται παρεμβολή
% για να υπολογιστούν οι τιμές για τις θέσεις των NaN. Η
%παρεμβολή γίνεται μεταξύ των υπάρχουσων μη-NaN τιμών
%Χρησιμοποιείται γραμμική παρεμβολή ('linear') με εξωπολυωνική παρεμβολή ('extrap') για τις τιμές εκτός του διαθέσιμου εύρους

    for j = 1:c
        % Αντικατάσταση τιμών μικρότερων από 10 με NaN για να συμπεριληφθούν στην παρεμβολή
        weights(weights(:, j) < 10, j) = NaN;

        % Δείκτες μη-NaN τιμών
        non_nan_idx = ~isnan(weights(:, j));

       % Έλεγχος αν υπάρχουν αρκετά μη-NaN στοιχεία για την παρεμβολή
        if sum(non_nan_idx) >= 2
        % Αντικατάσταση NaN τιμών με παρεμβολή
           weights(:, j) = interp1(find(non_nan_idx), weights(non_nan_idx, j), 1:r, 'linear', 'extrap');
         else
        % Εδώ μπορείτε να τοποθετήσετε μια εναλλακτική διαδικασία, όπως η αντικατάσταση των NaN τιμών με το μέσο όρο της στήλης
           disp('Μη επαρκής αριθμός μη-NaN τιμών για παρεμβολή στη στήλη');
         end
    end

    % Επιστροφή διορθωμένων βαρών
    correct_weights = weights;
    disp('Κανονικοποιημένα βάρη:');
    disp(correct_weights);
end

%----------------------------------------------------------
%για τισ επιδοσεις βαθμολογιες

function new_scores = fill_missing_performance(scores)
    [experts_count, criteria_count, alternatives_count] = size(scores);

    % Για κάθε κριτήριο
    for k = 1:criteria_count
        % Για κάθε εναλλακτική
        for l = 1:alternatives_count
            % Βρίσκουμε τα μη-NaN στοιχεία στον τρέχοντα συνδυασμό ειδικών/κριτηρίων/εναλλακτικών
            non_nan_idx = ~isnan(scores(:, k, l));

            % Υπολογίζουμε τον μέσο όρο των μη-NaN τιμών
            if any(non_nan_idx)
                mean_performance = mean(scores(non_nan_idx, k, l));
            else
                mean_performance = NaN;
            end

            % Αντικαθιστούμε τα NaN στοιχεία με γεωμετρική πρόοδο
            for i = 1:experts_count
                if isnan(scores(i, k, l))
                    % Υπολογίζουμε τη θέση του σημείου στη γεωμετρική πρόοδο
                    % Εδώ μπορείτε να προσαρμόσετε τον τύπο της γεωμετρικής προόδου ανάλογα με τις ανάγκες σας
                    geometric_progression_value = mean_performance * (i / experts_count);

                    % Αντικαθιστούμε το NaN στοιχείο με την τιμή της γεωμετρικής προόδου
                    scores(i, k, l) = geometric_progression_value;
                end
            end
        end
    end

    new_scores = scores;
end


%----------------------------------------------------------
%allo tropos gia symplhrvsh kenon stoixeion



%η συνάρτηση χρησιμοποιεί τη συνάρτηση randsample για να επιλέξει τυχαίες τιμές από τις υπάρχουσες τιμές
%και να αντικαταστήσει τις απουσιάζουσες τιμές με αυτές
%. Η επιλογή γίνεται με βάση την ίδια κατανομή με τις υπάρχουσες τιμές.





function filled_performance = fill_missing_performance_statistical2(performance)
    [experts_count, criteria_count, alternatives_count] = size(performance);

    % Επίπεδο επιβεβαίωσης (significance level) για τον προσδιορισμό της κατ,ανομής το αλλαζουμε αναλογως το ποσο αυστηρο θελουε να ειναι
    alpha = 0.15;

    % Για κάθε κριτήριο
    for k = 1:criteria_count
        % Για κάθε εναλλακτική
        for l = 1:alternatives_count
            % Επιλογή των υπάρχουσων τιμών στη συγκεκριμένη στήλη
            data = performance(:, k, l);

            % Αντικατάσταση των NaN τιμών με τυχαίες τιμές από την ίδια κατανομή
            nan_indices = isnan(data);
            nan_count = sum(nan_indices);
            existing_values = data(~isnan(data));
            filled_values = randsample(existing_values, nan_count, true);

            % Ενημέρωση των απουσιάζουσων τιμών με τις τυχαίες τιμές
            data(nan_indices) = filled_values;

            % Επανατοποθέτηση των δεδομένων στον αρχικό πίνακα επιδόσεων
            performance(:, k, l) = data;
        end
    end

    filled_performance = performance;
end


%----------------------------------------------------------
% Βήμα 3: Κανονικοποίηση βαρών

correct_weights= fill_missing_values(weights);
mean_weights = mean(correct_weights, 1); % Μέσος όρος κατά στήλη
normalized_weights = mean_weights / sum(mean_weights);
disp('Κανονικοποιημένα βάρη κριτηρίων:');
disp(normalized_weights);


%----------------------------------------------------------
% Βήμα 4: Αξιολόγηση εναλλακτικών από ειδους

scores = randi([10, 100], experts_count, criteria_count, alternatives_count); % Τυχαίες βαθμολογίες
scores(2,4,3)=NaN;
scores(2,4,4)=NaN;
scores(2,4,5)=NaN;
disp(scores);
new_scores= fill_missing_performance(scores);
disp('Βαθμολογίες:');
disp(new_scores);

% Υπολογισμός μέσων βαθμολογιών για κάθε εναλλακτική και κάθε κριτήριο
mean_scores = mean(new_scores, 1);
disp('Μέσες βαθμολογίες:');
disp(mean_scores);


%----------------------------------------------------------
% Βήμα 5: Υπολογισμός τιμών χρησιμότητας για κάθε εναλλακτική

utilities = zeros(1, alternatives_count);
for j = 1:alternatives_count
    for i = 1:criteria_count
        utilities(j) += normalized_weights(i) * mean_scores(1, i, j);
    end
end

disp('Τιμές χρησιμότητας για κάθε εναλλακτική:');
disp(utilities);

% Επιλογή της καλύτερης εναλλακτικής
max_utility = -1;
best_selection = 1;
for i = 1:alternatives_count
    if utilities(i) > max_utility
        max_utility = utilities(i);
        best_selection = i;
    end
end
disp('Καλύτερη επιλογή:');
disp(best_selection);
disp('Με τιμή χρησιμότητας:');
disp(max_utility);

