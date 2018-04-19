# Aggregate the results and generate a plot
#
# Authors: Roel Brouwer, Kees van Eijden, Jonathan de Bruin
#
# Dependencies: sklearn, numpy
# License: BSD-3-Clause

# pylint: disable=C0321

import os
import re
import glob
import warnings

from sklearn import metrics
import numpy as np

warnings.filterwarnings("ignore")

# Load the digits dataset to get the target
data_test_path = os.path.join('data', 'digits_testset.csv')
data_test = np.loadtxt(data_test_path, delimiter=',')
data_test_target = data_test[:, -1].astype(np.int)

# store the result
result = []

# save the result to a file
for fp in glob.glob(os.path.join('output', 'digits_svm*_C_*_gamma_*.txt')):

    # load the predicition result into memory
    prediction = np.loadtxt(fp)
    regexp = re.search('.*digits_svm.*\_C\_(.*)\_gamma\_(.*)\.txt', fp)
    c = regexp.group(1)
    gamma = regexp.group(2)
    f1score = metrics.f1_score(data_test_target, prediction, average='macro')

    result.append({'f1': f1score, 'cost': c, 'gamma': gamma})

optimal = max(result, key=lambda x: x['f1'])
print("Grid length:", len(result))
print("Optimal settings:", optimal)

# make a plot
import pandas as pd
import seaborn as sns

df_result = pd.DataFrame(result)
df_result = df_result.pivot(index='cost', columns='gamma', values='f1')
sns_fig = sns.heatmap(df_result)
figure = sns_fig.get_figure()
figure.savefig(os.path.join("output", "digits_f1_plot.pdf"))
