require 'diff/comparison/rubric_rule'
module Diff
  module Comparison
    class Rubric
      attr_reader :currentScore
      # a rubric should be a hash of rubric rules which modify a score.
      # The hash structure should mirror the structure of the hashes to
      # which the rules will be applied.
      #
      # For instance, if we're comparing
      #   a = { :a => "foo", :b => { :ba => 1 } }
      #   b = { :a => "foo", :b => { :ba => 2 }, :c => true }
      # then the rubric would be defined as (in its complete form):
      #   r = { :a => RubricRule.new(...), :b => { :ba => RubricRule.new(...) }, :c => RubricRule.new(...) }
      # RubricRule objects can be shared, if desired
      #   rule = RubricRule.new(...)
      #   r = { :a => rule, :b => { :ba => rule }, :c => rule }
      # You can also define a rubric rule which will be used for all child paths
      #   r = { :a => RubricRule.new(...), :b => RubricRule.new(...), :c => RubricRule.new(...) }
      # You can also define a default rubric rule which will be used when a rule for the corresponding path
      # is not found
      #   r = { :__default__ => RubricRule.new(...), :a => { :__default__ => RubricRule.new(...), :aa => RubricRule.new(...) } }
      def initialize(rubric = nil, initialScore = 0)
        @rubric = rubric || { :__default__ => RubricRule.defaultRule }
        @initialScore = initialScore
        @currentScore = initialScore
      end

      def reset
        @currentScore = @initialScore
      end

      def applyRule(path, difference, severity = 100)
        rule = findRule(path)
        @currentScore = rule.applyRule(@currentScore, difference, severity) if rule
      end

      private

      def findRule(path)
        tree = @rubric
        last_default = @rubric[:__default__]

        path.each do |path_part|
          if tree = tree[path_part]
            return tree if tree.is_a?(RubricRule)
            last_default = tree[:__default__] || last_default
          else
            break
          end
        end
        return last_default
      end
    end

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
          return m.call currentScore, severity
        end
        return currentScore
      end
    end
  end
end
