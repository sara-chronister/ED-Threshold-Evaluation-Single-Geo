# ED-Threshold-Evaluation-Single-Geo Instructions

This Rproj is set up to explaore MEM thresholds applied to ED respiratory visits for a single geography. Geography in this use case can be any combination of geographical units available in ESSENCE (e.g., facility, county, substate region, state, etc.) however, this script is only able to evaluate a single geography at a time. Another version to evaluate a geography, such a state, and subgeographies, such as substate regions, is in development. Please reach out to sara.chronister@doh.wa.gov to gain access to the development version. Please follow the instructions below, taking care at the steps requiring manual evaluation for the COVID thresholds.

## Step 1: Repo Access

1. Download the repo either using a GitHub close (Useful link for setting up here: https://rfortherestofus.com/2021/02/how-to-use-git-github-with-r) or the "Download Zip" option in the green "<> Code" tab.
2. In the folder where the files for the repo are saved, open the "Geo-Evaluation.Rproj" file, which should open in RStudio.
3. Within RStudio, open the "Run-Eval.R" script.

## Step 2: Script Setup

1. In line 4 of the "Run-Eval.R" script, enter the ESSENCE syntax for the geography you wish to evaluate. I recommend setting up the geographies as you want them in ESSENCE then copying/pasting just the geography portion of the API syntax into the script.
2. In line 8 of the "Run-Eval.R" script, enter the name of the geography. You can use any description that makes sense for your use case. This will just add this name into some of the output tables.
3. Run everything in "Run-Eval.R" through line 34 - stop just before the `source("COVIDprep.R")` section in line 35.

## Step 3: COVID Prep

1. Open the "Scripts" folder and open the "COVIDprep.R" script.
2. Run lines 1-11 - the last step will save a CSV file of the COVID data since the beginning of 2020. You will need this for the next steps.
   - Please note that this file contains three columns: Year, Week, and Percent.
4. Navigate to https://github.com/lozalojo/memapp and scroll to the "Useful Links" section. Click on the link that says "memapp official server". This is a version of the Shiny app built by the package developers to explore MEM thresholds using an uploaded CSV file. If you have concerns about data privacy security, I recommend following the instructions in the "Installation" section of this page to run it from your local computer.
5. Once the Shiny app is open and loaded, click on the purple "i" logo on the right side and chek the boxes for both "Advanced features" and "Experimental features". These are what will allow multiple waves/season, which is needed for COVID.
6. Upload the saved CSV file to the Shiny app.
7. In the "Waves detection" dropdown, select "Multiple waves/series".
8. Set the First Week to sometimes between 30-4o and the Last Week to the week just before the First Week (e.g., 35 for First Week and 34 for Last Week). Feel free to test how the model changes depending on what week you choose as your start.
9. Click on the "Evolution" tab then on the "Detailed" tab that appears.
10. In the bottom row ("next" , take the values for "Epidemic thr.", "Medium thr.", "High thr.", and "Very high thr." and input them into their respective places in lines 14-18 of the "COVIDprep.R" script.
   - NOTE: you must enter the values as the raw/unadjusted value and not the adjusted/human readable value. For example, if the Shiny app shows 4.2% you must enter it as 0.042 in the R script.
12. Save the "COVIDprep.R" script and close it.

## Step 4: Generate Evaluation

1. Return to the "Run-Eval.R" script and run lines 35 through 40 - ensure that you are running the "COVIDprep.R" script at this time.
2. An html file with the name of the geogrpahy you entered will be generated and can be shared and opened in a browser.
3. Copies of the data used to generate the report are saved in the "Data" folder for further analysis/exploration as needed.


