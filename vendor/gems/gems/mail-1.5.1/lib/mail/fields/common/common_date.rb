# encoding: utf-8
module Mail
  module CommonDate # :nodoc:
    
    module InstanceMethods # :doc:
      
      # Returns a date time object of the parsed date
      def date_time
        ::DateTime.parse("#{element.date_string} #{element.time_string}")
      end

      def default
        date_time
      end

      private
      
      def do_encode(field_name)
        "#{field_name}: #{value}\r\n"
      end
      
      def do_decode
        "#{value}"
      end

      def element
        @element ||= Mail::DateTimeElement.new(value)
      end
      
      # Returns the syntax tree of the Date
      def tree
        @tree ||= element.tree
      end
      
    end
    
    def self.included(receiver) # :nodoc:
      receiver.send :include, InstanceMethods
    end
    
  end
end