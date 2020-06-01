import numpy as np

class Algorithm(object):

    def __init__(self, params = None):
        self.problem_size = params["problem_size"]
        self.domain_range = params['domain_range']
        self.objective_func = params['objective_func']
        self.epochs = params['epochs']
        self.pop_size = params['pop_size']
        self.verbose = params['verbose']
        self.num_measurements = params['num_measurements']
        self.mod = np.int(self.epochs / self.num_measurements)

        self.population = self.__init_population__()
        self.fitness = [self.objective_func(elem) for elem in self.population]

    def __init_population__(self):
        return [
            np.random.uniform(
                self.domain_range[0], self.domain_range[1], self.problem_size
            ) for i in range(self.pop_size)
        ]

    def __amend_solution__(self, sol):
        return np.clip(sol, self.domain_range[0], self.domain_range[1])

    def __create_solution__(self):
        return np.random.uniform(
            self.domain_range[0], self.domain_range[1], self.problem_size
        )

    def __get_best_solution__(self):
        idx = np.argmin(self.fitness)
        return self.population[idx], self.fitness[idx]
