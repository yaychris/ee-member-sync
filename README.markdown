EE Member Sync
==============

EE Member Sync is a Rails plugin to sync users from ExpressionEngine to a model in Rails. The plugin consists of:

* a controller method to extract the EE session ID from the cookie and load the session data from the EE sessions table
* a model class method and an instance method to sync a specific member ID
* a model instance method to update the member's group

This plugin is tested against EE 1.6.5.


Usage
=====

Include the `EEMemberSync::Model` module in your model:

    class User < ActiveRecord::Base
      include EEMemberSync::Model
    end

Include the `EEMemberSync::Controller` module in your controller:

    class ApplicationController < ActionController::Base
      include EEMemberSync::Controller
    end

Generate a new migration with the required fields:

    class CreateUsers < ActiveRecord::Migration
      def self.up
        create_table :users do |t|
          t.integer :ee_id
          t.integer :ee_group_id
          t.string  :ee_group_name
          t.string  :ee_username
          t.string  :ee_screen_name
          t.string  :ee_email

          t.timestamps
        end
      end

      def self.down
        drop_table :users
      end
    end



Controller Methods
------------------

    class UsersController < ActionController::Base
      def some_action
        # uses the value in cookies["exp_sessionid"] to find the session
        # assigns the EE session data to session[:ee_session]
        fetch_ee_session  
      end

      def another_action
        # uses the supplied value to find the session
        fetch_ee_session(params[:sessid])  
      end
    end


Model Methods
-------------

    # EE member 1 has never synced before

    # create a new record in the users table with the member's data
    @user = User.sync_with_ee(1) 

    puts @user.ee_screen_name  # => "Yay"

    # update the member's group
    # @user will be reloaded automatically
    @user.update_ee_group("Contributors")

    # ... member updates their screen_name through EE

    # sync again, changes will be pulled in and saved
    # @user will be reloaded automatically
    @user.sync_with_ee
    puts @user.ee_screen_name # => "Hooray"




Testing
=======

ExpressionEngine is MySQL-only, so testing requires a valid MySQL config. Add your config info to `test/rails_root/config/database.yml`.




TODO
====

* add a generator for the migration
* validations for model attributes?
* update the EE cookie so it doesn't expire if the user is only in the Rails app



Copyright (c) 2009 Chris Jones, released under the MIT license
