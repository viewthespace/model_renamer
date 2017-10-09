describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  describe 'rename ClientCompany to Account' do
    def client_company_content
      <<~HEREDOC
        class ClientCompany
        end
      HEREDOC
    end

    def account_content
      <<~HEREDOC
        class Account
        end
      HEREDOC
    end

    before do
      File.open('./tmp/client_company.rb', 'w') { |f| f.write client_company_content }
      Rename.new("ClientCompany", "Account").rename
    end

    it 'renames the file' do
      expect(File.exists?('./tmp/account.rb')).to be true
    end

    it 'changes ClientCompany to Account' do
      expect(File.read('./tmp/account.rb')).to eq(account_content)
    end
  end
end
