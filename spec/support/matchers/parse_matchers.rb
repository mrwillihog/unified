RSpec::Matchers.define :parse do |string_to_parse|
  match do |parser|
    begin
      parser.parse(string_to_parse)
    rescue Parslet::ParseFailed => e
      # @exception = e
      @exception = e.cause.ascii_tree
      false
    end
  end

  failure_message_for_should do |parser|
    @exception + "\n\n" + string_to_parse
  end
end

RSpec::Matchers.define :parse_empty_string do
  match do |parser|
    begin
      parser.parse("")
    rescue Parslet::ParseFailed => e
      @exception = e.cause.ascii_tree
      false
    end
  end
end

RSpec::Matchers.define :parse_all do |diffs|
  match do |parser|
    begin
      diffs.each do |diff|
        parser.parse(diff)
      end
    rescue Parslet::ParseFailed => e
      @exception = e.cause.ascii_tree
      false
    end
  end
end

# TODO Can you have aliases for RSpec matchers?
RSpec::Matchers.define :parse_any do |diffs|
  match do |parser|
    begin
      diffs.each do |diff|
        parser.parse(diff)
      end
    rescue Parslet::ParseFailed => e
      @exception = e.cause.ascii_tree
      false
    end
  end
end