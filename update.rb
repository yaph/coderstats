# check whether data exists or is outdated, i.e. older than a week = 604800 seconds
#if ghdata.nil? || now - ghdata['updated'] > 604800
#          if ghdata && ghdata['_id']
#            oid = ghdata['_id']
#            doc[:created] = ghdata['created']
#            ghcoll.update({'_id' => oid}, doc)
#          else
#            # no user data exists so far
#            doc[:created] = now
#            oid = ghcoll.insert(doc)
#          end
#          ghdata = ghcoll.find_one({ :_id => oid })
#        end
#        repos = ghdata['repos']

