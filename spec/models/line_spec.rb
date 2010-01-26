require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Line" do
  before(:all) do
    result = RedisRunner.start_detached
    raise("Could not start redis-server, aborting") unless result

    # yea, this sucks, but it seems like sometimes we try to connect too quickly w/o it
    sleep 1

    # use database 15 for testing so we dont accidentally step on you real data
    @test_db = Redis.new :db => 15 
  end

  before(:each) do
    Line.stub!(:store).and_return(@test_db)
    @it = Line.new
  end

  after(:each) do
    @test_db.keys('*').each {|k| @test_db.del k}
  end

  after(:all) do
    begin
      @test_db.quit
    ensure
      RedisRunner.stop
    end
  end

  describe "adding a line" do

    before do
      @pad = Pad.new.save
      @it.pad = @pad
      @it.user = 1 #should fix
    end
    
    it "should increase the global line count" do
      @test_db["lines"] = "5"
      @it.save

      Line.count.should == "6"
    end

    it "should store the line in global line set" do
     @it.content = "hello"
     @it.position = "2" 
     @it.save

     @test_db["line:line_sha"].should == "{content: hello, position: 2}"
    end

  end


end
