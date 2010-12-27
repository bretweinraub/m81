#!/usr/local/bin/ruby

require "m80table"
require "column"

def createMigration(name,upblock,downblock)
  ret=<<END_OF_STMT
class #{name} < ActiveRecord::Migration
  def self.up
    #{upblock}
  end
  def self.down
    #{downblock}
  end
end
END_OF_STMT
  ret
end

def newM80Table(table)
  ret=<<END_OF_STMT
    create_table :#{table} do |t|
    end
END_OF_STMT
  ret
end

def dropTable(table)
  "drop_table :#{table}"
end

workorder = M80table.new("workorder",[M80column.new("assigned_to","varchar2(32)")])

puts workorder.inspect

#puts createMigration("workorder",newM80Table("workorder"),dropTable("workorder"))




