require '../achievements.rb'

test_user1 = {
  'stats' => {'counts' => {'owned' => {
    'forkcount' => 100,
    'langcount' => 3,
    'watchercount' => 200
  }}}
}

test_user2 = {
  'stats' => {'counts' => {'owned' => {
    'langcount' => 3,
    'watchercount' => nil
  }}}
}

test_user3 = {}

puts Achievements.new.set_user_achievements(test_user1)['achievements']
puts Achievements.new.set_user_achievements(test_user2)['achievements']
puts Achievements.new.set_user_achievements(test_user3)['achievements']

