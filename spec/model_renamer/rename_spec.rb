describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  describe 'rename Cat to Dog' do
    before do
      File.open('./tmp/cat.rb', 'w') { |f| f.puts "hello world" }
      Rename.new("Cat", "Dog").rename
    end

    it 'renames the file' do
      expect(File.exists?('./tmp/dog.rb')).to be true
    end
  end
end
