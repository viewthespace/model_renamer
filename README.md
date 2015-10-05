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

Simply type the following into the command line:

    $ model_renamer OldName NewName
