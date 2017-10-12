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
Rename.new("OldName", "NewName").run
```

This will rename everything in the codebase as well as generate the migrations. If you only want to rename files and directories, run:

```ruby
Rename.new("OldName", "NewName").rename_files_and_directories
```

To only rename within the contents of the files, run:

```ruby
Rename.new("OldName", "NewName").rename_in_files
```

To only generate migrations, you guessed it:

```ruby
Rename.new("OldName", "NewName").generate_migrations
```

## Options

You can pass in parameters to the constructor to specify paths to ignore and the root directory:

```ruby
Rename.new("OldName", "NewName", ignore_paths: ['mailers/'], path: 'app/')
```

This will ignore any files within the `mailers/` directory and search for `OldName` renames starting in the `app/` directory. By default no paths are ignored and the path is the current directory.

## Supported File Types

These are the file types that renamer will search for: `js, coffee, hamlc, skim, erb, sass, scss, css, rb, slim, haml, rabl, html, txt, feature, rake, json, sh, yaml, yml, sql, csv`
