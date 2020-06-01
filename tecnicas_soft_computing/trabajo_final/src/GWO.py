import numpy as np
from algorithm import Algorithm

class GWO(Algorithm):
    def __init__(self, params):
        Algorithm.__init__(self, params)
        self.loss_train = []

    def train(self):
        gbest, gfit = self.__get_best_solution__()

        for i in range(self.epochs):
            alpha, beta, delta = self.__get_dominants__()
            a = 2 - 2 * i / (self.epochs - 1)

            for j in range(self.pop_size):
                r1 = np.random.rand(self.problem_size)
                r2 = np.random.rand(self.problem_size)
                A1 = 2 * a * r1 - a
                C1 = 2 * r2
                D1 = np.abs(C1*alpha - self.population[j])
                X1 = alpha - A1*D1

                r1 = np.random.rand(self.problem_size)
                r2 = np.random.rand(self.problem_size)
                A2 = 2 * a * r1 - a
                C2 = 2 * r2
                D2 = np.abs(C2*beta - self.population[j])
                X2 = beta - A2*D2

                r1 = np.random.rand(self.problem_size)
                r2 = np.random.rand(self.problem_size)
                A3 = 2 * a * r1 - a
                C3 = 2 * r2
                D3 = np.abs(C3*delta - self.population[j])
                X3 = delta - A3*D3

                new_position = (X1 + X2 + X3)/3

                new_position[new_position < self.domain_range[0]] = self.domain_range[0]
                new_position[new_position > self.domain_range[1]] = self.domain_range[1]

                new_fit = self.objective_func(new_position)

                self.population[j] = np.array(new_position)
                self.fitness[j] = new_fit

            current_best, current_fit = self.__get_best_solution__()

            if  current_fit < gfit:
                gbest = np.copy(current_best)
                gfit = current_fit


            if (i + 1) % self.mod == 0:
                self.loss_train.append(gfit)
                if self.verbose:
                    print(
                        "Epoch = {}, Best fit so far = {}".format(i + 1, gfit)
                    )

        return gbest, self.loss_train

    def __get_dominants__(self):
        ordering = np.argsort(self.fitness)

        return (
            self.population[ordering[0]],
            self.population[ordering[1]],
            self.population[ordering[2]]
        )
