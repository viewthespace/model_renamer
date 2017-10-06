describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  describe 'rename Cat to Dog' do
    def cat_class_content
      <<~HEREDOC
        class Cat
        end
      HEREDOC
    end

    def cat_controller_content
      <<~HEREDOC
        class CatsController < ApplicationController
          def show
            @cat = Cat.new
          end
        end
      HEREDOC
    end

    def dog_class_content
      <<~HEREDOC
        class Dog
        end
      HEREDOC
    end

    def dog_controller_content
      <<~HEREDOC
        class DogsController < ApplicationController
          def show
            @dog = Dog.new
          end
        end
      HEREDOC
    end

    before do
      FileUtils.mkdir_p './app/models'
      FileUtils.mkdir_p './app/controllers'
      File.open('./app/models/cat.rb', 'w') { |f| f.write cat_class_content }
      File.open('./app/controllers/cats_controller.rb', 'w') { |f| f.write cat_controller_content }
      Rename.new("Cat", "Dog").rename
    end

    it 'renames the files' do
      expect(File.exists?('./app/models/dog.rb')).to be true
      expect(File.exists?('./app/controllers/dogs_controller.rb')).to be true
    end

    it 'changes Cat to Dog' do
      expect(File.read('./app/models/dog.rb')).to eq(dog_class_content)
      expect(File.read('./app/controllers/dogs_controller.rb')).to eq(dog_controller_content)
    end
  end
end
