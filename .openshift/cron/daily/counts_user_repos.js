// http://www.mongodb.org/display/DOCS/Scripting+the+shell
// Collect stats on repos grouped by users and save to counts_user_repos collection
// db = connect('coderstats');
var targetcoll = 'counts_user_repos';
var map = function() {
  emit(this.user_id, {
    language: this.language,
    fork: this.fork,
    forks: this.forks,
    watchers: this.watchers});
};
var reduce = function(key, values) {
  var ownedrepos = 0;
  var ownedlangs = 0;
  var ownedlanguages = {};
  var ownedforks = 0;
  var ownedwatchers = 0;
  var forkedrepos = 0;
  values.forEach(function(doc) {
    if (doc.language && !doc.fork) {
      ownedrepos++;
      ownedforks += doc.forks;
      ownedwatchers += doc.watchers;
      if (!ownedlanguages.hasOwnProperty(doc.language)) {
        ownedlanguages[doc.language] = 0;//must be 0 since it gets incremented later
        ownedlangs++;
      }
      ownedlanguages[doc.language]++;
    } else {
      forkedrepos++;
    }
  });
  if (ownedrepos > 0) {
    return {
      ownedlangs: ownedlangs,
      ownedrepos: ownedrepos,
      ownedlanguages: ownedlanguages,
      ownedforks: ownedforks,
      ownedwatchers: ownedwatchers,
      forkedrepos: forkedrepos
    };
  }
};
// execure map reduce operation
var op = db.repos.mapReduce(map, reduce, {out: {merge: targetcoll}});
// remove records that contain no relevant data
db[targetcoll].remove({value:null});
