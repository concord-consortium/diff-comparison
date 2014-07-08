require 'spec_helper'

describe Diff::Comparison::RubricRule do
  it 'should provide a default rule which can be used' do
    ret = Diff::Comparison::RubricRule.defaultRule.applyRule({:currentScore => 0, :difference => :changed, :severity => 100})
    expect(ret).to eq(1)
  end

  it 'should allow custom rules to be built' do
    rule = Diff::Comparison::RubricRule.new({
      :__default__ => lambda {|c,s| return c+2 },
      :added   => lambda {|c,s| return c+4 },
      :changed => lambda {|c,s| return c+(0.02*s) },
      :deleted => lambda {|c,s| return c*0.5 }
    })

    expect(rule.applyRule({:currentScore => 100, :difference => :added, :severity => 100})).to eq(104)
    expect(rule.applyRule({:currentScore => 100, :difference => :changed, :severity => 10})).to eq(100.2)
    expect(rule.applyRule({:currentScore => 100, :difference => :changed, :severity => 40})).to eq(100.8)
    expect(rule.applyRule({:currentScore => 100, :difference => :changed, :severity => 100})).to eq(102)
    expect(rule.applyRule({:currentScore => 100, :difference => :deleted, :severity => 100})).to eq(50)
  end

  it 'should correctly detect the number of arguments expected for each lamdba' do
    rule = Diff::Comparison::RubricRule.new({
      :__default__ => lambda {|c,s| return c+2 },
      :added   => lambda {|c| return c+4 },
      :changed => lambda {|c,s| return c+(0.02*s) },
      :deleted => lambda {|c,s| return c*0.5 }
    })

    expect(rule.applyRule({:currentScore => 100, :difference => :added, :severity => 100})).to eq(104)
    expect(rule.applyRule({:currentScore => 100, :difference => :changed, :severity => 10})).to eq(100.2)
    expect(rule.applyRule({:currentScore => 100, :difference => :changed, :severity => 40})).to eq(100.8)
    expect(rule.applyRule({:currentScore => 100, :difference => :changed, :severity => 100})).to eq(102)
    expect(rule.applyRule({:currentScore => 100, :difference => :deleted, :severity => 100})).to eq(50)
  end
end
