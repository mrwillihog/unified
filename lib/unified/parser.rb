require 'parslet'

module Unified
  class Parser < Parslet::Parser
    rule(:minus) { str('-') }
    rule(:plus) { str('+') }
    rule(:space) { str(' ') }
    rule(:space?) { str(' ').maybe }
    rule(:digit) { match['0-9'] }
    rule(:digits) { digit.repeat(1) }
    rule(:tab) { match['\\t'] }
    rule(:newline) { match['\\r'].maybe >> match['\\n'] }
    rule(:text_until_tab) { (tab.absent? >> newline.absent? >> any).repeat.as(:string) }
    rule(:rest_of_line) { (newline.absent? >> any).repeat }

    rule(:original_file_marker) { str('--- ') }
    rule(:modified_file_marker) { str('+++ ') }
    rule(:revision) { rest_of_line.as(:string) }
    rule(:header_information) { text_until_tab.as(:filename) >> (tab >> revision.as(:revision)).maybe }

    rule(:original_file_header) { original_file_marker >> header_information.as(:original) >> newline }
    rule(:modified_file_header) { modified_file_marker >> header_information.as(:modified) >> newline }

    rule(:chunk_marker) { str('@@') }
    rule(:line_numbers) do
      digits.as(:line_number) >> (str(',') >> digits).maybe
    end
    rule(:chunk_header) do
      chunk_marker >> space >>
      minus >> line_numbers.as(:original) >> space >>
      plus  >> line_numbers.as(:modified) >> space >>
      chunk_marker >> (space >> rest_of_line.as(:string).as(:section_heading)).maybe >>
      newline
    end

    rule(:added_line) { plus >> rest_of_line }
    rule(:deleted_line) { minus >> rest_of_line }
    rule(:unchanged_line) { space >> rest_of_line }
    rule(:no_newline_notice) { str('\\ No newline at end of file') }
    rule(:line) { (added_line | deleted_line | unchanged_line | no_newline_notice).as(:string) >> newline.maybe }

    rule(:chunk) do
      (chunk_header >> line.as(:line).repeat(1).as(:lines)).as(:chunk)
    end

    rule(:unified_diff_header) { original_file_header >> modified_file_header }
    rule(:unified_diff) do
      (unified_diff_header.as(:diff_header) >>
      chunk.repeat(1).as(:chunks)).as(:diff)
    end
    root(:unified_diff)
  end
end