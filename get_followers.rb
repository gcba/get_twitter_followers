require 'twitter'
require "csv"


client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "XXX"
  config.consumer_secret     = "XXX"
  config.access_token        = "XXXXXX"
  config.access_token_secret = "XXX"
end


def get_follower_ids(client, user_id)
  follower_ids = []
  next_cursor = -1
  while next_cursor != 0
    cursor = client.follower_ids(user_id, :cursor => next_cursor)
    follower_ids.concat cursor.attrs[:ids]
    next_cursor = cursor.send(:next_cursor)
  end
  follower_ids
end


def get_friend_ids(client, user_id)
  friend_ids = []
  next_cursor = -1
  begin
    while next_cursor != 0
      cursor = client.friend_ids(user_id, :cursor => next_cursor)
      friend_ids.concat cursor.attrs[:ids]
      next_cursor = cursor.send(:next_cursor)
    end
  rescue Twitter::Error::Unauthorized
    []
  end
  friend_ids
end
 

def get_followers_info(client)
  friends = []
  get_follower_ids(client, client.user.id).each_slice(100) do |ids|
    friends.concat client.users(ids)
  end
  friends
end

CSV.open("followers.csv", "w") do |csv|
  followers = get_followers_info(client)
  total = followers.count
  followers.each_with_index do |user, index|
    sleep 2
    print "\r#{index}/#{total} completo"
 
    user_friend_ids = get_friend_ids(client, user.id)
    csv << [user.id, user.name, user.description, user.location, user.uri.to_s, user_friend_ids]
  end
end







