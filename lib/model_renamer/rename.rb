#
# Uses VariationsGenerator output to first change all the occurences of the model name in the files,
# then to create new directories and rename files. Then uses MigrationGenerator to create a migration
#
class Rename
  ACCEPTABLE_FILE_TYPES = [
    'js', 'coffee', 'hamlc', 'skim', 'erb',
    'sass', 'scss', 'css', 'rb', 'slim',
    'haml', 'rabl', 'html', 'txt', 'feature',
    'rake', 'json', 'sh', 'yaml', 'sql', 'yml', 'csv'
  ].map(&:freeze)

  def initialize old_name, new_name, opts = {}
    @variations_generator = VariationsGenerator.new(old_name, new_name)
    @opts = opts
  end

  def rename_and_generate_migrations
    rename
    generate_migrations
  end

  def rename
    rename_files_and_directories
    rename_in_files
  end

  def generate_migrations
    MigrationGenerator.new(@variations_generator.underscore_variations).create_migration_file
  end

  def rename_files_and_directories
    rename_files
    rename_directories
  end

  def rename_in_files
    all_filepaths.each do |filepath|
      replace_all_variations_in_file filepath
    end
  end

  private

  def variation_pairs
    @variation_pairs ||= @variations_generator.pairs_to_convert
  end

  def all_filepaths
    Find.find('.').to_a.reject do |path|
      FileTest.directory?(path) || !acceptable_filetype?(path) || ignore_file?(path) || !File.file?(path)
    end
  end

  def acceptable_filetype? path
    ACCEPTABLE_FILE_TYPES.include? path.split('.').last
  end

  def ignore_file? path
    Array(@opts[:ignore_paths]).any? do |ignore_path|
      path.include? ignore_path
    end
  end

  def replace_all_variations_in_file filepath
    variation_pairs.each do |variation|
      replace_in_file filepath, variation[0], variation[1]
    end
  end

  def replace_in_file filepath, old_string, new_string
    old_text = File.read(filepath)
    if old_text.include? old_string
      new_text = old_text.gsub(old_string, new_string)
      File.open(filepath, "w") { |file| file.puts new_text }
    end
  end

  def rename_files
    all_filepaths.product(variation_pairs).each do |filepath, (old_name, new_name)|
      next unless File.basename(filepath).include? old_name
      filename = File.basename(filepath)
      File.rename filepath, filepath.gsub(filename, filename.gsub(old_name, new_name))
    end
  end

  def rename_directories
    all_filepaths.product(variation_pairs).each do |filepath, (old_name, new_name)|
      next unless File.file?(filepath) && File.dirname(filepath).include?(old_name)
      FileUtils.mv File.dirname(filepath), File.dirname(filepath).gsub(old_name, new_name)
    end
  end
end
