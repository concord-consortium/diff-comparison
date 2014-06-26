require 'spec_helper'

describe Diff::Comparison::SymbolDiff do
  it 'should correctly compare equal sequences' do
    seq1 = %w{one two three four}
    seq2 = %w{one two three four}
    out = ""
    callback = Diff::Comparison::SymbolDiff.new(out)
    Diff::LCS.traverse_sequences(seq1, seq2, callback)
    expect(out).to eq('====')
  end

  it 'should make the output accessible even without providing it at initialization' do
    seq1 = %w{one two three four}
    seq2 = %w{one two three four}
    callback = Diff::Comparison::SymbolDiff.new
    Diff::LCS.traverse_sequences(seq1, seq2, callback)
    expect(callback.output).to eq('====')
  end

  it 'should correctly identify missing elements from seq1' do
    seq1 = %w{one three}
    seq2 = %w{one two three four}
    callback = Diff::Comparison::SymbolDiff.new
    Diff::LCS.traverse_sequences(seq1, seq2, callback)
    expect(callback.output).to eq('=-=-')
  end

  it 'should correctly identify extra elements in seq1' do
    seq1 = %w{one two three four}
    seq2 = %w{one three}
    callback = Diff::Comparison::SymbolDiff.new
    Diff::LCS.traverse_sequences(seq1, seq2, callback)
    expect(callback.output).to eq('=+=+')
  end

  it 'should correctly identify differing elements in seq1 (sequences)' do
    seq1 = %w{one two six four}
    seq2 = %w{one two three four}
    callback = Diff::Comparison::SymbolDiff.new
    Diff::LCS.traverse_sequences(seq1, seq2, callback)
    expect(callback.output).to eq('==+-=')
  end

  it 'should correctly identify differing elements in seq1 (balanced)' do
    seq1 = %w{one two six four}
    seq2 = %w{one two three four}
    callback = Diff::Comparison::SymbolDiff.new
    Diff::LCS.traverse_balanced(seq1, seq2, callback)
    expect(callback.output).to eq('==*=')
  end
end
