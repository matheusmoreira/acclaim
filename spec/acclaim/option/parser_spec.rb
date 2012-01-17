require 'acclaim/option'
require 'acclaim/option/parser'

describe Acclaim::Option::Parser do

  let!(:args)   { [] }
  let(:options) { nil }
  subject { Acclaim::Option::Parser.new(args, options) }

  describe '#parse!' do
    context 'when given a long switch with a parameter separated by an equals sign' do
      let!(:args) { %w(--switch=PARAM) }

      it 'should separate the switch from the single parameter' do
        subject.parse!
        args.should == %w(--switch PARAM)
      end
    end

    context 'when given a long switch with multiple parameters separated by an equals sign' do
      let!(:args) { %w(--files=FILE1,FILE2,FILE3) }

      it 'should separate the switch and the parameters' do
        subject.parse!
        args.should == %w(--files FILE1 FILE2 FILE3)
      end

      context 'but without a first parameter' do
        let!(:args) { %w(--files=,FILE2,FILE3) }

        it 'should treat the first parameter as if it was an empty string' do
          subject.parse!
          args.should == ['--files', '', 'FILE2', 'FILE3']
        end
      end
    end

    context 'when given a long switch with an equals sign' do
      context 'but no parameters' do
        let!(:args) { %w(--none=) }

        it 'should separate the switch from the empty parameter' do
          subject.parse!
          args.should == %w(--none)
        end
      end

      context 'but with a parameter list that consists of three commas' do
        let!(:args) { %w(--empty=,,,) }

        it 'should treat the parameters as if they were not there' do
          subject.parse!
          args.should == %w(--empty)
        end

        context 'and ends with a parameter' do
          let!(:args) { %w(--not-pretty=,,,PARAM4) }

          it 'should treat the first three parameters as if they were empty strings' do
            subject.parse!
            args.should == ['--not-pretty', '', '', '', 'PARAM4']
          end
        end
      end
    end

    context 'when given multiple combined short options' do
      let!(:args) { %w(-abcd) }

      it 'should split the combined option into multiple short options' do
        subject.parse!
        args.should == %w(-a -b -c -d)
      end
    end

    context 'when not given an array of options' do
      it 'should return an empty ribbon' do
        subject.parse!.should_not be_nil
      end
    end

    context 'when given an array of options' do
      let(:options) { [ Acclaim::Option.new(:option) ] }

      it 'should return option values' do
        subject.parse!.should_not be_nil
      end

      context 'containing a required option' do
        let(:options) { [ Acclaim::Option.new(:option, '-o', required: true) ] }

        context 'but not given the required switch' do
          let!(:args) { [] }

          it 'should raise an error' do
            expect { subject.parse! }.to raise_error Acclaim::Option::Parser::Error, /required/
          end
        end

        context 'and given the required switch' do
          let!(:args) { %w(-o) }

          it 'parse the value of the option correctly' do
            subject.parse!.option?.should be_true
          end
        end
      end

      context 'containing an option with a required parameter' do
        let(:options) { [ Acclaim::Option.new(:option, '-o', arity: [1,0]) ] }

        context "and not given the option's switch" do
          let!(:args) { [] }

          it 'should not raise an error' do
            expect { subject.parse! }.to_not raise_error Acclaim::Option::Parser::Error, /arguments/
          end
        end

        context "and given the option's switch" do
          context 'with a parameter' do
            let!(:args) { %w(-o PARAM) }

            it 'should not raise an error' do
              expect { subject.parse! }.to_not raise_error Acclaim::Option::Parser::Error, /arguments/
            end

            it 'should parse the value of the parameter correctly' do
              subject.parse!.option.should == 'PARAM'
            end
          end

          context 'without a parameter' do
            let!(:args) { %w(-o) }

            it 'should raise an error' do
              expect { subject.parse! }.to raise_error Acclaim::Option::Parser::Error, /arguments/
            end
          end
        end
      end

      context 'containing an option with an optional argument' do
        let(:options) { [ Acclaim::Option.new(:volume, '-V', arity: [0,1], default: 2) ] }

        context 'and not given the option a parameter' do
          let!(:args) { %w(-V) }

          it 'should not raise an error' do
            expect { subject.parse! }.to_not raise_error Acclaim::Option::Parser::Error, /arguments/
          end

          it 'should initialize the option to its default' do
            subject.parse!.volume.should == 2
          end
        end

        context 'and given the option a parameter' do
          let!(:args) { %w(-V 5) }

          it 'should not raise an error' do
            expect { subject.parse! }.to_not raise_error Acclaim::Option::Parser::Error, /arguments/
          end

          it 'should initialize the option to the value given' do
            subject.parse!.volume.should == '5'
          end
        end
      end

      context 'containing an option that requires at least one argument' do
        let(:options) { [ Acclaim::Option.new(:files, '--files', arity: [1,-1]) ] }

        context 'and not given the switch any arguments' do
          let!(:args) { %w(--files) }

          it 'should raise an error' do
            expect { subject.parse! }.to raise_error Acclaim::Option::Parser::Error, /arguments/
          end
        end

        context 'and given the switch three arguments' do
          let!(:args) { %w(--files FILE1 FILE2 FILE3) }

          it 'should not raise an error' do
            expect { subject.parse! }.to_not raise_error Acclaim::Option::Parser::Error, /arguments/
          end

          it 'should initialize the option to the values given' do
            subject.parse!.files.should == %w(FILE1 FILE2 FILE3)
          end

          context 'among other arguments and commands' do
            let!(:args) { %w(cmd subcmd --files FILE1 FILE2 -- ARG1 ARG2) }

            it 'should ignore the other arguments and leave them where they are' do
              subject.parse!
              args.should == %w(cmd subcmd -- ARG1 ARG2)
            end
          end
        end
      end

      context 'containing an option which' do
        let!(:options) { [ Acclaim::Option.new(:files, '-f', arity: [1,0], on_multiple: on_multiple, &block) ] }
        let!(:args) { %w(-f f1 -f f2 -f f3) }
        let(:block) { nil }

        context 'replaces the previously found value' do
          let(:on_multiple) { :replace }

          it 'should replace the value with the last argument found' do
            subject.parse!.files.should == 'f3'
          end
        end

        context 'appends to the previously found values' do
          let(:on_multiple) { :append }

          it 'should return all arguments' do
            subject.parse!.files.should == %w(f1 f2 f3)
          end

          context 'but that was passed a handler block' do
            let(:block) { proc { |values| values.files = :block } }

            it 'should parse all options and arguments' do
              subject.parse!
              args.should be_empty
            end

            it "should use the handler to obtain the option's value" do
              subject.parse!.files.should == :block
            end
          end
        end

        context 'raises an error if encountered multiple times' do
          let(:on_multiple) { :raise }

          it 'should raise a parser error' do
            expect { subject.parse! }.to raise_error Acclaim::Option::Parser::Error, /multiple/i
          end
        end
      end
    end
  end

end
