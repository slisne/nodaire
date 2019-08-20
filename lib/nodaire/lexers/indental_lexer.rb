# frozen_string_literal: true

require_relative 'lexer'

class Nodaire::Indental
  # @private
  class Lexer < Nodaire::Lexer
    Token = Struct.new(:type, :key, :value, :line_num)

    def self.tokenize(source)
      lines_with_number(strip_js_wrapper(source))
        .reject { |line, _| line.match(/^\s*(;.*)?$/) }
        .map { |line, num| token_for_line(line, num) }
    end

    def self.token_for_line(line, num)
      case line.match(/^\s*/)[0].size
      when 0 then category_token(line, num)
      when 2 then key_or_list_token(line, num)
      when 4 then list_item_token(line, num)
      else error_token('Unexpected indent', num)
      end
    end

    def self.category_token(string, line_num)
      Token.new :category, normalize(string), nil, line_num
    end

    def self.key_or_list_token(string, line_num)
      if string.include?(' : ')
        key, value = string.split(' : ', 2)
        Token.new :key_value, normalize(key), normalize(value), line_num
      else
        Token.new :list_name, normalize(string), nil, line_num
      end
    end

    def self.list_item_token(string, line_num)
      Token.new :list_item, nil, normalize(string), line_num
    end

    def self.error_token(message, line_num)
      Token.new :error, nil, normalize(message), line_num
    end

    def self.normalize(input)
      collapse_spaces(input)
    end
  end
end
