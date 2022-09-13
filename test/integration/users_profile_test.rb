require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper #full_titleヘルパー使うため

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user) #showにはアクセス制限ない
    assert_template "users/show"
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    #h1タグの子要素にimgタグ(gravatarクラスを持つ)がある。
    assert_match @user.microposts.count.to_s, response.body
    #ユーザの投稿数を表示している部分がレスポンスされたHTMLのbody部にある。
    assert_select "div.pagination", count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
