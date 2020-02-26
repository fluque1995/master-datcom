## Cargamos el paquete gpml para aprendizaje con
## procesos gaussianos
pkg load gpml

function mat = confusionmat (labels, preds)
  mat = zeros(2,2);
  mat(1,1) = sum(labels == preds & labels == 1);
  mat(2,2) = sum(labels == preds & labels == -1);
  mat(1,2) = sum(labels != preds & labels == 1);
  mat(2,1) = sum(labels != preds & labels == -1);
endfunction

function predictions = get_single_probs(train_data, train_labels, test_data)
  ## Definimos la función de media, que será igual a 0
  meanfunc = @meanZero;

  ## Definimos la función de covarianza
  sf = 1.0;
  ell = 1.9;
  hyp.cov = log([ell sf]);
  covfunc = @covSEiso;

  ## Definimos el modelo de observación con la función logística
  likfunc = @likLogistic;

  ## Optimizamos los parámetros del modelo (sf y ell) con el conjunto de
  ## entrenamiento
  hyp = minimize(hyp, @gp, -40, @infVB, meanfunc, covfunc, likfunc,
                 train_data, train_labels);

  ## Realizamos la predicción
  [a b c d lp] = gp(hyp, @infVB, meanfunc, covfunc, likfunc, train_data,
                    train_labels, test_data, ones(rows(test_data),1));

  predictions = exp(lp);
endfunction

function mean_preds = get_probabilities(train_data, test_data)
  predictions = zeros(rows(test_data),0);

  for benign_fold = train_data.benign
    train_set = [benign_fold.histogram; train_data.malign];
    train_labels = [
                    -1*ones(rows(benign_fold.histogram),1)
                    ones(rows(train_data.malign),1)
    ];
    curr_preds = get_single_probs(train_set, train_labels, test_data);
    predictions = [predictions, curr_preds];
  endfor

  mean_preds = mean(predictions, 2);
endfunction

function conf_mat = evaluate_fold(benign_data, malign_data, i)
  train_idx = (1:5 != i);
  train_data.benign = benign_data(train_idx);
  malign_examples = zeros(0,10);
  for j = 1:5
    if j != i
      malign_examples = [malign_examples; malign_data(j).histogram];
    endif
  endfor
  train_data.malign = malign_examples;
  test_data = [benign_data(i).histogram; malign_data(i).histogram];
  test_labels = [-1*ones(rows(benign_data(i).histogram),1);
                 ones(rows(malign_data(i).histogram),1)];
  mean_preds = get_probabilities(train_data, test_data);
  pred_labels = int8(mean_preds > 0.5);
  pred_labels(pred_labels == 0) = -1;
  conf_mat = confusionmat(test_labels, pred_labels);
endfunction

## Cargamos el conjunto de datos
load Datos

conf_mats = {}
for i = 1:5
  conf_mat = evaluate_fold(Healthy_folds, Malign_folds, i);
  conf_mats(i) = conf_mat
  sum(diag(conf_mat))/sum(conf_mat(:))
endfor
