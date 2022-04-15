#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../src/genetic_optimizer'

# The Ruby Random class, to which we add one method for generating random
# 64-bit unsigned integers.
class Random
  def self.randuint64
    bytes(8).unpack1('Q')
  end
end

# Represents a closed interval with a low and high limit
ClosedInterval = Struct.new('ClosedInterval', :l, :h)

# The maximum possible 64-bit unsigned integer
MAXUINT64 = 0xFFFFFFFFFFFFFFFF

# A genetic algorithm chromosome which represents a function x value as a bit
# string and is used to maximize functions on an interval.
class Chromosome
  attr_reader :bitvector, :objectivefun, :domain, :value, :fitness

  # Initialize a Chromosome for optimizing an objective function within a
  # domain.
  # Bitvector is an internal representation of a Chromosome meant to be used by
  # Chromosomes to create new Chromosomes. When initializing a Chromosome
  # yourself, let it take its default value.
  def initialize(objectivefun:, domain:, bitvector: Random.randuint64)
    @bitvector = bitvector
    @objectivefun = objectivefun
    @domain = domain
    minval = domain.l
    scalefactor = (domain.h - domain.l) / MAXUINT64
    @value = minval + scalefactor * bitvector
    @fitness = objectivefun.call(value)
  end

  # Creates a new Chromosome which has the same objective function and domain as
  # this Chromosome, but a new bit vector.
  def clone(bitvector)
    Chromosome.new(bitvector: bitvector, objectivefun: objectivefun, domain: domain)
  end

  # Crossover. Picks a random locus between two bits, then splits both
  # Chromosomes around that locus and recombines them to create two new
  # Chromosomes.
  def *(other)
    # The bit vector representation of each Chromosome.
    a = bitvector
    b = other.bitvector

    # A random locus around which to split both bit vectors.
    locus = Random.rand(64)

    # rightmask selects all bits to the right of the locus.
    # leftmask selects all to the left.
    rightmask = MAXUINT64 >> locus
    leftmask = rightmask << locus

    # Split and recombine the two bit vectors.
    c = leftmask & a | rightmask & b
    d = leftmask & b | rightmask & a

    # Return two new Chromosomes with the new bit vectors.
    [clone(c), clone(d)]
  end

  # Mutation. Separately flips each bit approximately mutationrate% of the time.
  def mutate(mutationrate)
    # The bit vector representation of this Chromosome.
    x = bitvector

    # A mask that selects a single bit.
    bitmask = 1 << 63

    # variant: position of the mask bit
    while bitmask.positive?
      # Flip the corresponding bit approximately mutationrate% of the time
      x ^= bitmask if Random.rand < mutationrate

      # Move the mask bit 1 to the right.
      bitmask >>= 1
    end

    # Return a new Chromosome with the mutated bit vector.
    clone(x)
  end
end

# Optimize f(x) = x + |sin(32x)| on the interval [0, pi] using 50 generations of
# a genetic algorithm.
interval = ClosedInterval.new(0.0, Math::PI)
f = proc { |x| x + Math.sin(32 * x).abs }
ga = GeneticOptimizer.new(chromclass: Chromosome, objectivefun: f,
                          domain: interval)
50.times { ga.step }
puts ga.best
