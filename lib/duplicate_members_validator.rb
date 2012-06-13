class DuplicateMembersValidator < ActiveModel::Validator
  def validate(record)
    set = Set.new
    record.nodes.each do |node|
      record.errors.add :node_id, "^#{record.graph_membership_nodes_attributes.count}"
      unless set.add?(node.id)
        record.errors.add :node_id, "^You selected a node multiple times"
      end
    end
  end
end
