# Batch script generation
#
# Arguments:
#     -n: Number of batch files.
#
# Authors: Roel Brouwer, Kees van Eijden, Jonathan de Bruin
#
# Dependencies: sklearn, numpy
# License: BSD-3-Clause


#' Generic function to create batch files for HPC cluster.
#' 
#' @param arguments The hyperparameters
#' @param n_processes Number of processes/tasks per file/node
#' @param n_batch Number of the batch.
make_bash_file <- function (parameters, n_processes=24, n_batch=0) {

  # recusive if nrow(parameters > 24)
  if (nrow(parameters) > n_processes){
    make_bash_file(tail(parameters, nrow(parameters)-n_processes), 
                   n_processes=n_processes, 
                   n_batch=n_batch + 1)
  }
  parameters = head(parameters, n_processes)

  # write batch commands to file
  if (!dir.exists("batch_files")) dir.create("batch_files")
  batch_script <- file.path("batch_files",
                            sprintf("batch-%d.sh", n_batch))
  
  fbatch <- file(batch_script, open = "w")
  writeLines("#!/bin/bash", fbatch)
  writeLines("#SBATCH -t 00:05:00", fbatch)
  writeLines("#SBATCH -N 1", fbatch)
  writeLines("cd $HOME/workshop", fbatch)
  writeLines("module load eb", fbatch)
  writeLines("module load R", fbatch)
  writeLines("date", fbatch)
  
  for (i in 1:nrow(parameters)){

    i_job = i + n_batch * n_processes
  
    command <- sprintf("Rscript --vanilla R/digits_svm.R -T %d -C %f -G %f &", 
                       i_job, parameters[i, 'cost'],  parameters[i, 'gamma'])
    writeLines(command, fbatch)
  }

  writeLines("wait", fbatch)
  writeLines("date", fbatch)
  close(con= fbatch)
}


# hyperparameter: grid search
cost    <- c(2^-5, 2^-3, 2^-1, 2^1, 2^3, 2^5, 2^7, 2^9, 2^11, 2^13, 2^15)
gamma   <- c(2^-15, 2^-13, 2^-11, 2^-9, 2^-7, 2^-5, 2^-3, 2^-1, 2^1, 2^3 )
hyperparameters <- expand.grid(cost, gamma)
colnames(hyperparameters) <- c("cost", "gamma")

# parsing the arguments to Rscript after program file: Rscript --[options] progam.R [arguments]
opt <- getopt::getopt(
  matrix(
    c('n', 'n', 1, "numeric"), 
    byrow=TRUE, ncol=4)
)

# defaults for options not specified
if (is.null(opt$n)) { opt$n = 1 }

# the number of batch files to generate
n_processes <- ceiling(nrow(hyperparameters)/opt$n)

make_bash_file(hyperparameters, n_processes = n_processes)
