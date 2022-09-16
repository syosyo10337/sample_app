# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# メインのサンプルユーザを1つ作成
User.create!(name: 'Example User',
             email: 'example@railstutorial.org',
             password: 'foobar',
             password_confirmation: 'foobar',
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

# 追加のユーザを.timesをつかって作成
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = 'password'
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
  end

#一部のユーザに対してサンプルのマイクロポストを生成する。
users = User.order(:created_at).take(6)
50.times do
  #Faker(gem)のダミー文章作成メソッドを使って
  content = Faker::Lorem.sentence(word_count: 5)
  #(6)人のユーザに作成したダミー文章を挿入
  users.each { |user| user.microposts.create!(content: content)}
end

#ユーザのRelationshipに関するサンプル
users = User.all
f_user = users.first
following = users[2..50]
followers = users[3..40]
#f_userがusers[2..50]までのユーザ達をフォローする。
following.each { |followed| f_user.follow(followed)}
#users[3..40]のユーザ達がf_userをフォローする。
followers.each { |follower| follower.follow(f_user)}