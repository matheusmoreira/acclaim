require 'acclaim/option'

describe Acclaim::Option do

  describe '#initialize' do

    context 'when given multiple strings' do

      let(:switches) { %w(-s --switch) }
      let(:description) { 'Description' }
      subject { Acclaim::Option.new :key, *[switches, description].flatten }

      it 'should find the switches' do
        subject.names.should == switches
      end

      it 'should find the description' do
        subject.description.should == description
      end

    end

    context 'when given a class' do

      let(:type) { Integer }
      subject { Acclaim::Option.new :key, type }

      it "should use it as the option's type" do
        subject.type.should == type
      end

    end

  end

end
