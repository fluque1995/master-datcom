import numpy as np
from algorithm import Algorithm

class WOA(Algorithm):
    def __init__(self, params=None):
        Algorithm.__init__(self, params)
        self.loss_train = []

    def train(self):
        gbest, gfit = self.__get_best_solution__()

        for i in range(self.epochs):
            a = 2 - 2 * i / (self.epochs - 1)

            for j in range(self.pop_size):
                r = np.random.rand()
                A = 2 * a * r - a
                C = 2 * r
                l = np.random.uniform(-1, 1)
                p = 0.5
                b = 1
                if (np.random.uniform() < p) :
                    if np.abs(A) < 1:
                        D = np.abs(C * gbest - self.population[j])
                        new_position = gbest - A * D
                    else:
                        x_rand = self.__create_solution__()
                        D = np.abs(
                            C * x_rand - self.population[j]
                        )
                        new_position = (x_rand - A * D)
                else:
                    D1 = np.abs(gbest - self.population[j])
                    new_position = D1 * np.exp(b * l) * np.cos(2 * np.pi * l) + gbest

                new_position[new_position < self.domain_range[0]] = self.domain_range[0]
                new_position[new_position > self.domain_range[1]] = self.domain_range[1]
                fit = self.objective_func(new_position)
                self.population[j] = np.array(new_position)
                self.fitness[j] = fit

            current_best, current_fit = self.__get_best_solution__()

            if current_fit < gfit:
                gbest = np.copy(current_best)
                gfit = current_fit

            if (i + 1) % self.mod == 0:
                self.loss_train.append(gfit)
                if self.verbose:
                    print(
                        "Epoch = {}, Best fit so far = {}".format(i + 1, gfit)
                    )

        return gbest, self.loss_train
