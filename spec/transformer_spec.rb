require "unified/transformer"
require "spec_helper"



describe "Unified::Transformer" do
  def lines
    [" Line 1", " Line 2", " Line 3", "-Line 5", "-Line 6", "-Line 7", "+Line 4", "+Line 5"]
  end

  def build_chunk_hash(original_line_number = 1, modified_line_number = 1, header = nil)
    {:chunk=>{:original=>original_line_number, :modified=>modified_line_number, :section_heading=>header, :lines=>lines}}
  end
  let(:transformer) { Unified::Transformer.new }

  context "simple values" do
    it "transforms a string value" do
      expect(transformer.apply({:string => "a string"})).to eq("a string")
    end
  end

  context "Lines" do
    it "transforms a line into a Unified::Line object" do
      expect(transformer.apply({:line => {:string => "+A line"}})).to eq(Unified::Line.new("+A line"))
    end
  end

  context "Chunks" do
    let(:chunk) { build_chunk_hash }
    it "transforms a chunk into a Unified::Chunk object" do
      expect(transformer.apply(chunk)).to eq(Unified::Chunk.new(original: 1, modified: 1, section_heading: "A section heading", lines: lines))
    end
  end

  describe "Diff header" do
    let(:header) { {:original=>{:filename=>"Original", :revision=>"OrigRev"}, :modified=>{:filename=>"Modified", :revision=>"ModRev"}} }
    it "transforms a diff header into filenames and revisions" do
      expect(transformer.apply(header)).to eq({
        original_filename: "Original",
        modified_filename: "Modified",
        original_revision: "OrigRev",
        modified_revision: "ModRev"
      })
    end
  end

  # context "Diffs" do
  #   let(:chunks) { [build_chunk_hash, build_chunk_hash(101, 101)] }
  #   let(:diff_hash) do
  #     {
  #       :diff => {
  #         :diff_header => {
  #           :original => {
  #             :filename=>"Original",
  #             :revision=>"OriginalRevision"
  #           },
  #           :modified => {
  #             :filename=>"Modified",
  #             :revision=>"ModifiedRevision"
  #           }
  #         },
  #         :chunks => chunks
  #       }
  #     }
  #   end
  #   let(:diff) {
  #     Unified::Diff.new(
  #       original_filename: "Original",
  #       original_revision: "OriginalRevision",
  #       modified_filename: "Modified",
  #       modified_revision: "ModifiedRevision",
  #       chunks: [
  #         Unified::Chunk.new(original: 1, modified: 1, lines: lines),
  #         Unified::Chunk.new(original: 101, modified: 101, lines: lines)
  #       ]
  #     )
  #   }
  #   it "transforms a diff into a Unified::Diff object" do
  #     expect(transformer.apply(diff_hash)).to eq(diff)
  #   end
  # end
end