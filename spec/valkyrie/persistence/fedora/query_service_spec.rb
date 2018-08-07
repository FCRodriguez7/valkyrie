# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

=begin
RSpec.describe Valkyrie::Persistence::Fedora::QueryService do
  let(:adapter) { Valkyrie::Persistence::Fedora::MetadataAdapter.new(connection: ::Ldp::Client.new("http://localhost:8988/rest"), base_path: "test_fed") }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  it_behaves_like "a Valkyrie query provider"
end
=end
