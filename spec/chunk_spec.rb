require "unified/chunk"

describe "Unified::Chunk" do
  let(:lines) { [" Line 1", "+Line 2", "-Line 3", "+Line4", "-Line5", " Line6"] }
  let(:chunk_without_section_header) { Unified::Chunk.new original: 1, modified: 2, lines: lines }
  let(:chunk) { Unified::Chunk.new original: 1, modified: 2, lines: lines, section_header: "A section header" }
  describe "#original_line_number" do
    it "returns the correct number" do
      chunk.original_line_number.should == 1
    end
  end
  describe "#modified_line_number" do
    it "returns the correct number" do
      chunk.modified_line_number.should == 2
    end
  end

  describe "#total_number_of_lines" do
    it "returns the number of lines" do
      chunk.total_number_of_lines.should == lines.length
    end
  end

  describe "#number_of_deleted_lines" do
    it "returns the number of lines beginning with '-'" do
      chunk.number_of_deleted_lines.should == 2
    end
  end

  describe "#number_of_added_lines" do
    it "returns the number of lines beginning with '+'" do
      chunk.number_of_added_lines.should == 2
    end
  end

  describe "#number_of_unchanged_lines" do
    it "returns the number of lines beginning with ' '" do
      chunk.number_of_unchanged_lines.should == 2
    end
  end

  describe "#number_of_original_lines" do
    it "returns the number of lines within the original chunk" do
      chunk.number_of_original_lines.should == 4
    end
  end

  describe "#number_of_modified_lines" do
    it "returns the number of lines within the modified chunk" do
      chunk.number_of_modified_lines.should == 4
    end
  end

  describe "#section_heading" do
    it "returns nil when not provided" do
      chunk_without_section_header.section_header.should be_nil
    end
    it "returns the correct value when it is provided" do
      chunk.section_header.should == "A section header"
    end
  end

  describe "#each_line" do
    it "iterates over each line" do
      count = 0
      chunk.each_line do |line|
        count += 1
      end

      expect(count).to eq lines.length
    end

    it "passes the line as block argument" do
      index = 0
      chunk.each_line do |line|
        expect(line).to be_a_kind_of Unified::Line
        line.should == lines[index]
        index += 1
      end
    end

    it "passes the original line number as a block argument" do
      expected_line_numbers = [1, nil, 2, nil, 3, 4]
      index = 0
      chunk.each_line do |line, original_line_number|
        original_line_number.should == expected_line_numbers[index]
        index += 1
      end
    end

    it "passes the modified line number as a block argument" do
      expected_line_numbers = [2, 3, nil, 4, nil, 5]
      index = 0
      chunk.each_line do |line, original_line_number, modified_line_number|
        modified_line_number.should == expected_line_numbers[index]
        index += 1
      end
    end

    it "does not pass line numbers for the no newline warning" do
      no_newline_chunk = Unified::Chunk.new original: 1, modified: 1, lines: [" Line 1", "\\ No newline at end of file"]
      index = 0
      no_newline_chunk.each_line do |line, original_line_number, modified_line_number|
        if index == 1
          original_line_number.should be_nil
          modified_line_number.should be_nil
        end
        index += 1
      end
    end
  end

  describe "#==" do
    it "returns true when both line numbers and all lines are equal" do
      another_chunk = Unified::Chunk.new original: 1, modified: 2, lines: lines, section_header: "A section header"
      chunk.should == another_chunk
    end
  end

  describe "#header" do
    it "returns a valid chunk header" do
      chunk_without_section_header.header.should == "@@ -1,4 +2,4 @@"
    end
    it "returns a valid chunk header with section heading" do
      chunk.header.should == "@@ -1,4 +2,4 @@ A section header"
    end
    it "does not display number of lines if it is 1" do
      chunk = Unified::Chunk.new original: 1, modified: 1, lines: [" Line 1"]
      chunk.header.should == "@@ -1 +1 @@"
    end
  end

  describe "#to_s" do
    it "outputs the chunk header followed by each line" do
      chunk.to_s.should == <<-EOF.strip
@@ -1,4 +2,4 @@ A section header
 Line 1
+Line 2
-Line 3
+Line4
-Line5
 Line6
EOF
    end
  end
end