require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
    @non_activated =users(:non_active)
  end
 
  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    #最初のページに表示されるユーザを変数にassign
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin 
        #管理者以外のユーザの部分に<a href="/users/:id">delete</a>が存在するよね？
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    
    #有効化されていないアカウントが表示されない(count: 0)
    assert_select "a[href=?]", user_path(@non_activated), text: @non_activated.name, count: 0
    #deleteが実行されているか
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do 
    log_in_as(@non_admin)
    get users_path
    #aタグの中身deleteと表示されるものが0
    assert_select 'a', text: 'delete', count:0
  end


  


end
