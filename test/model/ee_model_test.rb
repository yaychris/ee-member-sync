require File.join(File.dirname(__FILE__), '..', 'test_helper')

class EEMemberSyncModelTest < ActiveSupport::TestCase
  context "The User class" do
    context "when calling :sync_with_ee" do

      context "with a valid member id" do
        should "should update the database" do
          assert_difference("User.count", 1) do
            User.sync_with_ee(1)
          end

          first = User.first

          assert_equal 1, first.ee_id
          assert_equal "admin", first.ee_username
          assert_equal "Admin", first.ee_screen_name
          assert_equal "admin@test.dev", first.ee_email
          assert_equal "Super Admins", first.ee_group_name
          assert_equal 1, first.ee_group_id
        end
      end

      context "with an invalid member id" do
        should "not change the database" do
          assert_no_difference("User.count") do
            User.sync_with_ee(0)
            User.sync_with_ee("blah")
            User.sync_with_ee(1.5)
          end
        end

        should "return nil" do
          assert_nil User.sync_with_ee(0)
        end
      end

    end
  end

  context "A user instance" do
    context "with a corresponding member in EE" do
      context "when calling :sync_with_ee after an attribute has changed in EE" do
        setup do
          @user = User.sync_with_ee(1)

          query("UPDATE `exp_members` SET `screen_name` = 'Yay!' WHERE `member_id` = 1")

          @user.sync_with_ee
        end

        should "update the database" do
          assert_equal "Yay!", User.find_by_ee_id(1).ee_screen_name
        end

        should "automatically reload the model" do
          assert_equal "Yay!", @user.ee_screen_name
        end

        teardown do
          query("UPDATE `exp_members` SET `screen_name` = 'Admin' WHERE `member_id` = 1")
        end
      end
    end

    context "with no corresponding member in EE" do
      context "when calling :sync_with_ee" do
        setup do
          @user = User.new
        end

        should "not update the database" do
          assert_no_difference("User.count") do
            @user.sync_with_ee
          end
        end

        should "return false" do
          assert_equal false, @user.sync_with_ee
        end
      end
    end

    context "when calling :update_ee_group" do
      setup do
        @crazy_group_id = select_all("SELECT `group_id` FROM `exp_member_groups` WHERE `group_title` = 'Crazy Awesome Members'").shift["group_id"].to_i

        @members_group_id = select_all("SELECT `group_id` FROM `exp_member_groups` WHERE `group_title` = 'Members'").shift["group_id"].to_i

        @user = User.sync_with_ee(2)
      end

      context "with a valid EE group name" do
        setup do
          @user.update_ee_group("Crazy Awesome Members")
        end

        should "update the EE table" do
          data = select_all("SELECT `g`.`group_id`, `g`.`group_title`
                            FROM `exp_members` AS `m`, `exp_member_groups` AS `g`
                            WHERE `m`.`member_id` = 2 AND `m`.`group_id` = `g`.`group_id`").shift

          assert_equal @crazy_group_id, data["group_id"].to_i
          assert_equal "Crazy Awesome Members", data["group_title"]
        end

        should "update the Rails table" do
          user = User.find_by_ee_id(2)

          assert_equal "Crazy Awesome Members", user.ee_group_name
          assert_equal @crazy_group_id, user.ee_group_id
        end

        should "automatically reload the instance" do
          assert_equal "Crazy Awesome Members", @user.ee_group_name
        end

        teardown do
          @user.update_ee_group("Members")
        end
      end

      context "with an invalid EE group name" do
        should "not update the database" do
          @user.update_ee_group("Blergh")
          user = User.find_by_ee_id(2)

          data = select_all("SELECT `group_id` FROM `exp_members` WHERE `member_id` = 2").shift

          assert_equal @members_group_id, data["group_id"].to_i
          assert_equal @members_group_id, user.ee_group_id
          assert_equal "Members", user.ee_group_name
        end

        should "return false" do
          assert_equal false, @user.update_ee_group("Blergh")
        end
      end
    end
  end
end
