require 'acclaim/command'

module Test; end
class Test::Command < Acclaim::Command; end
class Test::Command::Subcommand < Test::Command; end

describe Acclaim::Command do

  let(:root_command) { Test::Command }
  let(:subcommand) { Test::Command::Subcommand }

  describe Test::Command do
    subject { root_command }

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

    describe '::full_line' do
      context 'when not given any options' do
        it 'should return an empty string' do
          subject.full_line.should be_empty
        end
      end

      context 'when given an options hash' do
        context 'which specified that the root command should be excluded' do
          it 'should return an empty string' do
            subject.full_line(include_root: false).should be_empty
          end
        end

        context 'which specified that the root command should be included' do
          it "should return the command's name" do
            subject.full_line(include_root: true).should == 'command'
          end
        end
      end
    end

    describe '::root' do
      it 'should return this command' do
        subject.root.should == subject
      end
    end

    describe '::root?' do
      it 'should return true' do
        subject.root?.should be_true
      end
    end

    describe '::command_path' do
      it 'should return an array containing only the root command itself' do
        subject.command_path.should == [ subject ]
      end
    end

    describe '::command_ancestors' do
      it 'should return an array containing only the command itself' do
        subject.command_ancestors.should == [ subject ]
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
    subject { subcommand }

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

    describe '::full_line' do
      context 'when not given any options' do
        it "should return the command's name" do
          subject.full_line.should == 'subcommand'
        end
      end

      context 'when given an options hash' do
        context 'which specified that the root command should be excluded' do
          it "should return the command's name" do
            subject.full_line(include_root: false).should == 'subcommand'
          end
        end

        context 'which specified that the root command should be included' do
          it "should return the command's name prepended by the root command's name" do
            subject.full_line(include_root: true).should == 'command subcommand'
          end
        end
      end
    end

    describe '::root' do
      it 'should return the root command' do
        subject.root.should == root_command
      end
    end

    describe '::root?' do
      it 'should return false' do
        subject.root?.should be_false
      end
    end

    describe '::command_path' do
      it 'should return an array containing the root command and the subcommand, in order' do
        subject.command_path.should == [ root_command, subject ]
      end
    end

    describe '::command_ancestors' do
      it 'should return an array containing the command itself and the root command, in order' do
        subject.command_ancestors.should == [ subject, root_command ]
      end
    end

    describe '::subcommands' do
      it 'should be empty' do
        subject.subcommands.should be_empty
      end
    end
  end

end
