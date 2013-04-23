require "unified/parser"
require "spec_helper"

# Hashes used to validate captures
header_without_revision = {
  :filename => {:string => "Filename"},
}
header_with_revision = {
  :revision => {:string => "revision"}
}.merge(header_without_revision)

original_file_header = {
  :original => header_with_revision
}

modified_file_header = {
  :modified => header_with_revision
}

describe "Unified::Parser" do
  let(:parser) { Unified::Parser.new }
  subject { parser }

  it { should parse_all valid_diffs }
  it { should_not parse_any invalid_diffs }

  describe "#minus" do
    subject { parser.minus }

    it { should parse "-" }
    it { should_not parse_empty_string }
    it { should_not parse "+" }
  end

  describe "#plus" do
    subject { parser.plus }

    it { should parse "+" }
    it { should_not parse_empty_string }
    it { should_not parse "-" }
  end

  describe "#digit" do
    subject { parser.digit }

    it { should parse "9" }
    it { should parse "0" }

    it { should_not parse "a" }
    it { should_not parse_empty_string }
    it { should_not parse "2141" }
  end

  describe "#digits" do
    subject { parser.digits }

    it { should parse "123" }
    it { should parse "1" }
    it { should_not parse "a" }
    it { should_not parse_empty_string }

  end

  describe "#space" do
    subject { parser.space }

    it { should parse " " }
    it { should parse "\s" }
    it { should_not parse_empty_string }
    it { should_not parse "some content"}
    it { should_not parse "   " }
    it { should_not parse "\t" }
  end

  describe "#space?" do
    subject { parser.space? }

    it { should parse " " }
    it { should parse_empty_string }
    it { should_not parse "a" }
    it { should_not parse "  " }
  end

  describe "#tab" do
    subject { parser.tab }

    it { should parse "\t" }
    it { should_not parse " " }
  end

  describe "#newline" do
    subject { parser.newline }

    it { should parse "\n" }
    it { should parse "\r\n" }

    it { should_not parse_empty_string }
    it { should_not parse "\n\n" }
  end

  describe "#rest_of_line" do
    subject { parser.rest_of_line }

    it { should parse "a long string of content" }
    it { should parse "strings with\t(special_characters)" }
    it { should parse_empty_string }
    it { should_not parse "strings ending with a newline\n" }
  end

  describe "#text_until_tab" do
    subject { parser.text_until_tab }

    it { should parse "a string with names in" }
    it { should_not parse "a string with a tab\t" }

    it "should capture filename as {:string => 'filename'}" do
      expect(subject.parse("String until tab")).to eq :string => "String until tab"
    end
  end

  describe "#header_information" do
    subject { parser.header_information }

    it { should parse "This/is/a/filename" }
    it { should parse "Filename" }
    it { should parse "Filename\trevision" }

    it "should capture header as {:filename => 'filename', :revision => 'revision'}" do


      expect(subject.parse("Filename")).to eq header_without_revision
      expect(subject.parse("Filename\trevision")).to eq header_with_revision
    end
  end

  describe "#original_file_marker" do
    subject { parser.original_file_marker }

    it { should parse "--- " }
    it { should_not parse_empty_string }
    it { should_not parse "-- " }
    it { should_not parse "---" }
    it { should_not parse "---- " }
  end

  describe "#modified_file_marker" do
    subject { parser.modified_file_marker }

    it { should parse "+++ " }
    it { should_not parse_empty_string }
    it { should_not parse "++ " }
    it { should_not parse "+++" }
    it { should_not parse "++++ " }
  end

  describe "#original_file_header" do
    subject { parser.original_file_header }

    it { should parse "--- Filename\t2002-02-21 23:30:39.942229878 -0800\n" }
    it { should parse "--- Filename\t2002-02-21 23:30:39.942229878 -0800\r\n" }
    it { should parse "--- Filename\t(working copy)\n" }
    it { should parse "--- Filename\t(working copy)\r\n" }
    it { should parse "--- Filename\n" }

    it { should_not parse "--- Filename\t(working copy)"}

    it "should capture all header information" do
      expect(subject.parse("--- Filename\trevision\n")).to eq original_file_header
    end
  end

  describe "#modified_file_header" do
    subject { parser.modified_file_header }

    it { should parse "+++ Filename\t2002-02-21 23:30:39.942229878 -0800\n" }
    it { should parse "+++ Filename\t2002-02-21 23:30:39.942229878 -0800\r\n" }
    it { should parse "+++ Filename\t(working copy)\n" }
    it { should parse "+++ Filename\t(working copy)\r\n" }
    it { should parse "+++ Filename\n"}

    it { should_not parse "+++ Filename\t(working copy)"}

    it "should capture all header information" do
      expect(subject.parse("+++ Filename\trevision\n")).to eq modified_file_header
    end
  end

  describe "#chunk_marker" do
    subject { parser.chunk_marker }

    it { should parse "@@" }
    it { should_not parse "@" }
    it { should_not parse " @@" }
    it { should_not parse "@@ " }
  end

  describe "#line_numbers" do
    subject { parser.line_numbers }

    it { should parse "1" }
    it { should parse "1,5" }
    it { should parse "101,101" }

    it "captures line numbers as {:line_number => 'digits'}" do
      expect(subject.parse("1,5")).to eq :line_number => "1"
      expect(subject.parse("101,101")).to eq :line_number => "101"
      expect(subject.parse("1")).to eq :line_number => "1"
    end
  end

  describe "#chunk_header" do
    subject { parser.chunk_header }

    it { should parse "@@ -1 +1 @@\n" }
    it { should parse "@@ -1,5 +1,5 @@\n" }
    it { should parse "@@ -101,15 +102,14 @@ Some optional heading\n" }

    it "captures all required information" do
      expect(subject.parse("@@ -1 +1 @@\n")).to eq({
        :original => {
          :line_number => "1"
        },
        :modified => {
          :line_number => "1"
        }
      })

      expect(subject.parse("@@ -101,15 +102,14 @@ Some optional heading\n")).to eq({
        :original => {
          :line_number => "101"
        },
        :modified => {
          :line_number => "102"
        },
        :section_heading => { string: "Some optional heading" }
      })
    end
  end

  describe "#added_line" do
    subject { parser.added_line }

    it { should parse "+This is an additional line" }
    it { should_not parse " +This is not a valid additional line" }
    it { should parse "+++Even though this looks like a header, it should parse" }
  end

  describe "#deleted_line" do
    subject { parser.deleted_line }

    it { should parse "-This is a deleted line" }
    it { should_not parse " -This is not a valid deleted line" }
    it { should parse "---Even though this looks like a header, it should parse" }
  end

  describe "#unchanged_line" do
    subject { parser.unchanged_line }

    it { should parse " this line is unchanged" }
    it { should_not parse "This has no leading space" }
    it { should_not parse_empty_string }
  end

  describe "#no_newline_notice" do
    subject { parser.no_newline_notice }

    it { should parse "\\ No newline at end of file" }
  end

  describe "#line" do
    subject { parser.line }

    it { should parse "+This is an additional line" }
    it { should parse "-This is a deleted line" }
    it { should parse " this line is unchanged" }
    it { should parse "\\ No newline at end of file" }

    it "captures all line content as {:string => 'content'}" do
      expect(subject.parse("+This is an additional line")).to eq :string => "+This is an additional line"
      expect(subject.parse("-This is a deleted line")).to eq :string => "-This is a deleted line"
      expect(subject.parse(" this line is unchanged")).to eq :string => " this line is unchanged"
      expect(subject.parse("\\ No newline at end of file")).to eq :string => "\\ No newline at end of file"
    end
  end

  describe "#chunk" do
    subject { parser.chunk }
    valid_chunk = "@@ -1 +1 @@\n+addition\n-deletion\n no change"
    a_chunk_with_no_lines = "@@ -1 +1 @@\n"
    a_chunk_with_no_header = "+addition\n-deletion\n no change"

    it { should parse valid_chunk }
    it { should_not parse a_chunk_with_no_lines }
    it { should_not parse a_chunk_with_no_header }

    context "captures" do
      let(:capture) { subject.parse valid_chunk }
      it "captures as chunk" do
        capture.should include :chunk
      end

      it "captures lines" do
        capture[:chunk].should include :lines
        capture[:chunk][:lines].size.should == 3
        capture[:chunk][:lines].each do |line|
          line.should include :line
        end
      end
    end

  end

  describe "#unified_diff_header" do
    subject { parser.unified_diff_header }

    it { should parse "--- Filename\n+++ Filename\n" }
    it { should_not parse "--- Missing header\n" }
    it { should_not parse "\n+++ Missing header\n"}
  end

  describe "#unified_diff" do
    subject { parser.unified_diff }

    it { should parse valid_diffs.first }
    it { should_not parse invalid_diffs.first }

    context "capturing all necessary information" do
      let(:result) { subject.parse valid_diffs.first }

      it "captures as a diff hash" do
        result.should include(:diff)
      end

      it "captures a diff header" do
        result[:diff].should include(:diff_header)
      end

      it "captures chunks" do
        result[:diff].should include(:chunks)
        result[:diff][:chunks].size.should == 1
      end
    end
  end
end