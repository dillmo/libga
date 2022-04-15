# frozen_string_literal: true

# A library of statistics functions
class Stats
  # forall w in weights: w >= 0.0
  # sum(weights) > 0.0
  # Returns an index in weights by weighted probability
  def self.choose1(weights)
    # cumulative = sum(weights[0, i])
    i = 0
    cumulative = 0.0

    # 0.0 <= rnum < sum(weights)
    rnum = Random.rand(weights.sum.to_f)

    # invariant: cumulative <= rnum
    # variant: weights.len - i
    while cumulative + weights[i] <= rnum
      cumulative += weights[i]
      i += 1
    end

    # cumulative <= rnum < cumulative + weights[i]
    i
  end

  # replace => count <= values.len
  # Returns count values chosen with weighted probability
  def self.choose(values:, weights:, count:, replace: false)
    chosen = []
    dupweights = weights.dup

    # invariant: forall x in chosen: x in values
    # variant: count - chosen.length
    while chosen.length < count
      idx = choose1(dupweights)
      chosen << values[idx]
      dupweights.delete_at(idx) unless replace
    end

    chosen
  end
end
