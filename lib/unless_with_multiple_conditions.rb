module RuboCop
  module Cop
    module Style
      class UnlessWithMultipleConditions < ::RuboCop::Cop::Cop
        MSG = 'Do not use `unless` with multiple conditions because it is error prone & difficult to debug.'.freeze

        def on_if(node)
          @node = node
          return unless unless_with_multiple_conditions?
          add_offense(node, :expression)
        end

        private

        def unless_with_multiple_conditions?
          unless? && contains_multiple_conditions?
        end

        def unless?
          @node.loc.respond_to?(:keyword) && @node.loc.keyword.is?('unless')
        end

        def contains_multiple_conditions?
          @node.child_nodes.first.and_type? || @node.child_nodes.first.or_type?
        end
      end
    end
  end
end
