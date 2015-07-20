class Identity < ActiveRecord::Base
  belongs_to :user

  def self.from_omniauth(auth)
    where(name: auth.provider, uid: auth.uid).first_or_create do |identity|
      identity.token = auth.credentials.token
    end
  end
end
