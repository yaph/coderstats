require '../achievements.rb'

test_user1 = {
  'stats' => {'counts' => {'owned' => {
    'total' => 70,
    'forkcount' => 250,
    'langcount' => 10,
    'watchercount' => 500
  }}}
}

test_user2 = {
  'stats' => {'counts' => {'owned' => {
    'total' => 30,
    'langcount' => 3,
    'watchercount' => nil
  }}}
}

test_user3 = {}

puts Achievements.new.set_user_achievements(test_user1)['achievements']
puts Achievements.new.set_user_achievements(test_user2)['achievements']
puts Achievements.new.set_user_achievements(test_user3)['achievements']

