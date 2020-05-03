package experiments

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.classification.kNN_IS.{Distance, kNN_IS}
import org.apache.spark.rdd.RDD
import experiments.Preprocessing

class KNNExperiments(train: RDD[LabeledPoint], test: RDD[LabeledPoint]) {
  def performSimpleExperiment(sc: SparkContext) = {
    var nearestNeighbours = 2
    var numClasses = 2
    var numFeatures = 18
    var numIterations = 100

    val modelKNN = kNN_IS.setup(
      train, test, nearestNeighbours, 2,
      numClasses, numFeatures, -1, -1, numIterations, 1
    )

    modelKNN.predict(sc)
  }

  def performROSExperiment(sc: SparkContext, overRate: Double) = {
    var nearestNeighbours = 2
    var numClasses = 2
    var numFeatures = 18
    var numIterations = 100

    val augmented_train = Preprocessing.ROS(train, overRate)

    val modelKNN = kNN_IS.setup(
      augmented_train, test, nearestNeighbours, 2,
      numClasses, numFeatures, -1, -1, numIterations, 1
    )

    modelKNN.predict(sc)
  }

  def performRUSExperiment(sc: SparkContext) = {
    var nearestNeighbours = 2
    var numClasses = 2
    var numFeatures = 18
    var numIterations = 100

    val reduced_train = Preprocessing.RUS(train)

    val modelKNN = kNN_IS.setup(
      reduced_train, test, nearestNeighbours, 2,
      numClasses, numFeatures, -1, -1, numIterations, 1
    )

    modelKNN.predict(sc)
  }

}
