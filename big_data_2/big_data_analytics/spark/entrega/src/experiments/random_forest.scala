package experiments

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.rdd.RDD
import experiments.Preprocessing

class RandomForestExperiments(train: RDD[LabeledPoint], test: RDD[LabeledPoint]) {
  def performSimpleExperiment() = {
    val numClasses = 2
    val categoricalFeaturesInfo = Map[Int, Int]()
    val numTrees = 100
    val featureSubsetStrategy = "auto" // Let the algorithm choose.
    val impurity = "gini"
    val maxDepth = 4
    val maxBins = 32

    val modelRF = RandomForest.trainClassifier(
      train, numClasses, categoricalFeaturesInfo, numTrees,
      featureSubsetStrategy, impurity, maxDepth, maxBins
    )

    // Evaluate model on test instances and compute test error
    test.map { point =>
      val prediction = modelRF.predict(point.features)
      (prediction, point.label)
    }
  }

  def performROSExperiment(overRate: Double) = {
    val numClasses = 2
    val categoricalFeaturesInfo = Map[Int, Int]()
    val numTrees = 100
    val featureSubsetStrategy = "auto" // Let the algorithm choose.
    val impurity = "gini"
    val maxDepth = 4
    val maxBins = 32

    val augmented_train = Preprocessing.ROS(train, overRate)

    val modelRF = RandomForest.trainClassifier(
      augmented_train, numClasses, categoricalFeaturesInfo, numTrees,
      featureSubsetStrategy, impurity, maxDepth, maxBins
    )

    // Evaluate model on test instances and compute test error
    test.map { point =>
      val prediction = modelRF.predict(point.features)
      (prediction, point.label)
    }
  }

  def performRUSExperiment() = {
    val numClasses = 2
    val categoricalFeaturesInfo = Map[Int, Int]()
    val numTrees = 100
    val featureSubsetStrategy = "auto" // Let the algorithm choose.
    val impurity = "gini"
    val maxDepth = 4
    val maxBins = 32

    val reduced_train = Preprocessing.RUS(train)

    val modelRF = RandomForest.trainClassifier(
      reduced_train, numClasses, categoricalFeaturesInfo, numTrees,
      featureSubsetStrategy, impurity, maxDepth, maxBins
    )

    // Evaluate model on test instances and compute test error
    test.map { point =>
      val prediction = modelRF.predict(point.features)
      (prediction, point.label)
    }
  }
}
