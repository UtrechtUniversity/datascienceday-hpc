# Recognize written digits with Support Vector Machines
#
# Arguments:
#     -t: Task number
#     -C: Penalty parameter C of the error term.
#     -gamma: Kernel coefficient.
#
# Authors: Roel Brouwer, Kees van Eijden, Jonathan de Bruin
#
# Dependencies: sklearn, numpy
# License: BSD-3-Clause
#

library("getopt")
library("e1071")

#parsing the arguments to Rscript after program file: Rscript --[options] digits_svm.R [arguments]
opt <- getopt::getopt(
  matrix(
    c('task', 'T', 1, "numeric", # not essential
      'gamma', 'G', 1, "numeric",
      'cost', 'C', 1, "numeric"
    ), 
  byrow=TRUE, ncol=4
))

# default values for options not specified
if ( is.null(opt$gamma ) ) { opt$gamma = 0.01 }
if ( is.null(opt$cost ) ) { opt$cost  = 1.0 }
if ( is.null(opt$task ) ) { opt$task  = 1 }

# The digits dataset (train dataset)
train_set <- read.csv("data/digits_trainset.csv", header= FALSE)
train_images <- train_set[1:64]
train_targets <- as.factor(train_set[[65]])

# The digits dataset (test dataset)
test_set <- read.csv("data/digits_testset.csv", header= FALSE)
test_images <- test_set[1:64]
test_targets <- as.factor(test_set[[65]])

# Fit a Support Vector Classifier
model <- e1071::svm(train_images, train_targets, 
                    gamma = opt$gamma, cost = opt$cost, scale = FALSE)

# Predict the value of the digit on the test dataset
prediction <- predict(model, newdata = test_images)

# Accuracy measure to evaluate the result
agreement <- table(prediction == test_targets)
accuracy <- agreement[2]/(agreement[1]+agreement[2])
cat("Accuracy: ", accuracy, " with parameters C=", opt$cost, " and G=", opt$gamma, "\n")

# output parameters 'C' and 'gamma' and prediction of model to .csv file
output <- append(as.character(prediction), c(opt$cost, opt$gamma), after= 0)
output <- as.data.frame(t(output), optional=TRUE)

# write CSV file to output directory
if (!dir.exists("output")) { dir.create("output") }
output_file <- file.path(
  "output", 
  sprintf("digits_svm%d_C_%f_gamma_%f.txt", opt$task, opt$cost, opt$gamma))
write.csv(output, output_file, row.names= FALSE)

# Do 30 seconds of useless work to simulate a long process... 
b <- 0; runs <- 100
for (i in 1:100) { a <- rnorm(1000000); invisible(gc()); b <- sort(a, method="quick")}
remove("a", "b")

