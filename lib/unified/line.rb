module Unified
  class Line < String

    def addition?
      @addition ||= first_character == "+"
    end

    def deletion?
      @deletion ||= first_character == "-"
    end

    def unchanged?
      @unchanged ||= first_character == " "
    end

  private
    def first_character
      @first_character ||= self[0]
    end
  end
end