require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/methods', __FILE__)

describe "Time#-" do
  it "decrements the time by the specified amount" do
    (Time.at(100) - 100).should == Time.at(0)
    (Time.at(100) - Time.at(99)).should == 1.0
  end

  it "understands negative subtractions" do
    t = Time.at(100) - -1.3
    t.usec.should == 300000
    t.to_i.should == 101
  end

  ruby_version_is ""..."1.9" do
    it "accepts arguments that can be coerced into Float" do
      (obj = mock('9.5')).should_receive(:to_f).and_return(9.5)
      (Time.at(100) - obj).should == Time.at(90.5)
    end
  end

  ruby_version_is "1.9" do
    #see [ruby-dev:38446]
    it "accepts arguments that can be coerced into Rational" do
      (obj = mock('10')).should_receive(:to_r).and_return(Rational(10))
      (Time.at(100) - obj).should == Time.at(90)
    end
  end

  it "raises TypeError on argument that can't be coerced" do
    lambda { Time.now - Object.new }.should raise_error(TypeError)
    lambda { Time.now - "stuff" }.should raise_error(TypeError)
  end

  it "raises TypeError on nil argument" do
    lambda { Time.now - nil }.should raise_error(TypeError)
  end

  it "tracks microseconds" do
    time = Time.at(0.777777)
    time -= 0.654321
    time.usec.should == 123456
    time -= 1
    time.usec.should == 123456
  end

  ruby_version_is "1.9" do
    it "tracks microseconds" do
      time = Time.at(Rational(777777, 1000000))
      time -= Rational(654321, 1000000)
      time.usec.should == 123456
      time -= Rational(123456, 1000000)
      time.usec.should == 0
    end
  end

  it "returns a UTC time if self is UTC" do
    (Time.utc(2012) - 10).utc?.should == true
  end

  it "returns a non-UTC time if self is non-UTC" do
    (Time.local(2012) - 10).utc?.should == false
  end

  ruby_version_is "1.9" do
    it "returns a time with the same fixed offset as self" do
      (Time.new(2012, 1, 1, 0, 0, 0, 3600) - 10).utc_offset.should == 3600
    end
  end

  it "does not returns a subclass instance" do
    c = Class.new(Time)
    x = c.now + 1
    x.should be_kind_of(Time)
  end
end
