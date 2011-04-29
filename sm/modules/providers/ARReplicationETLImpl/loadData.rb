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
    class StageTable < Target
      set_table_name :#{etl_helper.targetRD.tableName}_stg
    end

    class TargetTable < Target
      set_table_name :#{etl_helper.targetRD.tableName}
    end
  }

  msg_exec "moving staged rows from #{StageTable.table_name} #{TargetTable.table_name}" do
    StageTable.all.each do |t|
      pk = t.send(StageTable.primary_key)

      new = etl_helper.rewrite_attributes(:row => t,
                                          :record_class => TargetTable)


      if target_row = TargetTable.send("find_by_original_#{StageTable.primary_key}",pk)
        new.keys.each do |k|
          target_row.send("#{k}=",new[k])
        end
        
        target_row.save!
        print "+"
      else
        ckebug 1, "no existing row found for row #{pk}"
        TargetTable.create(new)
        print "."
      end
    end
  end

end
