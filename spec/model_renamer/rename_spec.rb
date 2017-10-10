describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  describe 'rename ClientCompany to Account' do
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

    before do
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

      Rename.new("ClientCompany", "Account").rename
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

    before do
      FileUtils.mkdir_p './db/migrate'
      File.open('./db/migrate/add_client_company_to_deals.rb', 'w') { |f| f.write client_company_migration_content }
    end

    context 'when no options are passed in' do
      before do
        Rename.new('ClientCompany', 'Account').rename
      end

      it 'renames client_company to account' do
        expect(File.exist?('./db/migrate/add_account_to_deals.rb')).to be true
        expect(File.read('./db/migrate/add_account_to_deals.rb')).to eq(account_migration_content)
      end
    end

    context 'when ignore paths options are passed in' do
      let(:ignore_paths) do
        {
          ignore_paths: ['db/migrate']
        }
      end

      before do
        Rename.new('ClientCompany', 'Account', ignore_paths).rename
      end

      it 'does not touch the files in the ignore paths' do
        expect(File.exist?('./db/migrate/add_client_company_to_deals.rb')).to be true
        expect(File.read('./db/migrate/add_client_company_to_deals.rb')).to eq(client_company_migration_content)
      end
    end
  end
end
