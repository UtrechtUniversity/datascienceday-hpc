# Introduction to High Performance Computing
Instructions for Mac users, Workshop Data Science Day 2018.

## Step 1: Install Cyberduck
If Cyberduck is not yet installed on your local system, complete the following steps:
1.	Open https://cyberduck.io in your browser;
2.	Click “Download Cyberduck for Mac”. Make sure to download Cyberduck and not Mountain Duck Home;
3.	Open the downloaded file;
4.	Follow the steps in the installer to complete the installation.

## Step 2: Establish connection with Cartesius
In fact, we will establish two connections with Cartesius. One SSH connection with Terminal and one SFTP connection with Cyberduck

### 2.1 Terminal
1.	Open the application Terminal. You will find it in Applications/Utilities.
2.	At the commandline prompt enter: `ssh ws_hpc01@cartesius.surfsara.nl` (replace ‘01’ with your own number). 
3.	You will be asked to enter your password. Enter `DaSciDa#01` (replace ‘01’ with your own number);
4.	You will see the commandline prompt of Cartesius. That is the place where you will give instructions to Cartesius (the Dutch national supercomputer for Scientific Research). 

### 2.2 Cyberduck
With Cyberduck installed, we will now establish a connection with Cartesius for file transfer:
1.	Open Cyberduck;
2.	Click the "Open Connection" button in the top left corner to start a new session;
3.	Select “SFTP (SSH File Transfer Protocol”, and enter the following information:
a.	*Server*: `cartesius.surfsara.nl`
b.	*Username*: `ws_hpc01` (replace ‘01’ with your own number and make sure to check the box in front)
c.	*Password*: `DaSciDa#01` (replace ‘01’ with your own number);
4. Uncheck/check “Add Keychain” as to your private policy, leave all other fields unchanged and click “Connect”.
5.	A new session will start, and Cyberduck will display your home directory on Cartesius. You should see one directory named “R”. 
 
## Step 3: Download workshop files
Next, we will download the files that we will be using for this workshop from our GitHub repository to your local system:
1.	Open https://github.com/UtrechtUniversity/datascienceday-hpc in your browser;
2.	Click the “Clone or download” button on the right and then click “Download ZIP”;
3.	Open the file location of the zip-file and unzip the file to a convenient location;
4.	Make sure to remember where you put the files.

## Step 4: Upload files to Cartesius
As our goal is to run the scripts on a supercomputer, we will now upload the files to Cartesius:
1.	Open the Cyberduck window;
2.	Create a new folder by right-clicking in the file browser and selecting “New folder”. Call it “workshop”;
3.	Double-click to navigate to the folder;
4.	Open your local folder with the workshop files and select all files in the folder;
5.	Drag the files to the file browser within the Cyberduck window. The files will now be uploaded to Cartesius. You will be prompted for your password! 

## Step 5: Create job submission scripts
Among the files we just uploaded is a script that creates our submission files for us. We will run it now:
 
#### R
1.	In the Terminal window, type at the prompt: `cd workshop`;
2.	Run the following command: `Rscript ./R/batch_script_generation.R -n 1`;
3.	If you refresh your file browser you will see a directory “batch_files” has appeared. Our submission script is in this directory.
#### Python
1.	In the Terminal window, type: `cd workshop`;
2.	Run the following command: `python ./python/batch_script_generation.py -n 1`;
3.	If you refresh your file browser you will see a directory “batch_files” has appeared. Our submission script is in this directory. 

## Step 6: Submit job to the scheduler 
The script we just created contains all information on the job that we want to submit. All that remains is to submit it to the scheduler:
1.	Run the following command: `sbatch ./batch_files/batch-0.sh`;
2.	You can check if your job was submitted you can type: `squeue -u ws_hpc01` (replace ‘01’ with your own number). The u-argument ensures you will only see your own jobs. If you just type `squeue`, the queue for the entire system will be shown.
If your job does not show up, it might be that it is already complete. You can check this by looking for its output (next step).

## Step 7: Run aggregation script 
The scheduler ensures the job is executed on one of the available nodes. It will complete within ~3 minutes. Afterwards, we will look for the output of our job, and aggregate the results to get a good overview:
 
#### R
1.	Refresh your file browser. A folder named “output” has appeared. The results of each individual simulation are stored here;
2.	Run the aggregation script: `Rscript ./R/aggregation.R`;
3.	The results of the simulations will be shown. Additionally, an image will be created in the “output” directory.

#### Python
1.	Refresh your file browser. A folder named “output” has appeared. The results of each individual simulation are stored here;
2.	Run the aggregation script: `python ./python/aggregation.py`;
3.	The results of the simulations will be shown. Additionally, an image will be created in the “output” directory.
 
## Step 8: Download and view results
Finally, we will download (part of) the results to our local system:
1.	Open the Cyberduck window;
2.	Navigate to the “output” folder. Locate the generated image file (“digits-f1-plot.pdf”) and select it;
3.	Open your local folder with the workshop files and drag the image file to it. The image will now be downloaded;
4.	Open the image file on your local system.

## Step 9: Repeat
Now, we will repeat step 5-8, but we will split the work over two jobs (and two nodes). 
1.	While in your “workshop” directory remove the output files by entering `rm -r output` at the prompt in Terminal
2.	Follow the instructions in step 5-8 again, but change the `-n` parameter from `-n 1` to `-n 2` in 5.2, and run the command in 6.1 twice, once for `./batch_files/batch-0.sh` and again for `./batch_files/batch-1.sh`.
