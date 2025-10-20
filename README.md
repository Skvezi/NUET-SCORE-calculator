This code estimates score for each problem (multiple choice question) in the test based on test takers perfomance.

It receives excel table (preferrebly from Google Form, or it need to be adjust to Google Form format). You should select as a type "Table" only answers without any variable name column/row. (In code the table is caled Kisekinomock, you can replace it). Then, there should be row of all only answers, 1 row table, import it (rename to RightAnswers). That's it. Run code.
After some time you will recieve, the strings:
Total math = x
Total crit = y
Total = x+y
Min possible math total = m_1
Max possible math total = m_2
Min possible crit total = c_1
Max possible crit total = c_2

All these strings are indicate how "well" it assigned score to each task in order to sum up to 120 per section. If it does not sum up to 120, then it means that the program cannot round the score to the 120 (for example, it is rounding x.000001 to the x+1, and it is the limit for this rounding, but 120 cannot be achieved). In this case, you should manually change some score for the task.

Each score for task will be placed in structs named: zzzCRIT and zzzMATH (it is convinient to have them last in the workspace).

Also the figures will pop up.
![fig_mathscore](https://github.com/user-attachments/assets/ead887dc-3c6a-48fd-96b9-4634057b80ea)
![fig_critscore](https://github.com/user-attachments/assets/9f65d54f-a0b1-4f6f-9474-ef76f2189678)
![fig_totalscore](https://github.com/user-attachments/assets/c30e8e2a-e463-4ebc-b828-412d4184e7e1)

First three show the bar charts with required score in order to procede the next step of enrolling to university.

![fig_heatmapmath](https://github.com/user-attachments/assets/ba733104-72ad-4c50-b299-e5eb2739cad3)
![fig_heatmapcrit](https://github.com/user-attachments/assets/4f36b051-49bb-4166-8258-a6963225cca7)

The last two shows how students performed in each task by heatmap. The more it is blue, the more students answered correct.

