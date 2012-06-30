require 'acclaim/option/parser/regexp'

describe Acclaim::Option::Parser::Regexp do

  # Generate one helper for each constant in the described module.
  described_class.constants.each do |constant|
    let(constant.to_s.downcase.to_sym) { described_class.const_get constant }
  end

  let(:short_option) { '-o' }
  let(:long_option) { '--option' }
  let(:multiple_short_options) { '-option' }
  let(:long_option_equals_sign) { '--option=' }
  let(:long_option_equals_sign_value) { '--option=VALUE' }
  let(:long_option_equals_sign_values) { '--option=VALUE1,VALUE2,VALUE3' }
  let(:long_option_equals_sign_comma_values) { '--option=,VALUE2,VALUE3' }
  let(:long_option_equals_sign_empty_commas) { '--option=,,' }
  let(:double_argument_separator) { '--' }
  let(:triple_argument_separator) { '---' }
  let(:long_option_with_separators) { '--my-option' }
  let(:short_option_underscore) { '-_' }
  let(:long_option_underscore) { '--_' }
  let(:multiple_short_options_underscore) { '-many_options' }
  let(:long_option_equals_sign_underscore) { '--my_option=' }
  let(:short_option_with_numbers) { '-5' }
  let(:multiple_short_options_with_numbers) { '-1234567890' }
  let(:long_option_equals_sign_and_numbers) { '--1234567890=' }
  let(:long_option_with_numbers) { '--1234567890' }

  describe 'SHORT_SWITCH' do
    it 'should match short options' do
      short_option.should match(short_switch)
    end

    it 'should not match long options' do
      long_option.should_not match(short_switch)
    end

    it 'should not match multiple short options' do
      multiple_short_options.should_not match(short_switch)
    end

    it 'should not match long options with an equals sign' do
      long_option_equals_sign.should_not match(short_switch)
    end

    it 'should not match a two-dash argument separator' do
      double_argument_separator.should_not match(short_switch)
    end

    it 'should not match a three-dash argument separator' do
      triple_argument_separator.should_not match(short_switch)
    end

    it 'should consider underscores as valid characters' do
      short_option_underscore.should match(short_switch)
    end

    it 'should not consider digits as valid characters' do
      short_option_with_numbers.should_not match(short_switch)
    end
  end

  describe 'LONG_SWITCH' do
    it 'should not match short options' do
      short_option.should_not match(long_switch)
    end

    it 'should match long options' do
      long_option.should match(long_switch)
    end

    it 'should not match multiple short options' do
      multiple_short_options.should_not match(long_switch)
    end

    it 'should not match long options with an equals sign' do
      long_option_equals_sign.should_not match(long_switch)
    end

    it 'should not match a two-dash argument separator' do
      double_argument_separator.should_not match(long_switch)
    end

    it 'should not match a three-dash argument separator' do
      triple_argument_separator.should_not match(long_switch)
    end

    it 'should consider underscores as valid characters' do
      long_option_underscore.should match(long_switch)
    end

    it 'should consider digits as valid characters' do
      long_option_with_numbers.should match(long_switch)
    end

    it 'should allow dashes as word separators' do
      long_option_with_separators.should match(long_switch)
    end
  end

  describe 'MULTIPLE_SHORT_SWITCHES' do
    it 'should not match short options' do
      short_option.should_not match(multiple_short_switches)
    end

    it 'should not match long options' do
      long_option.should_not match(multiple_short_switches)
    end

    it 'should match multiple short options' do
      multiple_short_options.should match(multiple_short_switches)
    end

    it 'should not match long options with an equals sign' do
      long_option_equals_sign.should_not match(multiple_short_switches)
    end

    it 'should not match a two-dash argument separator' do
      double_argument_separator.should_not match(multiple_short_switches)
    end

    it 'should not match a three-dash argument separator' do
      triple_argument_separator.should_not match(multiple_short_switches)
    end

    it 'should consider underscores as valid characters' do
      multiple_short_options_underscore.should match(multiple_short_switches)
    end

    it 'should not consider digits as valid characters' do
      multiple_short_options_with_numbers.should_not match(multiple_short_switches)
    end
  end

  describe 'SWITCH_PARAM_EQUALS' do
    it 'should not match short options' do
      short_option.should_not match(switch_param_equals)
    end

    it 'should not match long options' do
      long_option.should_not match(switch_param_equals)
    end

    it 'should not match multiple short options' do
      multiple_short_options.should_not match(switch_param_equals)
    end

    it 'should match long options with an equals sign' do
      long_option_equals_sign.should match(switch_param_equals)
    end

    it 'should not match a two-dash argument separator' do
      double_argument_separator.should_not match(switch_param_equals)
    end

    it 'should not match a three-dash argument separator' do
      triple_argument_separator.should_not match(switch_param_equals)
    end

    it 'should consider underscores as valid characters' do
      long_option_equals_sign_underscore.should match(switch_param_equals)
    end

    it 'should consider digits as valid characters' do
      long_option_equals_sign_and_numbers.should match(switch_param_equals)
    end

    it 'should match a long option with an equals sign followed by a value' do
      long_option_equals_sign_value.should match(switch_param_equals)
    end

    it 'should match a long option with an equals sign followed by comma-separated values' do
      long_option_equals_sign_values.should match(switch_param_equals)
    end

    it 'should match a long option with an equals sign with a comma before the values' do
      long_option_equals_sign_comma_values.should match(switch_param_equals)
    end

    it 'should match a long option with an equals sign followed by commas' do
      long_option_equals_sign_empty_commas.should match(switch_param_equals)
    end
  end

  describe 'SWITCH' do
    it 'should match short options' do
      short_option.should match(switch)
    end

    it 'should match long options' do
      long_option.should match(switch)
    end

    it 'should not match multiple short options' do
      multiple_short_options.should_not match(switch)
    end

    it 'should not match long options with an equals sign' do
      long_option_equals_sign.should_not match(switch)
    end

    it 'should not match a two-dash argument separator' do
      double_argument_separator.should_not match(switch)
    end

    it 'should not match a three-dash argument separator' do
      triple_argument_separator.should_not match(switch)
    end
  end

  describe 'ARGUMENT_SEPARATOR' do
    it 'should not match short options' do
      short_option.should_not match(argument_separator)
    end

    it 'should not match long options' do
      long_option.should_not match(argument_separator)
    end

    it 'should not match multiple short options' do
      multiple_short_options.should_not match(argument_separator)
    end

    it 'should not match long options with an equals sign' do
      long_option_equals_sign.should_not match(argument_separator)
    end

    it 'should match a two-dash argument separator' do
      double_argument_separator.should match(argument_separator)
    end

    it 'should match a three-dash argument separator' do
      triple_argument_separator.should match(argument_separator)
    end
  end

end
