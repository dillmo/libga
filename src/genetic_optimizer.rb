# frozen_string_literal: true

require_relative 'stats'

# An instance of a genetic algorithm
class GeneticOptimizer
  private

  attr_reader :chromosomes, :objectivefun, :minval, :scalefactor, :crossoverrate,
              :mutationrate

  # Selects a pair of individuals by weighted probability, then performs
  # crossover approximately crossoverrate% of the time.
  def selectpair
    # Selection
    a, b = Stats.choose(values: chromosomes, weights: fitnesses, count: 2)
    # Crossover
    a, b = a * b if Random.rand < crossoverrate
    [a, b]
  end

  public

  # Initializes a new genetic optimizer using a chromosome class, which
  # must implement the value, fitness, mutate, and * (crossover) methods.
  # Can define population size, crossover rate, and mutation rate using keyword
  # arguments.
  # Additional keyword arguments are passed to chromosomes when they initialize.
  def initialize(chromclass:, popsize: 100, crossoverrate: 0.7,
                 mutationrate: 0.001, **chromargs)
    @chromosomes = Array.new(popsize) { chromclass.new(**chromargs) }
    @crossoverrate = crossoverrate
    @mutationrate = mutationrate
  end

  # Returns an array of population values.
  def population
    chromosomes.map(&:value)
  end

  # Returns an array of population fitnesses.
  def fitnesses
    chromosomes.map(&:fitness)
  end

  # Performs one step of the algorithm, which does selection, crossover, and
  # mutation in order.
  def step
    newchromosomes = []

    # Selection and crossover
    newchromosomes.push(*selectpair) while
      newchromosomes.length < chromosomes.length

    # The number of new chromosomes is even. If the population size is odd,
    # delete one so the two counts match.
    newchromosomes.delete_at(Random.rand(newchromosomes.length)) if
      newchromosomes.length > chromosomes.length

    # Mutation
    @chromosomes = newchromosomes.map { |c| c.mutate(mutationrate) }

    nil
  end

  # Returns a chromosome with the highest fitness value.
  def best
    chromosomes.max { |a, b| a.fitness <=> b.fitness }.value
  end
end
