require "unified/diff"
require "spec_helper"

describe "Unified::Diff" do

  def lines
    [" Line 1", "+Line 2", "-Line 3"]
  end

  def chunk(orig = 1, mod = 1, lines = lines)
    Unified::Chunk.new(original: orig, modified: mod, lines: lines, section_header: "A header")
  end

  def diff(lines = lines)
    Unified::Diff.new original_filename: "Original", modified_filename: "Modified",
                      original_revision: "OrigRev",  modified_revision: "ModRev",
                      chunks: [chunk(1, 1, lines), chunk(25, 25, lines), chunk(50, 50, lines)]
  end

  describe ".parse!" do
    it "parses all valid diff files" do
      valid_diffs.each do |content|
        expect { Unified::Diff.parse!(content) }.not_to raise_error
      end
    end

    it "returns a Unified::Diff object" do
      valid_diffs.each do |content|
        expect(Unified::Diff.parse!(content)).to be_a_kind_of Unified::Diff
      end
    end

    it "raises a Unified::ParseError for invalid diffs" do
      invalid_diffs.each do |content|
        expect { Unified::Diff.parse!(content) }.to raise_error(Unified::ParseError)
      end
    end

    it "provides a line number and character for invalid diffs" do
      invalid_diffs.each do |content|
        begin
          Unified::Diff.parse!(content)
        rescue Unified::ParseError =>  e
          e.message.should match /line \d+/
          e.message.should match /char \d+/
        end
      end
    end
  end

  describe "#original_filename" do
    it "returns the correct value" do
      diff.original_filename.should == "Original"
    end
  end

  describe "#modified_filename" do
    it "returns the correct value" do
      diff.modified_filename.should == "Modified"
    end
  end

  describe "#original_revision" do
    it "returns the correct value" do
      diff.original_revision.should == "OrigRev"
    end
  end

  describe "#modified_revision" do
    it "returns the correct value" do
      diff.modified_revision.should == "ModRev"
    end
  end

  describe "#chunks" do
    it "returns the correct number of chunks" do
      diff.chunks.size.should == 3
    end
    it "returns chunk objects" do
      diff.chunks.each do |chunk|
        chunk.should be_a_kind_of Unified::Chunk
      end
    end
  end

  describe "#number_of_added_lines" do
    it "returns the correct value" do
      diff.number_of_added_lines.should == 3
    end
  end

  describe "#number_of_deleted_lines" do
    it "returns the correct value" do
      diff.number_of_deleted_lines.should == 3
    end
  end

  describe "#number_of_unchanged_lines" do
    it "returns the correct value" do
      diff.number_of_unchanged_lines.should == 3
    end
  end

  describe "#number_of_modified_lines" do
    it "returns the number of additions plus the number of deletions" do
      diff.number_of_modified_lines.should == 6
    end
  end

  describe "#total_number_of_lines" do
    it "returns the total number of lines" do
      diff.total_number_of_lines.should == 9
    end
  end

  describe "#proportion_of_deleted_lines" do
    it "returns 0 when there are no deleted lines" do
      lines = [" Line 1", "+Line 2"]
      diff(lines).proportion_of_deleted_lines.should == 0
    end

    it "returns 100 when there are only deleted lines" do
      lines = ["-Line 1", "-Line 2"]
      diff(lines).proportion_of_deleted_lines.should == 100
    end

    it "returns 50 when there are equal added and deleted lines" do
      lines = ["-Line 1", "+Line 2", " Line 3"]
      diff(lines).proportion_of_deleted_lines.should == 50
    end

    it "rounds to the nearest integer when the lines are not evenly divisible" do
      lines = ["-Line 1", "-Line 2", "+Line 3"]
      diff(lines).proportion_of_deleted_lines.should == 67
    end
  end

  describe "#proportion_of_added_lines" do
    it "returns 0 when there are no added lines" do
      lines = [" Line 1", "-Line 2"]
      diff(lines).proportion_of_added_lines.should == 0
    end

    it "returns 100 when there are only added lines" do
      lines = ["+Line 1", "+Line 2"]
      diff(lines).proportion_of_added_lines.should == 100
    end

    it "returns 50 when there are equal added and added lines" do
      lines = ["-Line 1", "+Line 2", " Line 3"]
      diff(lines).proportion_of_added_lines.should == 50
    end

    it "rounds to the nearest integer when the lines are not evenly divisible" do
      lines = ["-Line 1", "-Line 2", "+Line 3"]
      diff(lines).proportion_of_added_lines.should == 33
    end
  end

  describe "#each_chunk" do
    it "iterates once for every chunk" do
      index = 0
      diff.each_chunk do
        index += 1
      end

      index.should == 3
    end

    it "passes a chunk to the block" do
      diff.each_chunk do |chunk|
        expect(chunk).to be_a_kind_of Unified::Chunk
      end
    end
  end

  describe "#header" do
    it "returns a valid diff header" do
      diff.header.should == "--- Original\tOrigRev\n+++ Modified\tModRev"
    end
  end

  describe "#to_s" do
    it "returns the full diff output" do
      diff.to_s.should ==  <<-EOF.strip
--- Original\tOrigRev
+++ Modified\tModRev
@@ -1,2 +1,2 @@ A header
 Line 1
+Line 2
-Line 3
@@ -25,2 +25,2 @@ A header
 Line 1
+Line 2
-Line 3
@@ -50,2 +50,2 @@ A header
 Line 1
+Line 2
-Line 3
EOF
    end
  end
end