import numpy as np
from algorithm import Algorithm

class MFO(Algorithm):
    def __init__(self, params):
        Algorithm.__init__(self, params)
        self.loss_train = []

    def train(self):
        gbest, gfit = self.__get_best_solution__()

        for i in range(self.epochs):
            n_flames = np.int(self.pop_size - i*(self.pop_size-1)/self.epochs)
            if i == 0:
                sorted_pop, sorted_fits = self.__sort_population__(
                    self.population, self.fitness
                )
                best_flames = sorted_pop
                best_flames_fit = sorted_fits
            else:
                pop_doubled = self.population + prev_pop
                fit_doubled = self.fitness + prev_fit

                sorted_pop, sorted_fits = self.__sort_population__(
                    pop_doubled, fit_doubled
                )
                best_flames = sorted_pop[:self.pop_size]
                best_flames_fit = sorted_fits[:self.pop_size]

            prev_pop = [elem.copy() for elem in self.population]
            prev_fit = self.fitness.copy()
            a = -1 - i/self.epochs

            for j in range(self.pop_size):
                if j < n_flames:
                    dist = np.abs(best_flames[j] - self.population[j])
                    t = np.random.uniform(a, 1)
                    self.population[j] = dist * np.exp(t) * np.cos(
                        t*2*np.pi
                    ) + best_flames[j]
                else:
                    dist = np.abs(best_flames[n_flames] - self.population[j])
                    t = np.random.uniform(a, 1)
                    self.population[j] = dist * np.exp(t) * np.cos(
                        t*2*np.pi
                    ) + best_flames[n_flames]

                self.fitness[j] = self.objective_func(self.population[j])

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

    def __sort_population__(self, pop, fits):
        ordering = np.argsort(fits)
        return [pop[i].copy() for i in ordering], [fits[i] for i in ordering]
