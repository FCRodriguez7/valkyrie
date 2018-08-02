# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Resource do
  before do
    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::Set
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  subject(:resource) { Resource.new }
  describe "#fields" do
    it "returns all configured fields as an array of symbols" do
      expect(Resource.fields).to eq [:id, :internal_resource, :created_at, :updated_at, :title]
    end
  end

  describe "#has_attribute?" do
    it "returns true for fields that exist" do
      expect(resource.has_attribute?(:title)).to eq true
      expect(resource.has_attribute?(:not)).to eq false
    end
  end

  describe "#column_for_attribute" do
    it "returns the column" do
      expect(resource.column_for_attribute(:title)).to eq :title
    end
  end

  describe "#persisted?" do
    context 'when nothing is passed to the constructor' do
      it { is_expected.not_to be_persisted }
    end

    context 'when new_record: false is passed to the constructor' do
      subject(:resource) { Resource.new(new_record: false) }

      it { is_expected.to be_persisted }
    end
  end

  describe "#to_key" do
    it "returns the record's id in an array" do
      resource.id = "test"
      expect(resource.to_key).to eq [resource.id]
    end
  end

  describe "#to_param" do
    it "returns the record's id as a string" do
      resource.id = "test"
      expect(resource.to_param).to eq 'test'
    end
  end

  describe "#to_model" do
    it "returns itself" do
      expect(resource.to_model).to eq resource
    end
  end

  describe "#model_name" do
    it "returns a model name" do
      expect(resource.model_name).to be_kind_of(ActiveModel::Name)
    end
    it "returns a model name at the class level" do
      expect(resource.class.model_name).to be_kind_of(ActiveModel::Name)
    end
  end

  describe "#to_s" do
    it "returns a good serialization" do
      resource.id = "test"
      expect(resource.to_s).to eq "Resource: test"
    end
  end

  describe '.human_readable_type=' do
    it 'sets the human readable type' do
      described_class.human_readable_type = 'Bogus Type'
      expect(described_class.human_readable_type).to eq('Bogus Type')
    end
  end

  context "extended class" do
    before do
      class MyResource < Resource
      end
    end
    after do
      Object.send(:remove_const, :MyResource)
    end
    subject(:resource) { MyResource.new }
    describe "#fields" do
      it "returns all configured parent fields as an array of symbols" do
        expect(MyResource.fields).to eq [:id, :internal_resource, :created_at, :updated_at, :title]
      end
    end
    describe "#internal_resource" do
      it "returns a stringified version of itself" do
        expect(MyResource.new.internal_resource).to eq "MyResource"
      end
    end
    describe "defining an internal attribute" do
      it "warns you and changes the type" do
        expect { MyResource.attribute(:id) }.to output(/is a reserved attribute/).to_stderr
        expect(MyResource.schema[:id]).to eq Valkyrie::Types::Set.optional
      end
    end
  end

  describe "::enable_optimistic_locking" do
    context "when it is enabled" do
      before do
        class MyLockingResource < Valkyrie::Resource
          enable_optimistic_locking
          attribute :title, Valkyrie::Types::Set
        end
      end

      after do
        Object.send(:remove_const, :MyLockingResource)
      end

      it "has an optimistic_lock_token attribute" do
        expect(MyLockingResource.new).to respond_to(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
        expect(MyLockingResource.new.optimistic_locking_enabled?).to be true
      end
    end

    context "when it is not enabled" do
      before do
        class MyNonlockingResource < Valkyrie::Resource
          attribute :title, Valkyrie::Types::Set
        end
      end

      after do
        Object.send(:remove_const, :MyNonlockingResource)
      end

      it "does not have an optimistic_lock_token attribute" do
        expect(MyNonlockingResource.new).not_to respond_to(:optimistic_lock_token)
        expect(MyNonlockingResource.new.optimistic_locking_enabled?).to be false
      end
    end
  end
end
