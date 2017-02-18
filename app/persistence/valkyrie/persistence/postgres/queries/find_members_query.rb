# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindMembersQuery
    attr_reader :obj
    def initialize(obj)
      @obj = obj
    end

    def run
      relation.lazy.map do |orm_object|
        ::ResourceFactory.from_orm(orm_object)
      end
    end

    private

      def relation
        orm_model.find_by_sql([query, obj.id])
      end

      def query
        <<-SQL
        SELECT member.* FROM orm_resources a,
        jsonb_array_elements_text(a.metadata->'member_ids') WITH ORDINALITY AS b(member, member_pos)
        JOIN orm_resources member ON b.member::uuid = member.id WHERE a.id = ?
        ORDER BY b.member_pos
      SQL
      end

      def orm_model
        ::Valkyrie::Persistence::Postgres::ORM::Resource
      end
  end
end