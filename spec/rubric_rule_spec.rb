require 'spec_helper'

describe Diff::Comparison::RubricRule do
  it 'should provide a default rule which can be used' do
    ret = Diff::Comparison::RubricRule.defaultRule.applyRule(0, :foo, 100)
    expect(ret).to eq(1)
  end

  it 'should allow custom rules to be built' do
    rule = Diff::Comparison::RubricRule.new({
      :__default__ => lambda {|c,s| return c+2 },
      :added   => lambda {|c,s| return c+4 },
      :changed => lambda {|c,s| return c+(0.02*s) },
      :deleted => lambda {|c,s| return c*0.5 }
    })

    expect(rule.applyRule(100, :added, 100)).to eq(104)
    expect(rule.applyRule(100, :changed, 10)).to eq(100.2)
    expect(rule.applyRule(100, :changed, 40)).to eq(100.8)
    expect(rule.applyRule(100, :changed, 100)).to eq(102)
    expect(rule.applyRule(100, :deleted, 100)).to eq(50)
  end
end
