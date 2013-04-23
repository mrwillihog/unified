module Unified
  class Chunk

    attr_reader :original_line_number
    attr_reader :modified_line_number
    attr_reader :lines
    attr_reader :section_header

    def initialize(attrs = {})
      @original_line_number = attrs[:original]
      @modified_line_number = attrs[:modified]
      @section_header = attrs[:section_header]
      @lines = attrs[:lines].map {|s| Unified::Line.new(s) }
    end

    def total_number_of_lines
      @number_of_lines ||= @lines.size
    end

    def number_of_deleted_lines
      @number_of_added_lines ||= number_of_lines_by_type(:deletion?)
    end

    def number_of_added_lines
      @number_of_deleted_lines ||= number_of_lines_by_type(:addition?)
    end

    def number_of_unchanged_lines
      @number_of_unchanged_lines ||= number_of_lines_by_type(:unchanged?)
    end

    def number_of_original_lines
      @number_of_original_lines ||= number_of_unchanged_lines + number_of_deleted_lines
    end

    def number_of_modified_lines
      @number_of_modified_lines ||= number_of_unchanged_lines + number_of_added_lines
    end

    def header
      parts = "@@"
      parts << " -#{@original_line_number}"
      parts << ",#{number_of_original_lines}" unless number_of_original_lines == 1
      parts << " +#{@modified_line_number}"
      parts << ",#{number_of_modified_lines}" unless number_of_modified_lines == 1
      parts << " @@"
      parts << " #{@section_header}" unless @section_header.nil?
      parts
    end

    def to_s
      header + "\n" + @lines.join("\n")
    end

    # Iterator for lines passing |line, original_line_number, modified_line_number| as block arguments
    def each_line
      original_line_number = @original_line_number
      modified_line_number = @modified_line_number

      @lines.each do |line|
        if line.addition?
          yield line, nil, modified_line_number
          modified_line_number += 1
        elsif line.deletion?
          yield line, original_line_number, nil
          original_line_number += 1
        else
          yield line, original_line_number, modified_line_number
          original_line_number += 1
          modified_line_number += 1
        end
      end
    end

    def ==(another)
     @modified_line_number == another.modified_line_number and
     @original_line_number == another.original_line_number and
     @section_header == another.section_header and
     @lines = another.lines
    end

  private

    def number_of_lines_by_type(type)
      @lines.inject(0) {|total, line| line.send(type) ? total + 1 : total}
    end
  end
end