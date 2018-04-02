module RuboCop
  module Cop
    module Style
      class UpdateNotUpdateAttributes < ::RuboCop::Cop::Cop
        MSG = 'Do not use `update_attributes` or `update_attributes!`, use `update` or `update!`.'.freeze

        def on_send(node)
          return unless update_attributes_or_update_attributes_bang?(node)
          add_offense(node, :selector)
        end

        private

        def update_attributes_or_update_attributes_bang?(node)
          node.method?(:update_attributes) || node.method?(:update_attributes!)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector, replacement_method(node))
          end
        end

        def message(node)
          format(MSG, replacement_method(node))
        end

        def replacement_method(node)
          method = node.method_name
          return 'update' if method == :update_attributes
          'update!'
        end
      end
    end
  end
end
