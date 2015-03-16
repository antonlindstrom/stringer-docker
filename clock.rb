require 'clockwork'

module Clockwork
  handler do |job|
    `bundle exec rake #{job}`
  end

  every(30.minutes, 'fetch_feeds')
end
