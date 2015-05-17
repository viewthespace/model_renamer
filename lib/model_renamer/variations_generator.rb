#
# Generates different versions of the model name and pairs them with the ones the should switch into,
# for example [ ['activity_log_iteration', 'deal_stage'], [activityLogIteration, dealStage], ... ]
#
class VariationsGenerator

  def initialize old_name, new_name
    @old_plural = split_into_words old_name.pluralize
    @new_plural = split_into_words new_name.pluralize
    @old_singular = split_into_words old_name
    @new_singular = split_into_words new_name
  end

  def pairs_to_convert
    # Important: plurals have to be applied first in case we are working with irregular pluralizations
    (variations(@old_plural) + variations(@old_singular)).zip (variations(@new_plural) + variations(@new_singular))
  end

  def underscore_variations
    {
      old_name_plural: @old_plural.join('_'),
      new_name_plural: @new_plural.join('_'),
      old_name_singular: @old_singular.join('_'),
      new_name_singular: @new_singular.join('_')
    }
  end

  private

  def split_into_words str
    str.split(/(?=[A-Z])/).map(&:downcase)
  end

  def variations words

    variations_array = []

    # underscore separated (Ruby methods)
    variations_array << words.join('_')

    # dash separated (CSS)
    variations_array << words.join('-')

    # capitalized (ActiveRecord model)
    variations_array << words.map(&:capitalize).join

    # camelCase (JavaScript)
    variations_array << words[1, words.count].map(&:capitalize).unshift(words[0]).join

    # space separated (comments)
    variations_array << words.join(' ')

    # space separated, every word capitalized (comments)
    variations_array << words.map(&:capitalize).join(' ')

    # space separated, first word capitalized (comments)
    variations_array << words[1, words.count].unshift(words[0].capitalize).join(' ')

    # all uppercase, underscore separated (constant)
    variations_array << words.map(&:upcase).join('_')

    variations_array

  end

end
