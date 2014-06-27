require 'cgi'

module Diff
  module Comparison
    class Comparer

      def initialize(left, right)
        @left = flatten(left)
        @right = flatten(right)
      end

      def differences
        process
        return unflatten(@differences)
      end

      def flat_differences
        process
        return @differences
      end

      def score(rubric)
        rubric.reset
        flat_differences.each do |path,result|
          rubric.applyRule(path, result[:difference], result[:severity])
        end
        return rubric.currentScore
      end

      # returns a value from 0 to 100 inclusive (essentially a percentage)
      # 0 means the values are the same, 100 means the values are entirely different
      def severity(left, right)
        return 0 if left == right
        return 100 if left.nil? || right.nil?
        return 100 if left.class != right.class
        if left.is_a?(String)
          # compare the strings
          # symbol diff returns a string of +-=* which represent whether the "word" was added, deleted, the same, or changed.
          sd = SymbolDiff.new

          a = CGI.escapeHTML(left).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
          a.delete("")
          b = CGI.escapeHTML(right).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
          b.delete("")

          Diff::LCS.traverse_balanced(a, b, sd)

          # return the percent of words that are different
          same = sd.output.count("=")
          return 100-((same.to_f/sd.output.size)*100).to_i
        else
          return 100 # the objects are different
        end
      end

      private

      def process
        return if @processed

        only_left = @left.keys - @right.keys
        only_right = @right.keys - @left.keys
        both = @left.keys & @right.keys

        @differences = {}
        only_left.each do |k|
          @differences[k] = {:difference => :added, :severity => severity(@left[k], nil)}
        end
        only_right.each do |k|
          @differences[k] = {:difference => :deleted, :severity => severity(nil, @right[k])}
        end
        both.each do |k|
          s = severity(@left[k], @right[k])
          @differences[k] = {:difference => :changed, :severity => s} unless s == 0
        end

        @processed = true
      end

      def flatten(h, f=[], g={})
        return g.update({ f=>h }) unless h.is_a? Hash
        h.each { |k,r| flatten(r,f+[k],g) }
        g
      end

      def unflatten(h)
        out = {}
        h.each do |k,v|
          parent = out
          k.each do |kp|
            if k.last == kp
              parent[kp] = v
            else
              parent[kp] ||= {}
              parent = parent[kp]
            end
          end
          parent = v
        end
        out
      end
    end
  end
end
