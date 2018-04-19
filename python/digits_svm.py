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

# pylint: disable=C0321

import os
import argparse

from sklearn import svm, metrics
import numpy as np

# parse the arguments
parser = argparse.ArgumentParser(description='SVC options.')
parser.add_argument("-T", default=1, type=int, help='Task number.')
parser.add_argument("-C", default=1.0, type=float, help='Penalty parameter C of the error term.')
parser.add_argument("-G", default=0.001, type=float, help='Kernel coefficient.')
svc_args = parser.parse_args()
print(svc_args)

# The digits dataset (train dataset)
data_train_path = os.path.join('data', 'digits_trainset.csv')
data_train = np.loadtxt(data_train_path, delimiter=',')
data_train_images = data_train[:, :-1]
data_train_target = data_train[:, -1].astype(np.int)

# The digits dataset (test dataset)
data_test_path = os.path.join('data', 'digits_testset.csv')
data_test = np.loadtxt(data_test_path, delimiter=',')
data_test_images = data_test[:, :-1]
data_test_target = data_test[:, -1].astype(np.int)

# Fit a Support Vector Classifier
classifier = svm.SVC(C=svc_args.C, gamma=svc_args.G)
classifier.fit(data_train_images, data_train_target)

# Predict the value of the digit on the test dataset
predicted = classifier.predict(data_test_images)

print("Classification report for classifier {}:\n{}\n".format(
    classifier, metrics.classification_report(data_test_target, predicted)))
print("Confusion matrix:\n{}".format(
    metrics.confusion_matrix(data_test_target, predicted)))

# save the result to a file
if not os.path.exists('output'): os.makedirs('output')
export_path = os.path.join('output', 'digits_svm{}_C_{}_gamma_{}.txt'.format(
    svc_args.T, svc_args.C, svc_args.G))
np.savetxt(export_path, predicted, fmt="%1.0f")

# Do 30 seconds of useless work to simulate a long process...
import random, time
start_time = time.time(); now = start_time
while now < start_time + 30:
    a = [random.random() for i in range(1000000)]; sorted(a)
    now = time.time()
