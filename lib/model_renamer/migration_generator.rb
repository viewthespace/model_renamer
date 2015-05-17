#
# Generates a migration that renames columns and tables
#
class MigrationGenerator

  def initialize(old_name_plural:, new_name_plural:, old_name_singular:, new_name_singular:)
    @old_name_plural = old_name_plural
    @new_name_plural = new_name_plural
    @old_name_singular = old_name_singular
    @new_name_singular = new_name_singular
  end

  def create_migration_file
    path = Rails::Generators.invoke("active_record:migration", [migration_name])[1]
    File.write(path, migration_file_content)
  end

  private

  def migration_file_content
"""class #{migration_name} < ActiveRecord::Migration
  def change
    #{rename_statements.join("\n    ")}
  end
end
"""
  end

  def migration_name
    "Rename#{@old_name_singular.split('_').map(&:capitalize).join}To#{@new_name_singular.split('_').map(&:capitalize).join}"
  end

  # {
  #   "table_1_name" => ["column_1", column_2, ...],
  #   "table_2_name" => ["column_1", column_2, ...],
  #   ...
  # }
  def tables_hash
    @tables_hash ||= Hash[ ActiveRecord::Base.connection.tables.collect { |table| [table, ActiveRecord::Base.connection.columns(table).map(&:name)] } ]
  end

  # [
  #   'rename_column :table_1, :old_name_1, :new_name_1',
  #   'rename_column :table_1, :old_name_2, :new_name_2',
  #   'rename_table :table_1, :new_table_1',
  #   ...
  # ]
  def rename_statements
    @rename_statements ||= tables_hash.map do |table_name, columns|
      columns.map { |column| rename_column(table_name, column) } << rename_table(table_name)
    end.flatten.compact
  end

  def rename_column table_name, column_name
    if column_name.include?(@old_name_plural)
"""if table_exists?(:#{table_name}) && column_exists?(:#{table_name}, :#{column_name})
      rename_column :#{table_name}, :#{column_name}, :#{column_name.gsub(@old_name_plural, @new_name_plural)}
    end
"""
    elsif column_name.include?(@old_name_singular)
"""if table_exists?(:#{table_name}) && column_exists?(:#{table_name}, :#{column_name})
      rename_column :#{table_name}, :#{column_name}, :#{column_name.gsub(@old_name_singular, @new_name_singular)}
    end
"""
    end
  end

  def rename_table table_name
    if table_name.include?(@old_name_plural)
"""if table_exists?(:#{table_name})
      rename_table :#{table_name}, :#{table_name.gsub(@old_name_plural, @new_name_plural)}
    end
"""
    elsif table_name.include?(@old_name_singular)
"""if table_exists?(:#{table_name})
      rename_table :#{table_name}, :#{table_name.gsub(@old_name_singular, @new_name_singular)}
    end
"""
    end
  end

end
