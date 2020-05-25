package main

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.feature.{PCA, PCAModel}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.{SparkConf, SparkContext}
import java.io.{File, PrintWriter}
import experiments.{DecisionTreeExperiments, RandomForestExperiments,
  KNNExperiments, ResultsWriter}

object runPCAExperiments {
  def main(arg: Array[String]) {
    val jobName = "Big Data II - PCA"

    val conf = new SparkConf().setAppName(jobName)
    val sc = new SparkContext(conf)

    sc.setLogLevel("ERROR")

    val dataPath = "/home/fluque1995/dev/master/big_data_2/big_data_analytics/spark/dataset/"

    val pathTrain = dataPath + "susy-10k-tra.data"
    val pathTest = dataPath + "susy-10k-tst.data"

    val rawDataTrain = sc.textFile(pathTrain)
    val rawDataTest = sc.textFile(pathTest)

    val train = rawDataTrain.map { line =>
      val array = line.split(",")
      val arrayDouble = array.map(f => f.toDouble)
      val featureVector = Vectors.dense(arrayDouble.init)
      val label = arrayDouble.last
      LabeledPoint(label, featureVector)
    }.persist

    val test = rawDataTest.map { line =>
      val array = line.split(",")
      val arrayDouble = array.map(f => f.toDouble)
      val featureVector = Vectors.dense(arrayDouble.init)
      val label = arrayDouble.last
      LabeledPoint(label, featureVector)
    }.persist

    val trainMat = train.map {pt => pt.features}

    val pca = new PCA(5)
    val pcaModel = pca.fit(trainMat)

    val pca_train = train.map {pt =>
      LabeledPoint(pt.label, pcaModel.transform(pt.features))
    }

    val pca_test = test.map {pt =>
      LabeledPoint(pt.label, pcaModel.transform(pt.features))
    }

    // Models execution
    val dtExperiments = new DecisionTreeExperiments(pca_train, pca_test)
    val rfExperiments = new RandomForestExperiments(pca_train, pca_test)
    val knnExperiments = new KNNExperiments(pca_train, pca_test)

    // Executions
    println("Executing Decision Tree Experiments...")
    val predsAndLabelsDT = dtExperiments.performSimpleExperiment
    val predsAndLabelsDTROS = dtExperiments.performROSExperiment(1.0)
    val predsAndLabelsDTRUS = dtExperiments.performRUSExperiment

    println("Executing Random Forest Experiments...")
    val predsAndLabelsRF = rfExperiments.performSimpleExperiment
    val predsAndLabelsRFROS = rfExperiments.performROSExperiment(1.0)
    val predsAndLabelsRFRUS = rfExperiments.performRUSExperiment

    println("Executing KNN Experiments...")
    val predsAndLabelsKNN = knnExperiments.performSimpleExperiment(sc)
    val predsAndLabelsKNNROS = knnExperiments.performROSExperiment(sc, 1.0)
    val predsAndLabelsKNNRUS = knnExperiments.performRUSExperiment(sc)

    // Results Logger
    val writer = new ResultsWriter(
      "/home/fluque1995/dev/master/big_data_2/big_data_analytics/spark/entrega/results-pca.txt"
    )

    println("Writing results")
    writer.writeExperiment("DT - Simple", predsAndLabelsDT)
    writer.writeExperiment("DT - ROS", predsAndLabelsDTROS)
    writer.writeExperiment("DT - RUS", predsAndLabelsDTRUS)

    writer.writeExperiment("RF - Simple", predsAndLabelsRF)
    writer.writeExperiment("RF - ROS", predsAndLabelsRFROS)
    writer.writeExperiment("RF - RUS", predsAndLabelsRFRUS)

    writer.writeExperiment("KNN - Simple", predsAndLabelsKNN)
    writer.writeExperiment("KNN - ROS", predsAndLabelsKNNROS)
    writer.writeExperiment("KNN - RUS", predsAndLabelsKNNRUS)

    writer.close()
  }
}

object runBasicExperiments {
  def main(arg: Array[String]) {
    val jobName = "Big Data II - Básicos"

    val conf = new SparkConf().setAppName(jobName)
    val sc = new SparkContext(conf)

    sc.setLogLevel("ERROR")

    val dataPath = "/home/fluque1995/dev/master/big_data_2/big_data_analytics/spark/dataset/"

    val pathTrain = dataPath + "susy-10k-tra.data"
    val pathTest = dataPath + "susy-10k-tst.data"

    val rawDataTrain = sc.textFile(pathTrain)
    val rawDataTest = sc.textFile(pathTest)

    val train = rawDataTrain.map { line =>
      val array = line.split(",")
      val arrayDouble = array.map(f => f.toDouble)
      val featureVector = Vectors.dense(arrayDouble.init)
      val label = arrayDouble.last
      LabeledPoint(label, featureVector)
    }.persist

    val test = rawDataTest.map { line =>
      val array = line.split(",")
      val arrayDouble = array.map(f => f.toDouble)
      val featureVector = Vectors.dense(arrayDouble.init)
      val label = arrayDouble.last
      LabeledPoint(label, featureVector)
    }.persist



    // Models execution
    val dtExperiments = new DecisionTreeExperiments(train, test)
    val rfExperiments = new RandomForestExperiments(train, test)
    val knnExperiments = new KNNExperiments(train, test)

    // Executions
    println("Executing Decision Tree Experiments...")
    val predsAndLabelsDT = dtExperiments.performSimpleExperiment
    val predsAndLabelsDTROS = dtExperiments.performROSExperiment(1.0)
    val predsAndLabelsDTRUS = dtExperiments.performRUSExperiment

    println("Executing Random Forest Experiments...")
    val predsAndLabelsRF = rfExperiments.performSimpleExperiment
    val predsAndLabelsRFROS = rfExperiments.performROSExperiment(1.0)
    val predsAndLabelsRFRUS = rfExperiments.performRUSExperiment

    println("Executing KNN Experiments...")
    val predsAndLabelsKNN = knnExperiments.performSimpleExperiment(sc)
    val predsAndLabelsKNNROS = knnExperiments.performROSExperiment(sc, 1.0)
    val predsAndLabelsKNNRUS = knnExperiments.performRUSExperiment(sc)

    // Results Logger
    val writer = new ResultsWriter(
      "/home/fluque1995/dev/master/big_data_2/big_data_analytics/spark/entrega/results.txt"
    )

    println("Writing results")
    writer.writeExperiment("DT - Simple", predsAndLabelsDT)
    writer.writeExperiment("DT - ROS", predsAndLabelsDTROS)
    writer.writeExperiment("DT - RUS", predsAndLabelsDTRUS)

    writer.writeExperiment("RF - Simple", predsAndLabelsRF)
    writer.writeExperiment("RF - ROS", predsAndLabelsRFROS)
    writer.writeExperiment("RF - RUS", predsAndLabelsRFRUS)

    writer.writeExperiment("KNN - Simple", predsAndLabelsKNN)
    writer.writeExperiment("KNN - ROS", predsAndLabelsKNNROS)
    writer.writeExperiment("KNN - RUS", predsAndLabelsKNNRUS)

    writer.close()
  }
}
