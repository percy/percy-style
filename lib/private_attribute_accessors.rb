module RuboCop
  module Cop
    module Style
      class PrivateAttributeAccessors < ::RuboCop::Cop::Cop
        MSG = 'Do not use private attribute accessors'.freeze

        def on_class(node)
          _name, _base_class, body = *node

          attrs = private_block_attrs(body)
          return if attrs.empty?

          attrs.each do |attr|
            add_offense(attr, :expression)
          end
        end

        private

        def private_block_attrs(body)
          return [] unless body

          private_nodes(body).select do |node|
            %i(attr_reader attr_writer attr_accessor).include?(node.method_name)
          end
        end

        def private_nodes(body)
          index = body.child_nodes.index { |x| x.method_name == :private }
          return [] unless index
          body.child_nodes[(index + 1)..-1]
        end
      end
    end
  end
end
