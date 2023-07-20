# AIM

A collection of scripts for  working with Alma. This repository is maintained by the Automation, Indexing, and Metadata department. 

## List of scripts included in this repository

### Send SMS

```
aim sms send
```

This script sends sms messages with the twilio API that are deposited by alma into the SFTP server

### Expire Student Worker Accounts

```
aim student_workers expire_passwords
```

This script expires the passwords of users in the set of student worker
accounts.

### HathiTrust

#### Set Digitizer

```
aim ht set_digitizer
```

Triggers the "Change Physical items information job" on the digifeeds set so
that Statistics Note 1 has the value "umich". This will tell Google that Umich
is the digitizer of the item. 

## Developer setup

1. Run the `init.sh` script. This is not a complicated script. It copies over
   env.example to .env, copies over a precommit hook, builds the image, and
   installs the gems. This script is safe to rerun at any time.

```
`./init.sh`
```

2. Fill out the `.env` file with the real secrets. The `ALMA_API_KEY` will be
   different for each subcommand. (Ex: `student_workers` uses a different key
   than `ht`.)

That's it. 🎉

## Running tests

```
docker-compose run --rm app bundle exec rspec
```

## Developer guidelines

### This repo is for small scripts

Scripts that belong in this repository use the Alma API (or another API) or talk
to the sftp server. They don't have support databases. They don't talk to a
Solr. 

### This repo is for fairly independent scripts

Ideally it should be easy to split this repository into separate microservices.
The scripts should not depend on each other and should certainly not depend on
other subcommands. (ex: the scripts in the `hathi_trust` folder shouldn't depend
on the script in the `student_workers` folder). 

### Adding a new script

Script code goes in the following directory `lib/aim/CATEGORY/ACTION`.
`CATEGORY` is the entity that should get an `ALMA_API_KEY`. It's ok if a
`CATEGORY` only has one `ACTION` script.

For adding script files, follow the pattern that's used for `aim student_workers
expire_passwords`:

* In `lib/aim.rb`
  * `aim/student_workers` is required. 
* In `lib/aim/student_workers.rb`:
  * `aim/student_workers/password_expirer` is required, 
  *  the module `AIM::StduentWorkers` is introduced 
  * all dependecies for scripts in the `aim/student_workers` directory are
    required
* `spec/aim/student_workers/password_expirer_spec.rb` has the tests associated
  with the script.
* `spec/fixtures/student_workers/` has the fixture files associated with the
  tests for the script.
* In `lib/aim/cli.rb`:
  * There's an `AIM::CLI::StduentWorkers` class that has an `expire_passwords`
    method.
  * there's a `student_workers` subcommand defined. 

