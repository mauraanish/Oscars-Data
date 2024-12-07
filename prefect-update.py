# import necessary libraries
from prefect import task, flow
import os
import subprocess

# run the R file which scrapes the new ceremony's data
@task
def run_data_update():
    os.chdir(r"C:\Users\maura\Documents\DACSS\690\Final")
    subprocess.run(["Rscript", "Yearly-Update-Scraping.R"])

# run the task
@flow
def yearly_update_flow():
    run_data_update()

# execute flow once a year on March 31st at midnight
if __name__ == "__main__":
    yearly_update_flow.serve(name="Oscars Yearly Update", cron = "0 0 31 3 *")