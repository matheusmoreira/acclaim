require 'acclaim/command'

module Test; end
class Test::Command < Acclaim::Command; end
class Test::Command::Subcommand < Test::Command; end

describe Acclaim::Command do

  describe Test::Command do
    subject { Test::Command }

    describe '::line' do
      context 'when not given a parameter' do
        it 'should return the default command name of the class' do
          subject.line.should == 'command'
        end
      end

      context 'when given a parameter' do
        let(:param) { 'test2' }
        before(:all) { subject.line param }
        after(:all) { subject.line nil } # Reset command name.

        it 'should set the command name of the class' do
          subject.line.should == param
        end
      end
    end

    describe '::subcommands' do
      it 'should not be empty' do
        subject.subcommands.should_not be_empty
      end

      it 'should include the subcommand' do
        subject.subcommands.should include(Test::Command::Subcommand)
      end
    end
  end

  describe Test::Command::Subcommand do
    subject { Test::Command::Subcommand }

    describe '::line' do
      context 'when not given a parameter' do
        it 'should return the default command name of the class' do
          subject.line.should == 'subcommand'
        end
      end

      context 'when given a parameter' do
        let(:param) { 'subcommand2' }
        before(:all) { subject.line param }
        after(:all) { subject.line nil } # Reset command name.

        it 'should set the command name of the class' do
          subject.line.should == param
        end
      end
    end

    describe '::subcommands' do
      it 'should be empty' do
        subject.subcommands.should be_empty
      end
    end
  end

end
