require 'spec_helper'

describe Diff::Comparison::Comparer do
  describe 'scoring' do
    it 'should score the differences between two hashes' do
      rubric = Diff::Comparison::Rubric.new
      left = { :a => 5, :b => true, :c => { :ca => "foo bar", :cb => "baz" }, :e => "This is a sentence about dogs."}
      right = { :a => 6, :b => true, :d => { :da => "foos ball", :db => "baseball" }, :e => "This is not a sentence about cats."}
      comparer = Diff::Comparison::Comparer.new(left, right)
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

  describe 'html' do
    # span classes are match, only_a, only_b and change, by default
    it 'should calculate html of primitives correctly' do
      c = Diff::Comparison::Comparer.new({},{})

      # matches
      expect(c.html(1,1)).to         eq(['<span class="match">1</span> ',      nil])
      expect(c.html(true,true)).to   eq(['<span class="match">true</span> ',   nil])
      expect(c.html(false,false)).to eq(['<span class="match">false</span> ',  nil])
      expect(c.html(nil,nil)).to     eq(['<span class="match">&nbsp;</span> ', nil])
      # mismatches, only left
      expect(c.html(1,2)).to        eq(['<span class="change">1</span> ',    nil])
      expect(c.html(true,false)).to eq(['<span class="change">true</span> ', nil])
      expect(c.html(false,true)).to eq(['<span class="change">false</span> ', nil])
      expect(c.html(nil,1)).to      eq(['<span class="change">&nbsp;</span> ',    nil])
      # mismatches, both left and right
      expect(c.html(1,2,true)).to        eq(['<span class="change">1</span> ',      '<span class="change">2</span> '])
      expect(c.html(true,false,true)).to eq(['<span class="change">true</span> ',   '<span class="change">false</span> '])
      expect(c.html(false,true,true)).to eq(['<span class="change">false</span> ',  '<span class="change">true</span> '])
      expect(c.html(nil,1,true)).to      eq(['<span class="change">&nbsp;</span> ', '<span class="change">1</span> '])
    end

    it 'should calculate html of Strings as an int between 0 and 100' do
      c = Diff::Comparison::Comparer.new({},{})

      # only left
      expect(c.html('one two three','one two three')).to     eq(['<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> ',       nil])
      expect(c.html('seven eight three','one two three')).to eq(['<span class="change">seven</span> <span class="change">eight</span> <span class="match">three</span> ', nil])
      expect(c.html('one four three','one two three')).to    eq(['<span class="match">one</span> <span class="change">four</span> <span class="match">three</span> ',     nil])
      expect(c.html('four five six','one two three')).to     eq(['<span class="change">four</span> <span class="change">five</span> <span class="change">six</span> ',    nil])
      expect(c.html(nil,'one two three')).to                 eq(['<span class="only_b">one</span> <span class="only_b">two</span> <span class="only_b">three</span> ',    nil])
      expect(c.html('four five six',nil)).to                 eq(['<span class="only_a">four</span> <span class="only_a">five</span> <span class="only_a">six</span> ',    nil])
      expect(c.html('two three','one two three')).to         eq(['<span class="only_b">one</span> <span class="match">two</span> <span class="match">three</span> ',      nil])
      expect(c.html('one two three','one three')).to         eq(['<span class="match">one</span> <span class="only_a">two</span> <span class="match">three</span> ',      nil])

      # left and right
      expect(c.html('one two three','one two three', true)).to     eq(['<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> ',       '<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> '])
      expect(c.html('seven eight three','one two three', true)).to eq(['<span class="change">seven</span> <span class="change">eight</span> <span class="match">three</span> ', '<span class="change">one</span> <span class="change">two</span> <span class="match">three</span> '])
      expect(c.html('one four three','one two three', true)).to    eq(['<span class="match">one</span> <span class="change">four</span> <span class="match">three</span> ',     '<span class="match">one</span> <span class="change">two</span> <span class="match">three</span> '])
      expect(c.html('four five six','one two three', true)).to     eq(['<span class="change">four</span> <span class="change">five</span> <span class="change">six</span> ',    '<span class="change">one</span> <span class="change">two</span> <span class="change">three</span> '])
      expect(c.html(nil,'one two three', true)).to                 eq(['',    '<span class="only_b">one</span> <span class="only_b">two</span> <span class="only_b">three</span> '])
      expect(c.html('four five six',nil, true)).to                 eq(['<span class="only_a">four</span> <span class="only_a">five</span> <span class="only_a">six</span> ',    ''])
      expect(c.html('two three','one two three', true)).to         eq(['<span class="match">two</span> <span class="match">three</span> ',      '<span class="only_b">one</span> <span class="match">two</span> <span class="match">three</span> '])
      expect(c.html('one two three','one three', true)).to         eq(['<span class="match">one</span> <span class="only_a">two</span> <span class="match">three</span> ',      '<span class="match">one</span> <span class="match">three</span> '])
    end
  end
end
