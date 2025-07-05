%% ITERATION

for i = 1:60
    tasks.(['task' num2str(i)]) = Kisekinomock(1:end, i); % extract all answers
    
    tasks_data.(['task' num2str(i) '_data']) = string(tasks.(['task' num2str(i)]){:,1}); % table to string
    
    % replace empty data
    tasks_data.(['task' num2str(i) '_data'])(tasks_data.(['task' num2str(i) '_data']) == "undefined" | tasks_data.(['task' num2str(i) '_data']) == "" | ismissing(tasks_data.(['task' num2str(i) '_data']))) = "NoAnswer"; 
    
    % define correct answer
    tasks_correctAns.(['task' num2str(i) '_correctAns']) = string(RightAnswers{1, i});
    
    % total answers
    tasks_total_ans = length(tasks_data.(['task' num2str(1) '_data']));

    % quantity of correct answers
    tasks_corr_quantity.(['task' num2str(i) '_corr_quantity']) = sum(tasks_data.(['task' num2str(i) '_data']) == tasks_correctAns.(['task' num2str(i) '_correctAns']));

    % percentage of correct answers
    tasks_corr_perc.(['task' num2str(i) '_corr_perc']) = tasks_corr_quantity.(['task' num2str(i) '_corr_quantity']) / tasks_total_ans;

    % find unique categories
    tasks_uniqueValues.(['task' num2str(i) '_uniqueValues']) = unique(tasks_data.(['task' num2str(i) '_data']));
    
    numeric_array = zeros(size(tasks_data.(['task' num2str(i) '_data'])));
    unique_vals = tasks_uniqueValues.(['task' num2str(i) '_uniqueValues']);
    
    % assign each unique value to a unique number
    for k = 1:length(unique_vals)
        numeric_array(strcmp(tasks_data.(['task' num2str(i) '_data']), unique_vals{k})) = k;
    end

    tasks_numericData.(['task' num2str(i) '_numericData']) = numeric_array;
    
    % calculate standard deviation
    tasks_std_value.(['task' num2str(i) '_std_value']) = std(tasks_numericData.(['task' num2str(i) '_numericData']));

    % guess penalty (rn 1/6) ((need to be developed)
    tasks_guess_penalty.(['task' num2str(i) '_guess_penalty']) = 1/6;    
end

for i = 1:30
    w_MATH.(['w_MATH_' num2str(i)]) = (1-tasks_corr_perc.(['task' num2str(i) '_corr_perc'])) * tasks_std_value.(['task' num2str(i) '_std_value']) * (1-tasks_guess_penalty.(['task' num2str(i) '_guess_penalty']));
    w_CRIT.(['w_CRIT_' num2str(i)]) = (1-tasks_corr_perc.(['task' num2str(i+30) '_corr_perc'])) * tasks_std_value.(['task' num2str(i+30) '_std_value']) * (1-tasks_guess_penalty.(['task' num2str(i+30) '_guess_penalty']));
end

w_total_MATH = sum(struct2array(w_MATH));
w_total_CRIT = sum(struct2array(w_CRIT));

for i = 1:30
    score_MATH.(['MATH_b_' num2str(i)]) = 120 * (w_MATH.(['w_MATH_' num2str(i)]) / w_total_MATH);
    score_CRIT.(['CRIT_b_' num2str(i)]) = 120 * (w_CRIT.(['w_CRIT_' num2str(i)]) / w_total_CRIT);
end

values_MATH = zeros(1,30);
values_CRIT = zeros(1,30);

for k = 1:30
    values_MATH(k) = score_MATH.(['MATH_b_' num2str(k)]);
    values_CRIT(k) = score_CRIT.(['CRIT_b_' num2str(k)]);
end

low_MATH = 0;
high_MATH = 1;
low_CRIT = 0;
high_CRIT = 1;
tolerance = 1e-4; % acceptable precision

while (high_MATH - low_MATH) > tolerance
    mid_MATH = (low_MATH + high_MATH) / 2;
    total_MATH = 0;
    
    for i = 1:30
        value = values_MATH(i);
        value = max(1, min(7, value)); 

        decimal_part = value - floor(value);
        if decimal_part >= mid_MATH
            value = ceil(value);
        else
            value = floor(value);
        end
        
        total_MATH = total_MATH + value;

        zzzMATH.(['MATH_b_' num2str(i)]) = value;
    end

    if total_MATH > 120
        low_MATH = mid_MATH;
    else
        high_MATH = mid_MATH;
    end
end

while (high_CRIT - low_CRIT) > tolerance
    mid_CRIT = (low_CRIT + high_CRIT) / 2;
    total_CRIT = 0;
    
    for i = 1:30
        value = values_CRIT(i);
        value = max(1, min(7, value));

        decimal_part = value - floor(value);
        if decimal_part >= mid_CRIT
            value = ceil(value);
        else
            value = floor(value);
        end
        
        total_CRIT = total_CRIT + value;

        zzzCRIT.(['CRIT_b_' num2str(i)]) = value;
    end

    if total_CRIT > 120
        low_CRIT = mid_CRIT;
    else
        high_CRIT = mid_CRIT;
    end
end



Total = total_CRIT + total_MATH;
disp(['Total math = ', num2str(total_MATH)]);
disp(['Total crit = ', num2str(total_CRIT)]);
disp(['Total = ', num2str(Total)]);

%% PLOTTING

MATH_vector = zeros(1,30);
CRIT_vector = zeros(1,30);
for i = 1:30    
    MATH_vector(i) = zzzMATH.(['MATH_b_' num2str(i)]);
    CRIT_vector(i) = zzzCRIT.(['CRIT_b_' num2str(i)]);
end

for i = 1:tasks_total_ans
    for j = 1:30
        student_mathscore.(['student' num2str(i)]) = double(table2array(RightAnswers(1, 1:30)) == table2array(Kisekinomock(i, 1:30))) * MATH_vector';
        student_critscore.(['student' num2str(i)]) = double(table2array(RightAnswers(1, 31:60)) == table2array(Kisekinomock(i, 31:60))) * CRIT_vector';
    end
end

CRIT_plotvector = zeros(1, tasks_total_ans);
MATH_plotvector = zeros(1, tasks_total_ans);
for i = 1:tasks_total_ans
    MATH_plotvector(i) = student_mathscore.(['student' num2str(i)]);
    CRIT_plotvector(i) = student_critscore.(['student' num2str(i)]);
end

Total_plotvector = MATH_plotvector + CRIT_plotvector;

%%
% MATH PLOT
figure;
math_plot = histogram(MATH_plotvector, 'BinWidth', 10);
hold on;

% get bin info
edges = math_plot.BinEdges;
counts = math_plot.Values;
delete(math_plot);  % Remove original histogram

% plot bins manually with custom color based on edge
for i = 1:length(counts)
    x = edges(i);
    w = edges(i+1) - edges(i);
    y = counts(i);
    
    % color based on bin position
    if x >= 50
        color = [0.4118, 0.4118, 0.4118];  % dark gray for bins >= 50
    else
        color = [0.6, 0.6, 0.6];  % gray for bins < 50
    end
    
    % draw rectangle (bar)
    rectangle('Position', [x, 0, w, y], ...
              'FaceColor', color, ...
              'EdgeColor', 'k');
end

% restore axis settings
xlim([edges(1), edges(end)]);
ylim([0, max(counts)*1.1]);
set(gca, 'YTickLabel', []);
title('MATH SCORES');


% CRIT PLOT
figure;
crit_plot = histogram(CRIT_plotvector, 'BinWidth', 10);
hold on;

% get bin info
edges = crit_plot.BinEdges;
counts = crit_plot.Values;
delete(crit_plot);  % remove original histogram

% plot bins manually with custom color based on edge
for i = 1:length(counts)
    x = edges(i);
    w = edges(i+1) - edges(i);
    y = counts(i);
    
    % color based on bin position
    if x >= 50
        color = [0.4118, 0.4118, 0.4118];  % dark gray for bins >= 50
    else
        color = [0.6, 0.6, 0.6];  % gray for bins < 50
    end
    
    % draw rectangle (bar)
    rectangle('Position', [x, 0, w, y], ...
              'FaceColor', color, ...
              'EdgeColor', 'k');
end

% restore axis settings
xlim([edges(1), edges(end)]);
ylim([0, max(counts)*1.1]);
set(gca, 'YTickLabel', []);
title('CRIT SCORES');


% TOTAL PLOT
figure;
total_plot = histogram(Total_plotvector, 'BinWidth', 20);
hold on;

% get bin info
edges = total_plot.BinEdges;
counts = total_plot.Values;
delete(total_plot);  % remove original histogram

% plot bins manually with custom color based on edge
for i = 1:length(counts)
    x = edges(i);
    w = edges(i+1) - edges(i);
    y = counts(i);
    
    % color based on bin position
    if x >= 120
        color = [0.4118, 0.4118, 0.4118];  % dark gray for bins >= 120
    else
        color = [0.6, 0.6, 0.6];  % gray for bins < 120
    end
    
    % draw rectangle (bar)
    rectangle('Position', [x, 0, w, y], ...
              'FaceColor', color, ...
              'EdgeColor', 'k');
end

% restore axis settings
xlim([edges(1), edges(end)]);
ylim([0, max(counts)*1.1]);
set(gca, 'YTickLabel', []);
title('TOTAL SCORES');

%% HEATMAP
vals = struct2array(tasks_corr_perc);
matrix_MATH = reshape(vals(1:30), [], 6)';   % 6 rows, then transpose to 6×5
matrix_CRIT = reshape(vals(31:60), [], 6)';

% math heatmap
figure;
imagesc(matrix_MATH);
colormap('sky');  % or any colormap you like
colorbar;
counter = 1;
for row = 1:size(matrix_MATH, 1)
    for col = 1:size(matrix_MATH, 2)
        qlabel = ['Q' num2str(counter)];
        text(col, row, qlabel, ...
            'HorizontalAlignment', 'center', ...
            'Color', 'black', ...
            'FontWeight', 'bold');
        counter = counter + 1;
    end
end
title('Mathematics Questions')
xticks([]);
yticks([]);

% crit heatmap
figure;
imagesc(matrix_CRIT);
colormap('sky');  % or any colormap you like
colorbar;
counter = 1;
for row = 1:size(matrix_CRIT, 1)
    for col = 1:size(matrix_CRIT, 2)
        qlabel = ['Q' num2str(counter)];
        text(col, row, qlabel, ...
            'HorizontalAlignment', 'center', ...
            'Color', 'black', ...
            'FontWeight', 'bold');
        counter = counter + 1;
    end
end
title('Critical Thinking Questions')
xticks([]);
yticks([]);
%% CHECK
clamped = min(7, max(1, values_MATH));
min_sum = sum(floor(clamped));
max_sum = sum(ceil(clamped));

disp(['Min possible math total: ', num2str(min_sum)]);
disp(['Max possible math total: ', num2str(max_sum)]);

clamped = min(7, max(1, values_CRIT)); 
min_sum = sum(floor(clamped));
max_sum = sum(ceil(clamped));

disp(['Min possible crit total: ', num2str(min_sum)]);
disp(['Max possible crit total: ', num2str(max_sum)]);