package experiments

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.rdd.RDD
import experiments.Preprocessing

class DecisionTreeExperiments(train: RDD[LabeledPoint], test: RDD[LabeledPoint]) {
  def performSimpleExperiment() = {
    var numClasses = 2
    var categoricalFeaturesInfo = Map[Int, Int]()
    var impurity = "gini"
    var maxDepth = 5
    var maxBins = 32

    val modelDT = DecisionTree.trainClassifier(
      train, numClasses, categoricalFeaturesInfo, impurity, maxDepth, maxBins
    )

    // Evaluate model on test instances and compute test error
    test.map { point =>
      val prediction = modelDT.predict(point.features)
      (prediction, point.label)
    }
  }

  def performROSExperiment(overRate: Double) = {
    var numClasses = 2
    var categoricalFeaturesInfo = Map[Int, Int]()
    var impurity = "gini"
    var maxDepth = 5
    var maxBins = 32

    val augmented_train = Preprocessing.ROS(train, overRate)

    val modelDT = DecisionTree.trainClassifier(
      augmented_train, numClasses, categoricalFeaturesInfo, impurity, maxDepth, maxBins
    )

    // Evaluate model on test instances and compute test error
    test.map { point =>
      val prediction = modelDT.predict(point.features)
      (prediction, point.label)
    }
  }

  def performRUSExperiment() = {
    var numClasses = 2
    var categoricalFeaturesInfo = Map[Int, Int]()
    var impurity = "gini"
    var maxDepth = 5
    var maxBins = 32

    val reduced_train = Preprocessing.RUS(train)

    val modelDT = DecisionTree.trainClassifier(
      reduced_train, numClasses, categoricalFeaturesInfo, impurity, maxDepth,
      maxBins
    )

    // Evaluate model on test instances and compute test error
    test.map { point =>
      val prediction = modelDT.predict(point.features)
      (prediction, point.label)
    }
  }
}
