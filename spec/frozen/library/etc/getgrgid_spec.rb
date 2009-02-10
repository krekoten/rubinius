require File.dirname(__FILE__) + '/../../spec_helper'
require 'etc'

platform_is :windows do
  describe "Etc.getgrgid" do
    it "returns nil" do
      Etc.getgrgid(1).should == nil
      Etc.getgrgid(nil).should == nil
      Etc.getgrgid('nil').should == nil
    end
  end
end

# TODO: verify these on non-windows, non-darwin OS
platform_is_not :windows do
  describe "Etc.getgrgid" do
    before(:all) do
      @gid = `id -g`.strip.to_i
      @name = `id -gn`.strip
    end

    ruby_version_is "" ... "1.9" do
      it "returns a Struct::Group struct instance for the given user" do
        gr = Etc.getgrgid(@gid)

        gr.is_a?(Struct::Group).should == true
        gr.gid.should == @gid
        gr.name.should == @name
      end

      it "returns the Struct::Group for a given gid if it exists" do
        grp = Etc.getgrgid(@gid)
        grp.should be_kind_of(Struct::Group)
        grp.gid.should == @gid
        grp.name.should == @name
      end
    end

    ruby_version_is "1.9" do
      it "returns a Etc::Group struct instance for the given user" do
        gr = Etc.getgrgid(@gid)

        gr.is_a?(Etc::Group).should == true
        gr.gid.should == @gid
        gr.name.should == @name
      end

      it "returns the Etc::Group for a given gid if it exists" do
        grp = Etc.getgrgid(@gid)
        grp.should be_kind_of(Etc::Group)
        grp.gid.should == @gid
        grp.name.should == @name
      end

      it "uses Process.gid as the default value for the argument" do
        gr = Etc.getgrgid

        gr.gid.should == @gid
        gr.name.should == @name
      end
    end

    platform_is_not :darwin, :freebsd do
      it "ignores its argument" do
        lambda { Etc.getgrgid("foo") }.should raise_error(TypeError)
        Etc.getgrgid(42)
        Etc.getgrgid(9876)
      end
    end

    it "returns the Group for a given gid if it exists" do
      grp = Etc.getgrgid(@gid)
      grp.should be_kind_of(Struct::Group)
      grp.gid.should == @gid
      grp.name.should == @name
    end

    it "raises if the group does not exist" do
      lambda { Etc.getgrgid(9876)}.should raise_error(ArgumentError)
    end

    it "only accepts integers as argument" do
      lambda {
        Etc.getgrgid("foo")
        Etc.getgrgid(nil)
      }.should raise_error(TypeError)
    end
  end
end
