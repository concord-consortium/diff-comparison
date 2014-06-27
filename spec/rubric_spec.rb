require 'spec_helper'

RR = Diff::Comparison::RubricRule
Rubric = Diff::Comparison::Rubric

describe Diff::Comparison::Rubric do
  it 'should have a default rule, if none are specified, which applies to all paths' do
    r = Rubric.new
    r.applyRule([], :added)
    expect(r.currentScore).to eq(1)
    r.applyRule([:foo, :bar], :changed, 49)
    expect(r.currentScore).to eq(2)
    r.applyRule([:bar], :deleted)
    expect(r.currentScore).to eq(3)
    r.applyRule([:some, :sub, :attr], :changed, 30)
    expect(r.currentScore).to eq(4)
  end

  it 'should allow the user to set the starting score' do
    r = Rubric.new(nil, 20)
    r.applyRule([], :added)
    expect(r.currentScore).to eq(21)
    r.applyRule([:foo, :bar], :changed, 49)
    expect(r.currentScore).to eq(22)
    r.applyRule([:bar], :deleted)
    expect(r.currentScore).to eq(23)
    r.applyRule([:some, :sub, :attr], :changed, 30)
    expect(r.currentScore).to eq(24)
  end

  it 'should apply the correct rule based on the path' do
    r = Rubric.new({
      :a => RR.new({:__default__ => lambda {|c,s| return c+2 }}),
      :b => RR.new({:__default__ => lambda {|c,s| return c+3 }}),
      :c => {
        :ca => RR.new({:__default__ => lambda {|c,s| return c+5 }})
      }
    })

    # same path as the rubric specifies
    r.applyRule([:a], :added)
    expect(r.currentScore).to eq(2)
    r.applyRule([:b], :added)
    expect(r.currentScore).to eq(5)
    r.applyRule([:c, :ca], :deleted)
    expect(r.currentScore).to eq(10)
  end

  it 'should apply the parent rule when a sub-path does not exist' do
    r = Rubric.new({
      :a => RR.new({:__default__ => lambda {|c,s| return c+2 }}),
      :b => RR.new({:__default__ => lambda {|c,s| return c+3 }}),
      :c => {
        :ca => RR.new({:__default__ => lambda {|c,s| return c+5 }})
      }
    })

    # same path as the rubric specifies
    r.applyRule([:b, :a], :added)
    expect(r.currentScore).to eq(3)
    r.applyRule([:c, :ca, :caa], :deleted)
    expect(r.currentScore).to eq(8)
  end

  it 'should apply the global __default__ rule when a path does not have an applicable rule' do
    r = Rubric.new({
      :__default__ => RR.new({:__default__ => lambda {|c,s| return c+1 }}),
      :a => RR.new({:__default__ => lambda {|c,s| return c+2 }}),
      :b => RR.new({:__default__ => lambda {|c,s| return c+3 }}),
      :c => {
        :__default__ => RR.new({:__default__ => lambda {|c,s| return c*2 }}),
        :ca => RR.new({:__default__ => lambda {|c,s| return c+5 }})
      }
    })

    # same path as the rubric specifies
    r.applyRule([:d, :da], :added)
    expect(r.currentScore).to eq(1)
    r.applyRule([:e, :da, :dc, :cda], :added)
    expect(r.currentScore).to eq(2)
    r.applyRule([:c, :cb], :deleted)
    expect(r.currentScore).to eq(4)
  end

  it 'should apply the path __default__ rule when a path does not have an applicable rule' do
    r = Rubric.new({
      :__default__ => RR.new({:__default__ => lambda {|c,s| return c+1 }}),
      :a => RR.new({:__default__ => lambda {|c,s| return c+2 }}),
      :b => RR.new({:__default__ => lambda {|c,s| return c+3 }}),
      :c => {
        :__default__ => RR.new({:__default__ => lambda {|c,s| return c*2 }}),
        :ca => RR.new({:__default__ => lambda {|c,s| return c+5 }})
      }
    }, 10)

    # same path as the rubric specifies
    r.applyRule([:c, :cb], :deleted)
    expect(r.currentScore).to eq(20)
  end

  it 'should apply a parent path __default__ rule when a path does not have an applicable rule' do
    r = Rubric.new({
      :__default__ => RR.new({:__default__ => lambda {|c,s| return c+1 }}),
      :a => RR.new({:__default__ => lambda {|c,s| return c+2 }}),
      :b => RR.new({:__default__ => lambda {|c,s| return c+3 }}),
      :c => {
        :__default__ => RR.new({:__default__ => lambda {|c,s| return c*2 }}),
        :ca => RR.new({:__default__ => lambda {|c,s| return c+5 }}),
        :cb => {
          :cba => RR.new({:__default__ => lambda {|c,s| return c+8 }})
        }
      }
    }, 20)

    # same path as the rubric specifies
    r.applyRule([:c, :cb, :cbc], :deleted)
    expect(r.currentScore).to eq(40)
  end

  it 'should not apply a rule if the path does not have an applicable rule and no defaults are specified' do
    r = Rubric.new({
      :a => RR.new({:__default__ => lambda {|c,s| return c+2 }}),
      :b => RR.new({:__default__ => lambda {|c,s| return c+3 }}),
      :c => {
        :ca => RR.new({:__default__ => lambda {|c,s| return c+5 }}),
        :cb => {
          :cba => RR.new({:__default__ => lambda {|c,s| return c+8 }})
        }
      }
    }, 20)

    # same path as the rubric specifies
    r.applyRule([:c, :cb, :cbc], :deleted)
    expect(r.currentScore).to eq(20)
    r.applyRule([:d, :cb, :cbc], :deleted)
    expect(r.currentScore).to eq(20)
  end
end
