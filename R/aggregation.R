# Aggregate the results and generate a plot
#
# Authors: Roel Brouwer, Kees van Eijden, Jonathan de Bruin
#
# Dependencies: sklearn, numpy
# License: BSD-3-Clause
#

library("ggplot2")
library("scales")
library("getopt")
library("caret")

# Load the digits dataset to get the target
data_test_path <- file.path("data", "digits_testset.csv")
data_test <- read.csv(data_test_path, header = FALSE)
target <- as.factor(data_test[,ncol(data_test)])

# make list of all the output files of each task
data_file_pattern <- sprintf("^digits_svm.*\\.txt$")
data_files <- list.files(path = "output",
                         pattern = data_file_pattern,
                         full.names = TRUE)
if (length(data_files) == 0) {
  cat("No data files found!\n\n")
  q(save = "no", status = -1)
}

n_predictions <- length(data_files)

model_score <- data.frame(
    cost =  rep(0, n_predictions),
    #data frame to store f1 value of every parameter setting
    gamma = rep(0, n_predictions),
    f1 =    rep(0, n_predictions)
  )

# compute the F score for each simulation
for (i in 1:n_predictions) {
  prediction <- read.csv(data_files[i], header = FALSE, stringsAsFactors = FALSE)
  cost <- prediction[1, 1]
  gamma <- prediction[1, 2]
  n_digits <- ncol(prediction) - 2  # first two columns contain the parameters 'cost' and 'gamma'
  prediction <- as.integer(prediction[1, 3:(n_digits + 2)])
  # to force all levels to occur in factor
  prediction <- factor(prediction,
    levels = c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  )
  
  cm <- confusionMatrix(prediction, target)
  precision <- diag(cm$table) / rowSums(cm$table)
  recall <- diag(cm$table) / colSums(cm$table)
  f1_score <- 2 * precision * recall / (precision + recall)
  
  f1_score_all <- mean(f1_score, na.rm = TRUE)
  model_score[i,] <- c(cost, gamma, f1_score_all)
}

max_f1_score <- max(model_score$f1)

cat("Parameter settings with best f1 score:\n")
print(model_score[model_score$f1 == max_f1_score,])

# Grid plot of all parameter pairs. Color of indicates the F1 score for
# the parameter pair. Best f1 scores are labelled.
pdf(file.path("output", "digits_f1_plot.pdf"))
ggplot(data = model_score, mapping = aes(cost, gamma)) +
  scale_y_continuous(
    trans = 'log2',
    breaks = trans_breaks('log2', function(x)
      2 ^ x),
    labels = trans_format('log2', math_format(2 ^ .x))
  ) +
  scale_x_continuous(
    trans = 'log2',
    breaks = trans_breaks('log2', function(x)
      2 ^ x),
    labels = trans_format('log2', math_format(2 ^ .x))
  ) +
  scale_color_gradientn(colours = rainbow(2)) +
  geom_point(aes(colour = f1)) + geom_text(aes(label = ifelse(
    f1 == max_f1_score, sprintf("%1.4f", f1), ''
  )),
  size = 2,
  hjust = 0,
  vjust = 0)
dev.off()
