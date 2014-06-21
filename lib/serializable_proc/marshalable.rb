require "base64"

class SerializableProc
  module Marshalable

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods

      protected

        def marshal_attrs(*attrs)
          attrs = attrs.map{|attr| :"@#{attr}" }
          self.class_eval do
            define_method(:marshalable_attrs) { attrs }
          end
        end

        alias_method :marshal_attr, :marshal_attrs

    end

    module InstanceMethods

      def marshal_dump
        marshalable_attrs.map{|attr| instance_variable_get(attr) }
      end

      def marshal_load(data)
        [data].flatten.each_with_index do |val, i|
          instance_variable_set(marshalable_attrs[i], val)
        end
      end

      protected

        def evaluable_string(val)
          "Marshal.load(Base64.strict_decode64(%q|#{Base64.strict_encode64(Marshal.dump(val)).gsub('|','\|')}|))"
        end

        def mclone(val)
          Marshal.load(Marshal.dump(val))
        end

    end

  end
end
