require 'acclaim/option'
require 'acclaim/option/parser'

describe Acclaim::Option::Parser do

  describe '#parse!' do

    let!(:args) do
      %w(cmd subcmd -a -b PARAM1 -cdef PARAM2 --long --parameters PARAM3 PARAM4 -- FILE1 FILE2)
    end

    subject { Acclaim::Option::Parser.new(args) }

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
            hash = { name: c, short: "-#{c}" }
            hash[:arity] = [1, 0] if c == 'b' or c == 'f'
            opts << Acclaim::Option.new(hash)
          end
          opts << Acclaim::Option.new(name: 'long', long: '--long')
          opts << Acclaim::Option.new(name: 'params', long: '--parameters',
                                      arity: [1, -1], default: [])
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
        args.should == %w(cmd subcmd -- FILE1 FILE2)
      end

    end

  end

end
