require 'acclaim/option'
require 'date'
require 'time'
require 'uri'

describe Acclaim::Option do

  let(:key) { :key }
  let(:args) { [] }
  let(:block) { nil }
  subject { Acclaim::Option.new key, *args, &block }

  describe '#initialize' do
    it 'should use the given key' do
      subject.key.should == key
    end

    context 'when given multiple switches' do
      let(:switches) { %w(-s --switch) }

      context 'directly' do
        let(:args) { [*switches] }

        it 'should find the switches' do
          subject.names.should == switches
        end
      end

      context 'as an array' do
        let(:args) { [switches] }

        it 'should find the switches' do
          subject.names.should == switches
        end
      end
    end

    context 'when given a description string' do
      let(:description) { 'Description' }

      context 'by itself' do
        let(:args) { [description] }

        it 'should find the description' do
          subject.description.should == description
        end
      end

      context 'with another description specified in the options hash' do
        let(:description_from_options_hash) { 'Description from options hash' }
        let(:options_hash) { { description: description_from_options_hash } }
        let(:args) { [description, options_hash] }

        it 'should use the description from the options hash' do
          subject.description.should == description_from_options_hash
        end
      end
    end

    context 'when not given a class' do
      it "should use String as the option's type" do
        subject.type.should == String
      end
    end

    context 'when given a class' do
      let(:type) { Integer }
      let(:args) { [type] }

      it "should use it as the option's type" do
        subject.type.should == type
      end
    end

    context 'when given an additional parameter hash' do
      let(:hash) { {} }
      let(:args) { [hash] }

      context 'that does not specify an arity' do
        it 'should be a flag' do
          subject.should be_flag
        end
      end

      context 'that specifies an arity' do
        let(:hash) { { arity: arity } }

        context 'which requires one argument' do
          let(:arity) { Acclaim::Option::Arity.new 1 }

          it 'should not be a flag' do
            subject.should_not be_flag
          end
        end

        context 'which allows one optional argument' do
          let(:arity) { Acclaim::Option::Arity.new 0, 1 }

          it 'should not be a flag' do
            subject.should_not be_flag
          end
        end
      end

      context 'that does not specify a default value' do
        it 'should have a default value of nil' do
          subject.default.should be_nil
        end
      end

      context 'that specifies a default value' do
        let(:default) { 10 }
        let(:hash) { { default: default } }

        it 'should use the default value supplied' do
          subject.default.should == default
        end
      end

      context 'that does not specify whether the option is required' do
        it 'should not be required' do
          subject.should_not be_required
        end
      end

      context 'that specifies if the option is required' do
        let(:hash) { { required: required } }

        context 'as false' do
          let(:required) { false }

          it 'should not be required' do
            subject.should_not be_required
          end
        end

        context 'as true' do
          let(:required) { true }

          it 'should be required' do
            subject.should be_required
          end
        end
      end

      context 'that specifies a description' do
        let(:hash) { { description: description } }

        context 'as a regular string' do
          let(:description) { 'Description' }

          it 'should use the string as the description' do
            subject.description.should == description
          end
        end

        context 'as a block' do
          let(:description) { -> { 'Description' } }

          it 'should call the block and use return value as the description' do
            value = description.call
            subject.description.should == value
          end
        end
      end
    end

    context 'when not given a block' do
      it 'should not have a custom handler' do
        subject.handler.should be_nil
      end
    end

    context 'when given a block' do
      let(:block) { proc { |*args| p args } }

      it 'should have a custom handler' do
        subject.handler.should respond_to(:call)
      end
    end
  end

  describe '#convert_parameters' do
    let(:args) { [type].compact }
    let!(:converted) { subject.convert_parameters *params }

    context 'when the option was not explicitly initialized with a type' do
      let(:type) { nil }
      let!(:params) { %w(a b c d) }

      it 'should convert the parameters to strings' do
        converted.should == params
      end
    end

    context 'when the option was initialized with String as its type' do
      let(:type) { String }
      let(:params) { %w(a b c d) }

      it 'should convert the parameters to strings' do
        converted.should == params
      end
    end

    context 'when the option was initialized with Symbol as its type' do
      let(:type) { Symbol }
      let(:params) { %w(a b c d) }

      it 'should convert the parameters to symbols' do
        converted.should == params.map(&:to_sym)
      end
    end

    context 'when the option was initialized with Date as its type' do
      let(:type) { Date }
      let(:date) { type.today }
      let(:params) { [date.to_s] }

      it 'should convert the parameters to dates' do
        converted.should == [date]
      end
    end

    context 'when the option was initialized with DateTime as its type' do
      let(:type) { DateTime }
      let(:date_time) { type.parse type.now.to_s }
      let(:params) { [date_time.to_s] }

      it 'should convert the parameters to dates/times' do
        converted.should == [date_time]
      end
    end

    context 'when the option was initialized with Time as its type' do
      let(:type) { Time }
      let(:time) { type.parse type.now.to_s }
      let(:params) { [time.to_s] }

      it 'should convert the parameters to times' do
        converted.should == [time]
      end
    end

    context 'when the option was initialized with URI as its type' do
      let(:type) { URI }
      let(:uri) { type.parse 'https://github.com/matheusmoreira/acclaim' }
      let(:params) { [uri.to_s] }

      it 'should convert the parameters to URIs' do
        converted.should == [uri]
      end
    end
  end

  describe '#=~' do
    let(:names) { %w(-o -a --option --alternative) }
    let(:args) { names }

    context "when passed the option's short switch" do
      let(:str) { '-o' }

      it 'should match' do
        (subject =~ str).should be_true
      end
    end

    context "when passed the option's alternative short switch" do
      let(:str) { '-a' }

      it 'should match' do
        (subject =~ str).should be_true
      end
    end

    context "when passed a different short switch" do
      let(:str) { '-d' }

      it 'should not match' do
        (subject =~ str).should be_false
      end
    end

    context "when passed the option's long switch" do
      let(:str) { '--option' }

      it 'should match' do
        (subject =~ str).should be_true
      end
    end

    context "when passed the option's alternative long switch" do
      let(:str) { '--alternative' }

      it 'should match' do
        (subject =~ str).should be_true
      end
    end

    context "when passed a different long switch" do
      let(:str) { '--different' }

      it 'should not match' do
        (subject =~ str).should be_false
      end
    end
  end

  describe '#arity' do
    context 'when the option was not explicitly initialized with an arity' do
      it 'should not return nil' do
        subject.arity.should_not be_nil
      end
    end
  end

  describe '#arity=' do
    before(:each) { begin subject.arity = arg; rescue; end }

    context 'when passed nil' do
      let(:arg) { nil }

      it "the option's arity should not be set to nil" do
        subject.arity.should_not be_nil
      end
    end

    context 'when passed an arity' do
      let(:arg) { Acclaim::Option::Arity.new 5, -1 }

      it "should set the option's arity" do
        subject.arity.should == arg
      end
    end

    context 'when passed an array' do
      let(:arg) { [ 5, -1 ] }

      it "should use the array to create the option's arity" do
        subject.arity.should == Acclaim::Option::Arity.new(5, -1)
      end
    end

    context 'when passed an invalid array' do
      let(:arg) { [ 5, -1, 99 ] }

      it 'should raise an argument error' do
        expect { subject.arity = arg }.to raise_error ArgumentError
      end
    end
  end

  describe '#require' do
    before(:each) { subject.require }

    it 'should make the option mandatory' do
      subject.should be_required
    end
  end

end
