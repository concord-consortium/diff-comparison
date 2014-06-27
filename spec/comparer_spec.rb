require 'spec_helper'

describe Diff::Comparison::Comparer do
  describe 'scoring' do
    it 'should score the differences between two hashes' do
      rubric = Diff::Comparison::Rubric.new
      left = { :a => 5, :b => true, :c => { :ca => "foo bar", :cb => "baz" }, :e => "This is a sentence about dogs."}
      right = { :a => 6, :b => true, :d => { :da => "foos ball", :db => "baseball" }, :e => "This is not a sentence about cats."}
      comparer = Diff::Comparison::Comparer.new(left, right)
      puts "Diffs: #{comparer.differences.inspect}"
      expect(comparer.score(rubric)).to eq(6)
    end
  end

  describe 'severity' do
    it 'should calculate severity of primitives as either 0 or 100' do
      c = Diff::Comparison::Comparer.new({},{})

      # matches
      expect(c.severity(1,1)).to eq(0)
      expect(c.severity(true,true)).to eq(0)
      expect(c.severity(false,false)).to eq(0)
      expect(c.severity(nil,nil)).to eq(0)
      # mismatches
      expect(c.severity(1,2)).to eq(100)
      expect(c.severity(true,false)).to eq(100)
      expect(c.severity(false,true)).to eq(100)
      expect(c.severity(nil,1)).to eq(100)
    end

    it 'should calculate severity of Strings as an int between 0 and 100' do
      c = Diff::Comparison::Comparer.new({},{})

      expect(c.severity('one two three','one two three')).to eq(0)
      expect(c.severity('seven eight three','one two three')).to eq(67)
      expect(c.severity('one four three','one two three')).to eq(34)
      expect(c.severity('four five six','one two three')).to eq(100)
      expect(c.severity(nil,'one two three')).to eq(100)
      expect(c.severity('four five six',nil)).to eq(100)
    end
  end
end
