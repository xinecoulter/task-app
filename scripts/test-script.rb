User.joins(:identities).where("identities.name = ?", "facebook").find_each do |user|
  identity = user.identities.find_by_name("facebook")
  next if identity.oauth_expires_at <= Time.now
  message = "testing! woo!"
  user.facebook.put_wall_post(message)
end
