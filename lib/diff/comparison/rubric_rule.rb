module Diff
  module Comparison
    class RubricRule
      # provide a default which increments by 1
      def self.defaultRule
        return RubricRule.new({ :__default__ => lambda {|currentScore, severity| return currentScore + 1 } })
      end

      # matchers is a hash, where the keys are a "difference", and the values are lambda functions
      # with two arguments (current score and the severity of the difference).
      #
      # Valid "differences": :added, :changed, :removed
      # The severity will be a value between 0 and 100, inclusive (a percentage, basically)
      def initialize(matchers)
        @matchers = matchers
      end

      def applyRule(currentScore, difference, severity = 100)
        if m = (@matchers[difference] || @matchers[:__default__])
          numArgsExpected = m.arity.abs
          args = [currentScore, severity].slice(0,numArgsExpected)
          args.fill(nil, args.length...numArgsExpected) if numArgsExpected > args.length
          return m.call(*args)
        end
        return currentScore
      end
    end
  end
end
