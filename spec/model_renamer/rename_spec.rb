describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  describe 'rename Cat to Dog' do
    def cat_content
      <<~HEREDOC
        class Cat
        end
      HEREDOC
    end

    def dog_content
      <<~HEREDOC
        class Dog
        end
      HEREDOC
    end

    before do
      File.open('./tmp/cat.rb', 'w') { |f| f.write cat_content }
      Rename.new("Cat", "Dog").rename
    end

    it 'renames the file' do
      expect(File.exists?('./tmp/dog.rb')).to be true
    end

    it 'changes Cat to Dog' do
      expect(File.read('./tmp/dog.rb')).to eq(dog_content)
    end
  end
end
