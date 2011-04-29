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
    end

    class TargetTable < Target
      set_table_name :#{etl_helper.targetRD.tableName}_stg
    end
  }

  TargetTable.connection.execute("truncate table #{TargetTable.table_name}")

  msg_exec "Loading remote rows in #{TargetTable.table_name}" do
    SourceTable.all.each do |t|
      new = etl_helper.rewrite_attributes(row => t)
      TargetTable.create(new)
      print "."
    end
  end

  ENV.keys.sort.each do |k|
    puts "#{k}=#{ENV[k]}" if k.match /wp_users_trg/i
  end


end
