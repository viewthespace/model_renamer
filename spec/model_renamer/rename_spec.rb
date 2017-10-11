describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  before(:all) do
    # Need this because MemFs doesn't behave properly with Dir['./*'] but works fine with Dir['/*']
    Rename::DEFAULT_PATH = ''
  end

  describe '#run' do
    let(:client_company_model_content) do
      <<~HEREDOC
        class ClientCompany
        end
      HEREDOC
    end

    let(:client_company_controller_content) do
      <<~HEREDOC
        class ClientCompanyController < ApplicationController
        end
      HEREDOC
    end

    let(:account_model_content) do
      <<~HEREDOC
        class Account
        end
      HEREDOC
    end

    let(:account_controller_content) do
      <<~HEREDOC
        class AccountController < ApplicationController
        end
      HEREDOC
    end

    let(:client_company_manager_import_users_service_content) do
      <<~HEREDOC
        class ClientCompanyManager::ImportUsersService
          def initialize client_company
            @client_company = client_company
          end
        end
      HEREDOC
    end

    let(:account_manager_import_users_service_content) do
      <<~HEREDOC
        class AccountManager::ImportUsersService
          def initialize account
            @account = account
          end
        end
      HEREDOC
    end

    let(:client_company_user_model_content) do
      <<~HEREDOC
        class ClientCompanyUser < ActiveRecord::Base
          belongs_to :client_company
          belongs_to :user
        end
      HEREDOC
    end

    let(:account_user_model_content) do
      <<~HEREDOC
        class AccountUser < ActiveRecord::Base
          belongs_to :account
          belongs_to :user
        end
      HEREDOC
    end

    let(:client_company_service_js_content) do
      <<~HEREDOC
        angular.module("vts").factory("ClientCompanyService", (DataCache, queryStringSerializer) => {
          return new (class ClientCompanyService extends DataCache {
            findAll() {
              if (!this.clientCompanies) {
                return super.findAll({ client_company_manager: true }).then((results) => {
                  this.clientCompanies = results;
                  this.selectedClientCompany = this.clientCompanies[0];
                });
              }
            }

            setSelectedClientCompany(id) {
              this.selectedClientCompany = this._findClientCompanyById(id);
            }

            _clientCompanyIds() {
              return _.map(this.clientCompanies, "id");
            }

            _findClientCompanyById(id) {
              return _.find(this.clientCompanies, { id });
            }

            _getCollectionPath(params) {
              return `/api/horse/client_companies?${queryStringSerializer.serialize(params)}`;
            }
        })};
      HEREDOC
    end

    let(:account_service_js_content) do
      <<~HEREDOC
        angular.module("vts").factory("AccountService", (DataCache, queryStringSerializer) => {
          return new (class AccountService extends DataCache {
            findAll() {
              if (!this.accounts) {
                return super.findAll({ account_manager: true }).then((results) => {
                  this.accounts = results;
                  this.selectedAccount = this.accounts[0];
                });
              }
            }

            setSelectedAccount(id) {
              this.selectedAccount = this._findAccountById(id);
            }

            _accountIds() {
              return _.map(this.accounts, "id");
            }

            _findAccountById(id) {
              return _.find(this.accounts, { id });
            }

            _getCollectionPath(params) {
              return `/api/horse/accounts?${queryStringSerializer.serialize(params)}`;
            }
        })};
      HEREDOC
    end

    let(:client_company_manager_translation_yml_content) do
      <<~HEREDOC
        en-us:
          views:
            client_company_manager:
              tenant_dedupe:
                tenant_dedupe_tool: Tenant Dedupe Tool
                potential_duplicates: Potential Duplicates
      HEREDOC
    end

    let(:account_manager_translation_yml_content) do
      <<~HEREDOC
        en-us:
          views:
            account_manager:
              tenant_dedupe:
                tenant_dedupe_tool: Tenant Dedupe Tool
                potential_duplicates: Potential Duplicates
      HEREDOC
    end
    let(:migration_generator_mock) { instance_double(MigrationGenerator) }

    before do
      expect(migration_generator_mock).to receive(:create_migration_file)
      expect(MigrationGenerator).to receive(:new).and_return(migration_generator_mock)

      FileUtils.mkdir_p './app/models'
      FileUtils.mkdir_p './app/controllers'
      FileUtils.mkdir_p './app/services/client_company_manager'
      FileUtils.mkdir_p './app/assets/javascripts/horse/services/client-company-manager'
      FileUtils.mkdir_p './config/locales/views'

      File.open('./app/models/client_company.rb', 'w') { |f| f.write client_company_model_content }
      File.open('./app/models/client_company_user.rb', 'w') { |f| f.write client_company_user_model_content }
      File.open('./app/controllers/client_companies_controller.rb', 'w') { |f| f.write client_company_controller_content }
      File.open('./app/services/client_company_manager/import_users_service.rb', 'w') { |f| f.write client_company_manager_import_users_service_content }
      File.open('./app/assets/javascripts/horse/services/client-company-manager/client-company-service.js', 'w') { |f| f.write client_company_service_js_content }
      File.open('./config/locales/views/client_company_manager.en-us.yml', 'w') { |f| f.write client_company_manager_translation_yml_content }

      Rename.new("ClientCompany", "Account").run
    end

    it 'renames the directories' do
      expect(File.directory?('./app/assets/javascripts/horse/services/client-company-manager')).to be false
      expect(File.directory?('./app/services/client_company_manager')).to be false
    end

    it 'renames the file' do
      expect(File.exist?('./app/models/account.rb')).to be true
      expect(File.exist?('./app/models/account_user.rb')).to be true
      expect(File.exist?('./app/controllers/accounts_controller.rb')).to be true
      expect(File.exist?('./app/services/account_manager/import_users_service.rb')).to be true
      expect(File.exist?('./app/assets/javascripts/horse/services/account-manager/account-service.js')).to be true
      expect(File.exist?('./config/locales/views/account_manager.en-us.yml')).to be true
    end

    it 'changes ClientCompany to Account' do
      expect(File.read('./app/models/account.rb')).to eq(account_model_content)
      expect(File.read('./app/models/account_user.rb')).to eq(account_user_model_content)
      expect(File.read('./app/controllers/accounts_controller.rb')).to eq(account_controller_content)
      expect(File.read('./app/services/account_manager/import_users_service.rb')).to eq(account_manager_import_users_service_content)
      expect(File.read('./app/assets/javascripts/horse/services/account-manager/account-service.js')).to eq(account_service_js_content)
      expect(File.read('./config/locales/views/account_manager.en-us.yml')).to eq(account_manager_translation_yml_content)
    end
  end

  describe 'options hash' do
    let(:client_company_migration_content) do
      <<~HEREDOC
        class AddClientCompanyToDeals < ActiveRecord::Migration
          def change
            add_column :activity_logs, :client_company_id, :integer
          end
        end
      HEREDOC
    end

    let(:account_migration_content) do
      <<~HEREDOC
        class AddAccountToDeals < ActiveRecord::Migration
          def change
            add_column :activity_logs, :account_id, :integer
          end
        end
      HEREDOC
    end
    let(:migration_generator_mock) { instance_double(MigrationGenerator) }

    before do
      expect(migration_generator_mock).to receive(:create_migration_file)
      expect(MigrationGenerator).to receive(:new).and_return(migration_generator_mock)

      FileUtils.mkdir_p './db/migrate'
      File.open('./db/migrate/add_client_company_to_deals.rb', 'w') { |f| f.write client_company_migration_content }
    end

    context 'when ignore paths options are passed in' do
      let(:ignore_paths) do
        ['db/migrate']
      end

      before do
        Rename.new('ClientCompany', 'Account', ignore_paths: ignore_paths).run
      end

      it 'does not touch the files in the ignore paths' do
        expect(File.exist?('./db/migrate/add_client_company_to_deals.rb')).to be true
        expect(File.read('./db/migrate/add_client_company_to_deals.rb')).to eq(client_company_migration_content)
      end
    end
  end

  describe '#rename_files' do
    let(:client_company_content) do
      <<~DOC
        class ClientCompany
          def initialize
            @client_company = ClientCompany.new
          end
        end
      DOC
    end
    let(:client_company_serializer_content) do
      <<~DOC
        class ClientCompany::V1::ClientCompany
          def initialize
            @client_company = ClientCompany.new
          end
        end
      DOC
    end
    let(:other_content) { 'other' }
    let(:foo_content) { 'client_company' }

    before do
      FileUtils.mkdir_p './app/client_company_manager/'
      FileUtils.mkdir_p './app/serializers/client_company/v1'

      File.open('./app/client_company_manager/other.rb', 'w') { |f| f.write other_content }
      File.open('./app/client_company_manager/client_company.rb', 'w') { |f| f.write client_company_content }
      File.open('./app/serializers/client_company/v1/client_company.rb', 'w') { |f| f.write client_company_serializer_content }
      File.open('./app/foo.rb', 'w') { |f| f.write foo_content }

      Rename.new('ClientCompany', 'Account').rename_files_and_directories
    end

    it 'renames the directories' do
      expect(File.directory?('./app/client_company_manager')).to eq false
      expect(File.directory?('./app/serializers/client_company/v1')).to eq false
    end

    it 'renames files' do
      expect(File.exist?('./app/serializers/account/v1/account.rb')).to be true
      expect(File.exist?('./app/account_manager/account.rb')).to be true
      expect(File.exist?('./app/account_manager/other.rb')).to be true
      expect(File.exist?('./app/foo.rb')).to be true
    end

    it 'does not modify the file content' do
      expect(File.read('./app/foo.rb')).to eq(foo_content)
      expect(File.read('./app/account_manager/other.rb')).to eq(other_content)
      expect(File.read('./app/account_manager/account.rb')).to eq(client_company_content)
      expect(File.read('./app/serializers/account/v1/account.rb')).to eq(client_company_serializer_content)
    end
  end

  describe '#rename_in_files' do
    let(:client_company_content) do
      <<~DOC
        class ClientCompany
        end
      DOC
    end
    let(:client_company_manager_content) do
      <<~DOC
        class ClientCompanyManager::ClientCompany
        end
      DOC
    end
    let(:account_content) do
      <<~DOC
        class Account
        end
      DOC
    end
    let(:account_manager_content) do
      <<~DOC
        class AccountManager::Account
        end
      DOC
    end

    before do
      FileUtils.mkdir_p './client_company_manager'

      File.open('./client_company_manager/client_company.rb', 'w') { |f| f.write client_company_manager_content }
      File.open('./client_company.rb', 'w') { |f| f.write client_company_content }

      Rename.new('ClientCompany', 'Account').rename_in_files
    end

    it 'does not modify the directories or file names' do
      expect(File.exist?('./client_company.rb')).to be true
      expect(File.exist?('./client_company_manager/client_company.rb')).to be true
    end

    it 'renames inside the file' do
      expect(File.read('./client_company.rb')).to eq account_content
      expect(File.read('./client_company_manager/client_company.rb')).to eq account_manager_content
    end
  end
end
