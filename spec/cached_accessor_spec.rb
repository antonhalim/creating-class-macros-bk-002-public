require 'spec_helper'

class TestClass
  extend CachedAccessor
  cached_accessor :name
end

describe CachedAccessor do
  it "creates getter and setter method for argument passed" do
    test = TestClass.new
    test.name = "A test"
    expect(test.name).to eq("A test")
  end

  it "new objects don't have a previous state" do
    test = TestClass.new
    test.name = "A test"
    expect(test.old_name).to be_nil
  end

  it "keeps the previous version of an attribute once it's changed" do
    test = TestClass.new
    test.name = "A test"
    test.name = "A different test"
    expect(test.name).to eq("A different test")
    expect(test.old_name).to eq("A test")
  end

  it "allows you to rollback a change" do
    test = TestClass.new
    test.name = "A test"
    test.name = "A different test"
    test.rollback_name
    expect(test.name).to eq("A test")
    expect(test.old_name).to be_nil
  end
end
