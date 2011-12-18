require 'acclaim/option/arity'

describe Acclaim::Option::Arity do

  subject { Acclaim::Option::Arity.new(required, optional) }

  context 'an arity that does not require any parameters' do
    let(:required) { 0 }
    let(:optional) { 0 }

    describe '#only?' do
      context 'when given zero' do
        it 'should return true' do
          subject.only?(0).should be_true
        end
      end

      context 'when given a non-zero number' do
        let(:number) { 1 }

        it 'should return false' do
          subject.only?(number).should be_false
        end
      end
    end

    describe '#unlimited?' do
      it 'should return false' do
        subject.unlimited?.should be_false
      end
    end

    describe '#bound?' do
      it 'should return true' do
        subject.bound?.should be_true
      end
    end

    describe '#total' do
      it 'should equal zero' do
        subject.total.should == 0
      end
    end

    context 'but allows five optional parameters' do
      let(:optional) { 5 }

      describe '#only?' do
        context 'when given the number of required parameters' do
          it 'should return false' do
            subject.only?(required).should be_false
          end
        end

        context 'when given a number other than the required number of parameters' do
          let(:number) { required + 10 }

          it 'should return false' do
            subject.only?(number).should be_false
          end
        end
      end

      describe '#unlimited?' do
        it 'should return false' do
          subject.unlimited?.should be_false
        end
      end

      describe '#bound?' do
        it 'should return true' do
          subject.bound?.should be_true
        end
      end

      describe '#total' do
        it 'should equal five' do
          subject.total.should == 5
        end
      end
    end

    context 'but allows for unlimited additional parameters' do
      let(:optional) { -1 }

      describe '#only?' do
        context 'when given the number of required parameters' do
          it 'should return false' do
            subject.only?(required).should be_false
          end
        end

        context 'when given a number other than the required number of parameters' do
          let(:number) { required + 10 }

          it 'should return false' do
            subject.only?(number).should be_false
          end
        end
      end

      describe '#unlimited?' do
        it 'should return true' do
          subject.unlimited?.should be_true
        end
      end

      describe '#bound?' do
        it 'should return false' do
          subject.bound?.should be_false
        end
      end

      describe '#total' do
        it 'should return nil' do
          subject.total.should be_nil
        end
      end
    end
  end

  context 'an arity which requires one parameter' do
    let(:required) { 1 }
    let(:optional) { 0 }

    describe '#only?' do
      context 'when given one' do
        it 'should return true' do
          subject.only?(required).should be_true
        end
      end

      context 'when given a number other than the required number of parameters' do
        let(:number) { required + 10 }
        it 'should return false' do
          subject.only?(number).should be_false
        end
      end
    end

    describe '#unlimited?' do
      it 'should return false' do
        subject.unlimited?.should be_false
      end
    end

    describe '#bound?' do
      it 'should return true' do
        subject.bound?.should be_true
      end
    end

    describe '#total' do
      it 'should equal one' do
        subject.total.should == 1
      end
    end

    context 'and allows for 4 additional parameters' do
      let(:optional) { 4 }

      describe '#only?' do
        context 'when given the number of required parameters' do
          it 'should return false' do
            subject.only?(required).should be_false
          end
        end

        context 'when given a number other than the required number of parameters' do
          let(:number) { required + 10 }

          it 'should return false' do
            subject.only?(number).should be_false
          end
        end
      end

      describe '#unlimited?' do
        it 'should return false' do
          subject.unlimited?.should be_false
        end
      end

      describe '#bound?' do
        it 'should return true' do
          subject.bound?.should be_true
        end
      end

      describe '#total' do
        it 'should equal five' do
          subject.total.should == 5
        end
      end
    end

    context 'and allows for unlimited additional parameters' do
      let(:optional) { -1 }

      describe '#only?' do
        context 'when given the number of required parameters' do
          it 'should return false' do
            subject.only?(required).should be_false
          end
        end

        context 'when given a number other than the required number of parameters' do
          let(:number) { required + 10 }

          it 'should return false' do
            subject.only?(number).should be_false
          end
        end
      end

      describe '#unlimited?' do
        it 'should return true' do
          subject.unlimited?.should be_true
        end
      end

      describe '#bound?' do
        it 'should return false' do
          subject.bound?.should be_false
        end
      end

      describe '#total' do
        it 'should return nil' do
          subject.total.should be_nil
        end
      end
    end
  end

end
