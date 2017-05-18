# kinda like SummaryNotification#rerun_argument_for, except that it's
#  * general purpose
#  * works correctly even if just a subset of spec files are loaded
module RerunArgument
  class << self
    def for(example)
      if shared_example?(example) || duplicate_location?(example)
        example.id
      else
        example.location_rerun_argument
      end
    end

    def shared_example?(example)
      example.example_group.parent_groups.any? { |group| group.metadata[:shared_group_name] }
    end

    def duplicate_location?(example)
      examples_at_location = examples_by_location(example.example_group.parent_groups.last)[example.location_rerun_argument]
      examples_at_location.size > 1
    end

    def examples_by_location(root_group)
      @examples_by_location ||= {}
      @examples_by_location[root_group] ||= begin
        all_examples = root_group.descendants.inject([]) do |examples, group|
          examples.concat group.examples
        end
        all_examples.each_with_object({}) do |example, map|
          map[example.location_rerun_argument] ||= []
          map[example.location_rerun_argument] << example
        end
      end
    end
  end
end
