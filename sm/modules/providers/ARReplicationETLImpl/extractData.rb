#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ckuru-tools'
#require 'aura-insight'
require File.join(ENV['TOP'],'sm-ruby','aura-insight','lib','aura-insight')
require 'log4r'
require 'ruby-debug'

emacs_trace do 
  ActiveRecord::Base.logger = Logger.new("database.log")

  etl_helper = Aura::EtlHelper.new(:source_namespace => ENV["sourceDB"],
                                   :target_namespace => "CONTROLLER")

  eval %{
    class SourceTable < Source
      set_table_name :#{etl_helper.sourceRD.tableName}
      set_primary_key :#{etl_helper.sourceRD.naturalKey}
    end

    class TargetTable < Target
      set_table_name :#{etl_helper.targetRD.tableName}_stg
    end
  }

  begin
    TargetTable.connection.execute("truncate table #{TargetTable.table_name}")
  rescue Exception => e
    eval %{
      class ::CreateTable < ActiveRecord::Migration
        def self.up
          create table #{TargetTable.table_name.to_sym} do |t|
            t.timestamps
          end
        end
      end
    }
  ### TODO Finish above.
    raise e

  end

  msg_exec "Loading remote rows in #{TargetTable.table_name}" do
    SourceTable.all.each do |t|
      new = etl_helper.rewrite_attributes(:row => t,
                                          :original_primary_key => etl_helper.sourceRD.naturalKey,
                                          :record_class => TargetTable)
      TargetTable.create(new)
      print "."
    end
  end


end
