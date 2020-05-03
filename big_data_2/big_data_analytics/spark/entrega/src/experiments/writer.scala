package experiments

import java.io.{File, PrintWriter}
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.rdd.RDD

class ResultsWriter(path: String){
  val _writer = new PrintWriter(path)
  def writeExperiment(identifier: String, predsAndLabels: RDD[(Double, Double)]) = {
    val metrics = new MulticlassMetrics(predsAndLabels)
    val acc = metrics.accuracy
    val confmat = metrics.confusionMatrix
    val tnr = metrics.truePositiveRate(0)
    val tpr = metrics.truePositiveRate(1)
    _writer.write(
      "Experiment: " + identifier + "\n" +
        "    Accuracy: " + acc + "\n" +
        "    TPR: " + tpr + "\n" +
        "    TNR: " + tnr + "\n" +
        "    TPR*TNR: " + tpr*tnr + "\n" +
        "    Confusion Matrix:\n"
    )
    for (elem <- confmat.rowIter) _writer.write("    " + elem + "\n")
    _writer.write("\n")
  }

  def close() = {
    _writer.close()
  }
}
