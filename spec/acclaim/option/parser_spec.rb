require 'acclaim/option'
require 'acclaim/option/parser'

describe Acclaim::Option::Parser do

  let!(:args)   { [] }
  let(:options) { nil }
  subject { Acclaim::Option::Parser.new(args, options) }

  context 'when given a long switch with a parameter separated by an equals sign' do

    let!(:args) { %w(--switch=PARAM) }

    describe '#parse!' do

      it 'should separate the switch from the single parameter' do
        subject.parse!
        args.should == %w(--switch PARAM)
      end

    end

  end

  context 'when given a long switch with multiple parameters separated by an equals sign' do

    let!(:args) { %w(--files FILE1 FILE2 FILE3) }

    describe '#parse!' do

      it 'should separate the switch and the parameters' do
        subject.parse!
        args.should == %w(--files FILE1 FILE2 FILE3)
      end

    end

  end

  describe '#parse!' do

    let!(:args) do
      %w(cmd -a subcmd -b PARAM1 -cdef PARAM2 --long --parameters PARAM3 PARAM4 PARAM5 -- FILE1 FILE2)
    end

    it 'should split multiple short options' do
      new_argv = args.dup.tap do |args|
        args[args.index('-cdef')] = %w[-c -d -e -f]
      end.flatten!
      subject.parse!
      args.should == new_argv
    end

    context 'when not given an array of options' do

      it 'should not return an options instance' do
        subject.parse!.should be_nil
      end

    end

    context 'when given an array of options' do

      let(:options) do
        [].tap do |opts|
          ('a'..'f').each do |c|
            hash = {}
            hash[:arity] = [1, 0] if c == 'b' or c == 'f'
            hash[:required] = true if c == 'd'
            opts << Acclaim::Option.new(c.to_sym, "-#{c}", hash)
          end
          opts << Acclaim::Option.new(:long, '--long')
          opts << Acclaim::Option.new(:params, '--parameters', arity: [1, 1], default: [])
        end
      end

      subject { Acclaim::Option::Parser.new(args, options) }

      it 'should return an options instance' do
        subject.parse!.should_not be_nil
      end

      it 'should parse arguments correctly' do
        subject.parse!.instance_eval do
          a?.should be_true
          b.should == 'PARAM1'
          c?.should be_true
          d?.should be_true
          e?.should be_true
          f.should == 'PARAM2'
          long?.should be_true
          params.should == %w(PARAM3 PARAM4)
        end
      end

      it 'should leave unparsed arguments in argv' do
        subject.parse!
        args.should == %w(cmd subcmd PARAM5 -- FILE1 FILE2)
      end

      context 'but not given a required parameter' do

        let!(:args) { %w(-db) }

        it 'should raise an error' do
          expect { subject.parse! }.to raise_error Acclaim::Option::Parser::Error,
                                                   /number of arguments/
        end

      end

      context 'but not passed a required option' do

        let!(:args) { [] }

        it 'should raise an error' do
          expect { subject.parse! }.to raise_error Acclaim::Option::Parser::Error,
                                                   /required/
        end

      end

    end

  end

end
