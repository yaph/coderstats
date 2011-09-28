Sinatra on OpenShift Express
============================

This git repository helps you get up and running quickly w/ a Sinatra installation
on OpenShift Express.


Running on OpenShift
----------------------------

Create an account at http://openshift.redhat.com/

Create a rack-1.1 application

    rhc-create-app -a sinatra -t rack-1.1

Add this upstream sinatra repo

    cd sinatra
    git remote add upstream -m master git://github.com/openshift/sinatra-example.git
    git pull -s recursive -X theirs upstream master
    
Then push the repo upstream

    git push

That's it, you can now checkout your application at:

    http://sinatra-$yourdomain.rhcloud.com

