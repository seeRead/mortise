require "mortise/version"
require "mortise/checker"
require "mortise/issue"
require "mortise/errors"
require 'cgi'

module Mortise
  TENON_APP_ID = '490866e2ad3b501842cef0569e4c0ee0'

  def self.check(url, key, options = {})
    Mortise::Checker.new(url, key, options)
  end

  class BeAccessibleMarkup

    #rspec 
    def matches?(fragment)
      #get the html
      if fragment.respond_to? :source
        fragment = fragment.source.to_s
      elsif fragment.respond_to? :body
        fragment = fragment.body.to_s
      end

      @message = ''
      @checker = Mortise.check(fragment, ENV['TENON_KEY'])
      return is_accessible
    end

    def description
      "be accessible markup"
    end

    def failure_message
      " expected markup to be accessible, but validation produced these errors:\n#{@message}"
    end

    def failure_message_when_negated
      " expected to not be accessible, but was (missing validation?)"
    end

    # continue to support Rspec < 3
    alias :negative_failure_message :failure_message_when_negated

    def is_accessible
      if @checker.issues.count == 0
        return true
      else
        puts @checker.raw
        str =""
        @checker.issues.each do |i|
          str += "Line "
          str += i.position["line"].to_s
          str += ": "
          str += i.error_title
          str += "\n\n"
          str += CGI.unescapeHTML(i.error_snippet)
          str += "\n\n"
          str += i.error_description
          str += "\n---\n\n"
        end
        @message = str
        return false
      end
    end
  end

  def be_accessible_markup
    BeAccessibleMarkup.new
  end
end
