require 'spec_helper'

RR = Diff::Comparison::RubricRule
Rubric = Diff::Comparison::Rubric

describe Diff::Comparison::Rubric do
  it 'should have a default rule, if none are specified, which applies to all paths' do
    r = Rubric.new
    r.applyRule({ :path => [], :difference => :added })
    expect(r.currentScore).to eq(1)
    r.applyRule({ :path => [:foo, :bar], :difference => :changed, :severity => 49 })
    expect(r.currentScore).to eq(2)
    r.applyRule({ :path => [:bar], :difference => :deleted })
    expect(r.currentScore).to eq(3)
    r.applyRule({ :path => [:some, :sub, :attr], :difference => :changed, :severity => 30 })
    expect(r.currentScore).to eq(4)
  end

  it 'should allow the user to set the starting score' do
    r = Rubric.new(nil, 20)
    r.applyRule({ :path => [], :difference => :added })
    expect(r.currentScore).to eq(21)
    r.applyRule({ :path => [:foo, :bar], :difference => :changed, :severity => 49 })
    expect(r.currentScore).to eq(22)
    r.applyRule({ :path => [:bar], :difference => :deleted })
    expect(r.currentScore).to eq(23)
    r.applyRule({ :path => [:some, :sub, :attr], :difference => :changed, :severity => 30 })
    expect(r.currentScore).to eq(24)
  end

  it 'should allow the user to reset the current score to the starting score' do
    r = Rubric.new(nil, 20)
    r.applyRule({ :path => [], :difference => :added })
    expect(r.currentScore).to eq(21)
    r.applyRule({ :path => [:foo, :bar], :difference => :changed, :severity => 49 })
    expect(r.currentScore).to eq(22)
    r.applyRule({ :path => [:bar], :difference => :deleted })
    expect(r.currentScore).to eq(23)
    r.reset
    r.applyRule({ :path => [:some, :sub, :attr], :difference => :changed, :severity => 30 })
    expect(r.currentScore).to eq(21)
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
    r.applyRule({ :path => [:a], :difference => :added })
    expect(r.currentScore).to eq(2)
    r.applyRule({ :path => [:b], :difference => :added })
    expect(r.currentScore).to eq(5)
    r.applyRule({ :path => [:c, :ca], :difference => :deleted })
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
    r.applyRule({ :path => [:b, :a], :difference => :added })
    expect(r.currentScore).to eq(3)
    r.applyRule({ :path => [:c, :ca, :caa], :difference => :deleted })
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
    r.applyRule({ :path => [:d, :da], :difference => :added })
    expect(r.currentScore).to eq(1)
    r.applyRule({ :path => [:e, :da, :dc, :cda], :difference => :added })
    expect(r.currentScore).to eq(2)
    r.applyRule({ :path => [:c, :cb], :difference => :deleted })
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
    r.applyRule({ :path => [:c, :cb], :difference => :deleted })
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
    r.applyRule({ :path => [:c, :cb, :cbc], :difference => :deleted })
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
    r.applyRule({ :path => [:c, :cb, :cbc], :difference => :deleted })
    expect(r.currentScore).to eq(20)
    r.applyRule({ :path => [:d, :cb, :cbc], :difference => :deleted })
    expect(r.currentScore).to eq(20)
  end
end
