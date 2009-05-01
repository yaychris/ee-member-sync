require File.join(File.dirname(__FILE__), '..', 'test_helper')

class EEMemberSyncControllerTest < ActionController::TestCase
  tests UsersController

  context "The Users controller" do
    context "when calling :fetch_ee_session" do
      setup do
        @ee_session = select_all("SELECT * FROM `exp_sessions` LIMIT 1").shift
      end

      context "with an EE session ID in the cookie" do
        context "which is valid" do
          setup do
            @request.cookies["exp_sessionid"] = @ee_session["session_id"]
            get :cookie
          end

          should "assign the EE session data to session[:ee_session]" do
            %w(session_id site_id member_id admin_sess ip_address user_agent last_activity).each do |var|
              assert_equal @ee_session[var], session[:ee_session][var.to_sym]
            end
          end
        end

        context "which is invalid" do
          setup do
            @request.cookies["exp_sessionid"] = "blah!"
            get :cookie
          end

          should "do nothing" do
            assert_equal({}, session[:ee_session])
          end
        end
      end


      context "with an EE session ID passed in manually" do
        context "which is valid" do
          setup do
            get :param, :sess => @ee_session["session_id"]
          end

          should "set session[:ee_session] to an empty hash" do
            %w(session_id site_id member_id admin_sess ip_address user_agent last_activity).each do |var|
              assert_equal @ee_session[var], session[:ee_session][var.to_sym]
            end
          end
        end

        context "which is invalid" do
          setup do
            get :param, :sess => "blaugh!"
          end

          should "set session[:ee_session] to an empty hash" do
            assert_equal({}, session[:ee_session])
          end
        end

        context "which is nil" do
          setup do
            get :param
          end

          should "set session[:ee_session] to an empty hash" do
            assert_equal({}, session[:ee_session])
          end
        end
      end

    end
  end
end
