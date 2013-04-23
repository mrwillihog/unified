require 'unified/line'

describe "Unified::Line" do
  it "extends from String" do
    line = Unified::Line.new "A line"
    line.should respond_to(:gsub)
    line.should respond_to(:size)
  end

  context "additional methods" do
    let(:addition) { Unified::Line.new "+An addition" }
    let(:deletion) { Unified::Line.new "-A deletion" }
    let(:unchanged) { Unified::Line.new " Unchanged" }

    describe "#addition?" do
      it "is true when a line begins with '+'" do
        addition.addition?.should be_true
      end
      it "is false when a line doesn't begin with '-'" do
        deletion.addition?.should be_false
        unchanged.addition?.should be_false
      end
    end

    describe "#deletion?" do
      it "is true when a line begins with '-'" do
        deletion.deletion?.should be_true
      end
      it "is false when a line doesn't begin with '-'" do
        addition.deletion?.should be_false
        unchanged.deletion?.should be_false
      end
    end

    describe "#unchanged?" do
      it "is true when a line begins with ' '" do
        unchanged.unchanged?.should be_true
      end
      it "is false when a line doesn't begin with ' '" do
        addition.unchanged?.should be_false
        deletion.unchanged?.should be_false
      end
    end
  end
end