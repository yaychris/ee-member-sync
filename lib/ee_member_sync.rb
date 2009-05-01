module EEMemberSync

  module Model
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods

      def sync_with_ee(ee_id)
        update_from_ee(ee_id)
      end

      def fetch_ee_groups
        hash = {}

        begin
          data = ActiveRecord::Base.connection.select_all("SELECT `group_id`, `group_title` AS `group` FROM `exp_member_groups")
          data.each { |i| hash[i["group"]] = i["group_id"] } unless data.blank?
        rescue
        end

        hash
      end


      protected

      def update_from_ee(id)
        ee_data = fetch_ee_data(id)
        return nil if ee_data.blank?

        ee_data.symbolize_keys!

        member = find_or_initialize_by_ee_id(ee_data[:ee_id])
        member.update_attributes(ee_data)
        member
      end

      def fetch_ee_data(id)
        begin
          sql = "SELECT
              `m`.`member_id` AS `ee_id`,
              `m`.`username` AS `ee_username`,
              `m`.`screen_name` AS `ee_screen_name`,
              `m`.`email` AS `ee_email`,
              `g`.`group_id` AS `ee_group_id`,
              `g`.`group_title` AS `ee_group_name` 
            FROM `exp_members` `m`, `exp_member_groups` `g` 
            WHERE `m`.`member_id` = #{ActiveRecord::Base.sanitize(id)}
              AND `m`.`group_id` = `g`.`group_id`"

          ActiveRecord::Base.connection.select_all(sql).shift
        rescue
          nil
        end
      end
    end
    
    module InstanceMethods
      def sync_with_ee
        return false if ee_id.blank?
        self.class.sync_with_ee(ee_id)
        reload
      end

      def update_ee_group(new_group)
        groups = self.class.fetch_ee_groups
        return false unless groups.include?(new_group)

        begin
          sql = "UPDATE `exp_members`
            SET `group_id` = #{ActiveRecord::Base.sanitize(groups[new_group])}
            WHERE `member_id` = #{ActiveRecord::Base.sanitize(ee_id)}"

          ActiveRecord::Base.connection.update(sql)
        rescue
          return false
        end

        sync_with_ee
        true
      end
    end
  end

  module Controller
    def self.included(base)
      base.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def fetch_ee_session(sess_id = nil)
        session[:ee_session] = {}

        sess = sess_id || cookies[:exp_sessionid] 
        return if sess.blank?

        begin
          data = ActiveRecord::Base.connection.select_all("SELECT * FROM `exp_sessions`
          WHERE `session_id` = #{ActiveRecord::Base.sanitize(sess)}").shift
        rescue
        end

        data = data || {}

        session[:ee_session] = data.symbolize_keys!
      end
    end
  end
end
