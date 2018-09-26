# redis-users

This app is a simple app meant to be used to build automated test cases.

You can use it online currently in [https://dry-ocean-41976.herokuapp.com](https://dry-ocean-41976.herokuapp.com).

## Features

* You can create Lists and Users
* This app deletes Lists and Users 30 minutes after its creating
* You have to create a List before creating Users
* A User has only Name, Email, and Password
* It is possible to create, update, and delete a User
* After the registration of a User in the List, it is also possible to Login using email and password
* Registration of a User in a list should not influence Users in other Lists

Take a look at the automated test file for this app in `spec/lists_spec.rb`.

## Running

Setup:

```terminal
docker-compose run --rm -u root app bash -c "mkdir -p /bundle/vendor && chown ruby /bundle/vendor"
docker-compose run --rm app bundle install
```

See `bin/setup`.

Run:

```terminal
$ docker-compose up app
```

And go to [localhost:3000](http://localhost:3000).
