require "unified/chunk"
require "unified/diff"
require "unified/line"

module Unified
  class Transformer < Parslet::Transform
    rule(:string => simple(:s)) { String(s) }
    rule(:line_number => simple(:n)) { Integer(n) }
    rule(:line => subtree(:line)) { Line.new line }
    rule(:chunk => subtree(:chunk)) { Chunk.new chunk }
    rule(:original => subtree(:original), :modified => subtree(:modified)) do
      {
        :original_filename => original[:filename],
        :modified_filename => modified[:filename],
        :original_revision => original[:revision],
        :modified_revision => modified[:revision]
      }
    end
    rule(:diff_header => subtree(:header), :chunks => subtree(:chunks)) do
      header[:chunks] = chunks
      header
    end
    rule(:diff => subtree(:d)) { Diff.new d }
  end
end