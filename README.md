Anagram Solver
==============

This is a first attempt.

[![Build Status](https://secure.travis-ci.org/richrace/anagram-solver-first.png)](http://travis-ci.org/richrace/anagram-solver-first/)

To run do the following:

    bundle
    rake db:setup
    rails server

Then navigate to: http://localhost:3000

To run the tests do the following:

    rake spec


## Notes

Used Ruby hash to find anagrams rather than using db to store a sorted word as an index. Using the db may provide faster searching of anagrams but adds complexity to the project. Therefore, as performance isn't a hard requirement the times for loading and searching a file with 100k+ words is acceptable.

Time recorded for the Loading of the dictionary file is just for parsing and not inserting into the database.

Estimated time 2 to 3 days.

## Assumptions

It's assumed that data would be required at a later point. Therefore, dictionary objects are not deleted when a new dictionary is added. Previous Search objects are also kept.

You cannot merge two dictionaries together. They are standalone. 

You can only search the current file you've uploaded from your session. 

Dictionaries are only available to the current session that uploaded them.

Results + Dictionary are wiped when the session ends (via clearing of a cookie)

