puts "**** INIT CLASSIFIER ****"
@work_classifier = WorkClassifier.new
@work_classifier.train
#@work_classifier.classifier_test
puts "**** END CLASSIFIER ****"