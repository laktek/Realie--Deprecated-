require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Pad" do
  before(:all) do
    result = RedisRunner.start_detached
    raise("Could not start redis-server, aborting") unless result

    # yea, this sucks, but it seems like sometimes we try to connect too quickly w/o it
    sleep 1

    # use database 15 for testing so we dont accidentally step on you real data
    @test_db = Redis.new :db => 15 
  end

  before(:each) do
    Pad.stub!(:store).and_return(@test_db)
    Line.stub!(:store).and_return(@test_db)
    @it = Pad.new
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

  describe "creating a new one" do
    it "should increment the pad count" do
      @test_db["pads"] = "5"
      @it.save 

      Pad.count.should == "6"
    end

    it "should set the pad id" do
      @it.save 

      @it.id.should == 1
    end
  end

  describe "adding users" do
    before do
      @it.save
    end

    it "should have new user in the list" do
      @it.add_user("1")  
      @test_db.sismember("pads:1:users", "1").should be_true
      #should implement
      #@it.users.should include?("1")
    end

    it "should increase the list user count" do
      @it.add_user("1")
      @test_db.scard("pads:1:users").should == 1
      #should implement
      #@it.users.count.should == 1
    end

    it "should not add the same user twice" do
      @it.add_user("1")
      prev_card = @test_db.scard("pads:1:users")
      @it.add_user("1")
      @test_db.scard("pads:1:users").should == prev_card
    end
  end

  describe "removing users" do
    before do
      @it.save
      @it.add_user("1")  
      @it.add_user("2")  
    end

    it "should have remove the user from the list" do
      @it.remove_user("1")  
      @test_db.sismember("pads:1:users", "1").should be_false 
      #should implement
      #@it.users.should include?("1")
    end

    it "should decrease the list user count" do
      @it.remove_user("1")
      @test_db.scard("pads:1:users").should == 1
      #should implement
      #@it.users.count.should == 1
    end
  end

  describe "getting the snapshot of a pad" do
    before do
      @pad = Pad.new.save

      @line2 = Line.new
      @line2.pad = 1
      @line2.user = 1
      @line2.content = "world" 
      @line2.position = 2
      @line2.save

      @line1 = Line.new
      @line1.pad = 1
      @line1.user = 1
      @line1.content = "hello" 
      @line1.position = 1
      @line1.save

    end

    it "should include all lines in the pad" do
      @pad.snapshot.length.should == 2
    end

    it "should sort the lines in ascending order" do
      @pad.snapshot.should == ["hello", "world"]
    end
  end

  describe "getting the timeline of the pad" do
    before do
      @pad = Pad.new.save

      @line2 = Line.new
      @line2.pad = 1
      @line2.user = 1
      @line2.content = "world" 
      @line2.position = 2
      @line2.save

      @line1 = Line.new
      @line1.pad = 1
      @line1.user = 1
      @line1.content = "hello" 
      @line1.position = 1
      @line1.save

    end

    it "should include all lines in the pad" do
      @pad.timeline.length.should == 2
    end

    it "should return the lines in insertion order" do
      @pad.timeline.should == ["world", "hello"]
    end
  end

end
