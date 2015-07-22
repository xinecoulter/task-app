Team.find_each do |team|
  team.members.joins(:identities).where("identities.name = ?", "facebook").find_each do |member|
    identity = member.identities.find_by_name("facebook")
    next if identity.oauth_expires_at <= Time.now
    message = member.decorate.team_result_message(team)
    member.facebook.put_wall_post(message)
  end
end
