require 'rubygems'

PATH = File.expand_path(File.dirname(__FILE__))

require PATH + '/db.rb'

user_count = 0

# global data structure for the graph as the basis for creating JSON file
# see http://thejit.org/static/v20/Jit/Examples/Hypertree/example2.js
# example:
# languages = {
#   'Ruby' => {
#     'count' => 24
#     'adjacencies' => {
#       'JavaScript' => { 'count' => 20 },
#       'Pyhton' => { 'count' => 10 }
#     }
#   },...
# }
$languages = {}

# control variable
$lang_counts = {}

# example call: update_lang('Ruby', ['Ruby', 'JavaScript'])
def update_lang(name, pair)
  if $lang_counts.has_key?(name)
    $lang_counts[name] += 1
  else
    $lang_counts[name] = 1
  end

  pair.delete(name)
  node_to = pair[0]
  if $languages.has_key?(name)
    $languages[name]['count'] += 1
    if $languages[name]['adjacencies'].has_key?(node_to)
      $languages[name]['adjacencies'][node_to]['count'] += 1
    else
      $languages[name]['adjacencies'][node_to] = { 'count' => 1 }
    end
  else
    $languages[name] = {
      'count' => 1,
      'adjacencies' => { node_to => { 'count' => 1 } }
    }
  end
end

db = Database.new().connect()
coll = db.collection('stats_users')
coll.find.each do |user|
  next unless user['counts']['owned']['languages']

  user_count += 1
  user_langs = user['counts']['owned']['languages']
  # initially ignore user repo counts for any given language
  langs = user_langs.keys
  if langs
    lang_combs = langs.combination(2)
    lang_combs.each do |comb|
      comb.each { |lang| update_lang(lang, comb) }
    end
  end
end

puts user_count
puts $lang_counts['Perl']
puts $languages['Perl'].to_s

