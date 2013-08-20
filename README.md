DspaceTools
===========

[![Continuous Integration Status][1]][2]
[![Dependency Status][3]][4]
[![Coverage Status][5]][6]

Description
-----------

DspaceTools app serves following purposes:

* It simplifies bulk upload to Dspace converting comma-separated lists of 
terms into xml import files compatible with dspace. 

* It adds authentication and authorization to Dspace restful API, hiding 
restricted data from users who are not supposed to see it.

* It adds api_key/api_digest authentication mechanism to restful API


Requirements 
------------

* Ruby v1.9.3 or higher

* Ruby Virtual Machine (rvm) is recommended for development

* Working DSpace with Postgresql in backend

* MySQL database

Running tests
-------------

Look at the content of [.travis.yml][7] in the project directory. 
It is used by continuous integration server to create tests environment.

Install
-------

add ruby lirbraries needed for the project

    gem install bundle 
    bundle
    rake db:create:all
    rake db:migrate #for development
    rake db:migrate RACK_ENV=production #for production
    rake db:migrate RACK_ENV=test #for test

to run it locally

    rackup

to run in production specify production environment before your server
command. For example

   RACK_ENV=production unicorn -c unicorn.conf -D

API description
---------------
[API][8]


[1]: https://secure.travis-ci.org/mbl-cli/DspaceTools.png
[2]: http://travis-ci.org/mbl-cli/DspaceTools
[3]: https://gemnasium.com/mbl-cli/DspaceTools.png
[4]: https://gemnasium.com/mbl-cli/DspaceTools
[5]: https://coveralls.io/repos/mbl-cli/DspaceTools/badge.png
[6]: https://coveralls.io/r/mbl-cli/DspaceTools
[7]: https://github.com/mbl-cli/DspaceTools/blob/master/.travis.yml
[8]: https://github.com/mbl-cli/DspaceTools/wiki/API
