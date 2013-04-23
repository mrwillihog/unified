module Unified
  class ParseError < StandardError; end
  class Diff

    attr_reader :original_filename
    attr_reader :modified_filename
    attr_reader :original_revision
    attr_reader :modified_revision
    attr_reader :chunks

    def initialize(attrs={})
      @original_filename = attrs[:original_filename]
      @modified_filename = attrs[:modified_filename]
      @original_revision = attrs[:original_revision]
      @modified_revision = attrs[:modified_revision]
      @chunks = attrs[:chunks]
    end

    def self.parse!(content)
      begin
        Unified::Transformer.new.apply(Unified::Parser.new.parse(content))
      rescue StandardError => e
        raise Unified::ParseError, e.message
      end
    end

    def total_number_of_lines
      @total_number_of_lines ||= number_of_added_lines + number_of_deleted_lines + number_of_unchanged_lines
    end

    def number_of_added_lines
      @number_of_added_lines ||= @chunks.inject(0) {|total, chunk| total + chunk.number_of_added_lines}
    end

    def number_of_deleted_lines
      @number_of_deleted_lines ||= @chunks.inject(0) {|total, chunk| total + chunk.number_of_deleted_lines}
    end

    def number_of_unchanged_lines
      @number_of_unchanged_lines ||= @chunks.inject(0) {|total, chunk| total + chunk.number_of_unchanged_lines}
    end

    def number_of_modified_lines
      @number_of_modified_lines ||= number_of_deleted_lines + number_of_added_lines
    end

    def proportion_of_deleted_lines
      @proportion_of_deleted_lines ||= ((100.0 * number_of_deleted_lines / number_of_modified_lines)).round
    end

    def proportion_of_added_lines
      @proportion_of_added_lines ||= 100 - proportion_of_deleted_lines
    end

    def header
      "--- #{@original_filename}\t#{@original_revision}\n+++ #{modified_filename}\t#{@modified_revision}"
    end

    def to_s
      str = [header]
      @chunks.each do |chunk|
        str << chunk.to_s
      end
      str.join("\n")
    end

    def each_chunk
      @chunks.each do |chunk|
        yield chunk
      end
    end

  end
end