# ModelRenamer

The model renamer gem allows you to rename any a model in your rails application. The gem looks for occurrences of any variation or pluralization of the old model name and changes it to the corresponding variation of the new name. It also generates database migrations that rename tables and foreign keys referencing the old name.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'model_renamer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install model_renamer

## Usage

Run rails console and use the following command:

```ruby
Rename.new("OldName", "NewName").rename_and_generate_migrations
```

This will rename everything in the codebase as well as generate the migrations. If you only want to rename in the codebase, run:

```ruby
Rename.new("OldName", "NewName").rename
```

To only generate migrations, you guessed it:

```ruby
Rename.new("OldName", "NewName").generate_migrations
```
