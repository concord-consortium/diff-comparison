require 'spec_helper'

describe Diff::Comparison::HtmlDiff do
  describe 'output both' do
    it 'should correctly compare equal sequences' do
      seq1 = %w{one two three four}
      seq2 = %w{one two three four}
      out = ""
      out2 = ""
      callback = Diff::Comparison::HtmlDiff.new(out, out2)
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(out).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> <span class="match">four</span> ')
      expect(out2).to eq('<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> <span class="match">four</span> ')
    end

    it 'should make the output accessible even without providing it at initialization' do
      seq1 = %w{one two three four}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> <span class="match">four</span> ')
      expect(callback.right_output).to eq('<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> <span class="match">four</span> ')
    end

    it 'should correctly identify missing elements from seq1' do
      seq1 = %w{one three}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">three</span> ')
      expect(callback.right_output).to eq('<span class="match">one</span> <span class="only_b">two</span> <span class="match">three</span> <span class="only_b">four</span> ')
    end

    it 'should correctly identify extra elements in seq1' do
      seq1 = %w{one two three four}
      seq2 = %w{one three}
      callback = Diff::Comparison::HtmlDiff.new
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="only_a">two</span> <span class="match">three</span> <span class="only_a">four</span> ')
      expect(callback.right_output).to eq('<span class="match">one</span> <span class="match">three</span> ')
    end

    it 'should correctly identify differing elements in seq1 (sequences)' do
      seq1 = %w{one two six four}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="only_a">six</span> <span class="match">four</span> ')
      expect(callback.right_output).to eq('<span class="match">one</span> <span class="match">two</span> <span class="only_b">three</span> <span class="match">four</span> ')
    end

    it 'should correctly identify differing elements in seq1 (balanced)' do
      seq1 = %w{one two six four}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new
      Diff::LCS.traverse_balanced(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="change">six</span> <span class="match">four</span> ')
      expect(callback.right_output).to eq('<span class="match">one</span> <span class="match">two</span> <span class="change">three</span> <span class="match">four</span> ')
    end
  end

  describe 'output only left' do
    it 'should correctly compare equal sequences' do
      seq1 = %w{one two three four}
      seq2 = %w{one two three four}
      out = ""
      callback = Diff::Comparison::HtmlDiff.new(out, nil)
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(out).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> <span class="match">four</span> ')
    end

    it 'should make the output accessible even without providing it at initialization' do
      seq1 = %w{one two three four}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new("", nil)
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="match">three</span> <span class="match">four</span> ')
      expect(callback.right_output).to eq(nil)
    end

    it 'should correctly identify missing elements from seq1' do
      seq1 = %w{one three}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new("", nil)
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="only_b">two</span> <span class="match">three</span> <span class="only_b">four</span> ')
    end

    it 'should correctly identify extra elements in seq1' do
      seq1 = %w{one two three four}
      seq2 = %w{one three}
      callback = Diff::Comparison::HtmlDiff.new("", nil)
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="only_a">two</span> <span class="match">three</span> <span class="only_a">four</span> ')
    end

    it 'should correctly identify differing elements in seq1 (sequences)' do
      seq1 = %w{one two six four}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new("", nil)
      Diff::LCS.traverse_sequences(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="only_a">six</span> <span class="only_b">three</span> <span class="match">four</span> ')
    end

    it 'should correctly identify differing elements in seq1 (balanced)' do
      seq1 = %w{one two six four}
      seq2 = %w{one two three four}
      callback = Diff::Comparison::HtmlDiff.new("", nil)
      Diff::LCS.traverse_balanced(seq1, seq2, callback)
      expect(callback.left_output).to  eq('<span class="match">one</span> <span class="match">two</span> <span class="change">six</span> <span class="match">four</span> ')
    end
  end
end
