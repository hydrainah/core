# encoding: utf-8
# spec/models/uketd_spec.rb
require 'spec_helper'

describe UketdObject do
  
  context "original spec" do
    before(:each) do
      # Create a new etd object for the tests... 
      @etd = UketdObject.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @etd.datastreams.keys.should include("descMetadata")
      @etd.descMetadata.should be_kind_of Datastream::ModsEtd
      @etd.descMetadata.label.should == "MODS metadata"

      #Check for contentMetadata datastream
      @etd.datastreams.keys.should include("contentMetadata")
      @etd.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @etd.datastreams.keys.should include("rightsMetadata")
      @etd.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @etd.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @etd.datastreams.keys.should include("properties")
      @etd.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end

    it "should have the attributes of an etd object and support update_attributes" do
      attributes_hash = {
        "title" => "A thesis describing the...",
        "person_name" => ["Smith, John.", "Supervisor, A."],
        "person_role_text" => ["Creator", "Supervisor"],
        "organisation_name" => ["The University of Hull"],
        "organisation_role_text" =>["Funder"],
        "abstract" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "subject_topic" => ["Subject of the matter"],
        "grant_number" => "GN:122335",
        "ethos_identifier" => "EthosId:Test:009",       
        "date_issued" => "1983-03-01",
        "qualification_level" => "Doctoral",
        "qualification_name" => "PhD",
        "dissertation_category" => "",
        "language_text" => "English",
        "language_code" => "eng",
        "publisher" => "ICTD, The University of Hull",
        "resource_status" => "New nice object"
      } 

      @etd.update_attributes( attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @etd.title.should == attributes_hash["title"]
      @etd.abstract.should == attributes_hash["abstract"]  
      @etd.ethos_identifier == attributes_hash["ethos_identifier"]
      @etd.date_issued == attributes_hash["date_issued"]
      @etd.qualification_level == attributes_hash["qualification_level"]
      @etd.qualification_name == attributes_hash["qualification_name"]
      @etd.dissertation_category == attributes_hash["dissertation_category"]
      @etd.language_text == attributes_hash["language_text"]
      @etd.language_code == attributes_hash["language_code"]
      @etd.publisher == attributes_hash["publisher"]
      @etd.resource_status.should == attributes_hash["resource_status"]


      # These attributes are not marked as 'unique' in the call to delegate, results will be arrays...
      @etd.person_name.should == attributes_hash["person_name"]
      @etd.person_role_text.should == attributes_hash["person_role_text"]
      @etd.organisation_name.should == attributes_hash["organisation_name"]
      @etd.organisation_role_text.should == attributes_hash["organisation_role_text"]
      @etd.subject_topic.should == attributes_hash["subject_topic"]  
      @etd.grant_number == [attributes_hash["grant_number"]]


      @etd.save
    end

    it "should respond with validation errors when trying to save without the appropiate fields populated" do
      invalid_attributes_hash = {
        "title" => "",
        "person_name" => [""],
        "person_role_text" => [""],
        "subject_topic" => [""],
        "qualification_level" => "",
        "qualification_name" => "",
        "publisher" => "",
        "date_issued" => "January"
      }

      @etd.update_attributes( invalid_attributes_hash )

      # save should be false
      @etd.save.should be_false

      # with 8 error messages
      @etd.errors.messages.size.should == 8

      # errors...
      @etd.errors.messages[:title].should == ["can't be blank"]
      @etd.errors.messages[:person_name].should == ["is too short (minimum is 5 characters)"]
      @etd.errors.messages[:person_role_text].should == ["is too short (minimum is 3 characters)"]
      @etd.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
      @etd.errors.messages[:publisher].should == ["can't be blank"]
      @etd.errors.messages[:qualification_level].should == ["can't be blank"]
      @etd.errors.messages[:qualification_level].should == ["can't be blank"]
      @etd.errors.messages[:date_issued].should == ["is invalid"]

    end

    context "non unique fields" do
      before(:each) do
        @attributes_hash = {
          "title" => "A thesis describing the...",
          "person_name" => ["Smith, John.", "Supervisor, A."],
          "person_role_text" => ["Creator", "Supervisor"],
          "organisation_name" => ["The University of Hull"],
          "organisation_role_text" =>["Funder"],
          "abstract" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "subject_topic" => ["Subject of the matter"],
          "grant_number" => ["GN:122335"] 
        } 
        @etd.update_attributes( @attributes_hash )        
      end
      it "should not overwrite the person_name and person_role_text if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title" }
        @etd.update_attributes( new_attributes_hash )
        @etd.title.should == new_attributes_hash["title"]
        @etd.person_name.should ==  @attributes_hash["person_name"]
        @etd.person_role_text.should == @attributes_hash["person_role_text"]
      end

      it "should not overwrite the subject_topic if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title part 2" }
        @etd.update_attributes( new_attributes_hash )
        @etd.title.should == new_attributes_hash["title"]
        @etd.subject_topic.should == @attributes_hash["subject_topic"]
      end   

      it "should not overwrite the grant_number if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title part 3" }
        @etd.update_attributes( new_attributes_hash )
        @etd.title.should == new_attributes_hash["title"]
        @etd.grant_number.should == @attributes_hash["grant_number"]
      end
    end

  end

  context "methods" do
      before(:each) do
          #set the 'required' fields
          @valid_etd  =  UketdObject.new
          @valid_etd.title = "Test title"
          @valid_etd.person_name = ["Smith, John.", "Jones, John"]
          @valid_etd.person_role_text = ["Creator", "Creator"]
          @valid_etd.subject_topic = ["Topci 1"]
          @valid_etd.language_code = "eng"
          @valid_etd.language_text = "English"
          @valid_etd.publisher = "IT, UoH"
          @valid_etd.qualification_name = "Undergraduate"
          @valid_etd.qualification_level = "BSc"
          @valid_etd.date_issued = "2012"
          @valid_etd.save
      end
      after(:each) do
        @valid_etd.delete
      end
      describe ".to_solr" do
        it "should return the necessary facets" do
          solr_doc = @valid_etd.to_solr
          solr_doc["object_type_sim"].should == "Thesis or dissertation"
        end

        it "should return the necessary cModels" do
          solr_doc = @valid_etd.to_solr
          solr_doc["has_model_ssim"].should == ["info:fedora/hydra-cModel:commonMetadata", "info:fedora/hydra-cModel:genericParent", "info:fedora/hull-cModel:uketdObject"]
        end
      end
      describe ".save" do
        it "should create the appropriate cModel declarations" do       
          @valid_etd.ids_for_outbound(:has_model).should == ["hydra-cModel:commonMetadata", "hydra-cModel:genericParent", "hull-cModel:uketdObject"] 
        end
        it "should contain the appropiately case for the uketdObject in the RELS-EXT (Lower Camelcase)" do
          @valid_etd.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:uketdObject').should == true
        end
        it "apply_additional_metadata should pre-populate the copyright (rights) field" do
          @valid_etd.rights.should == "© 2012 John Smith and John Jones. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holders." 
        end
      end
     
  end

  context "resource_state" do
    before(:each) do
      #set the general 'required' fields for an object
      @valid_etd  =  UketdObject.new
      @valid_etd.title = "Test title"
      @valid_etd.person_name = ["Smith, John."]
      @valid_etd.person_role_text = ["Creator"]
      @valid_etd.subject_topic = ["Topci 1"]
      @valid_etd.language_code = "eng"
      @valid_etd.language_text = "English"
      @valid_etd.publisher = "IT, UoH"
      @valid_etd.qualification_name = "Undergraduate"
      @valid_etd.qualification_level = "BSc"
      @valid_etd.date_issued = "2012"
      @valid_etd.save
    end

    after(:each) do
      @valid_etd.delete
    end

    describe "hidden" do
      it "should validate that the required field 'resource status' is populated" do

        #Submit the resource so that it can be hidden... 
        @valid_etd.submit_resource
        #Save the state... 
        @valid_etd.save
        
        @valid_etd.resource_state.should == "qa"

        #Hide the resource...
        @valid_etd.hide_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_etd.save.should be_false
        @valid_etd.errors.messages[:resource_status].should == ["can't be blank"]
        
        #Populate thteh required field
        @valid_etd.resource_status = "Hidden due to Copyright enquiry"
        #Save should work...
        @valid_etd.save.should be_true
      end
    end

    describe "deleted" do
      it "should validate that the required field 'resource status' is populated" do
        #Submit the resource so that it can be hidden... 
        @valid_etd.submit_resource
        @valid_etd.publish_resource
        #Save the state... 
        @valid_etd.save

        @valid_etd.resource_state.should == "published"

        #'Delete' the resource...
        @valid_etd.delete_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_etd.save.should be_false
        @valid_etd.errors.messages[:resource_status].should == ["can't be blank"]

        #Populate thteh required field
        @valid_etd.resource_status = "Deleted due to duplicate record"
        #Save should work...
        @valid_etd.save.should be_true
      end
    end

  end

end

