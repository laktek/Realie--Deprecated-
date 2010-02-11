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
      @it.pad = 1 #@pad
      @it.user = 1 #should fix
      @it.content = "hello"
      @it.position = 2 
      @it.stub!(:digest_for_line_content).and_return("line_sha")
    end
    
    it "should increase the global line count" do
      @test_db["lines"] = "5"
      @it.save

      Line.count.should == "6"
    end

    it "should store the line in global line set" do
     @it.save
     @test_db["line:line_sha"].should == "{\"user\":1,\"position\":2,\"content\":\"hello\"}" 
    end

    it "should increase the line count of the pad" do
      @test_db["pad:1:lines"] = "5"
      @it.save
      @test_db["pad:1:lines"].should == "6"
    end

    it "should add the line to pad's timeline of edits" do
      @it.save
      @test_db.rpop("pad:1:timeline").should == "line_sha"
    end

    it "should add the line to pad's snapshot" do
      @it.save
      @test_db.sismember("pad:1:snapshot_lines", "2").should be_true
      @test_db["pad:1:snapshot:2"].should == "line_sha"
    end

    it "should replace if there is already a line in pad's snapshot" do
      @test_db["pad:1:snapshot:2"] = "old_line_sha"

      @it.save
      @test_db["pad:1:snapshot:2"].should == "line_sha"
    end

  end


end
