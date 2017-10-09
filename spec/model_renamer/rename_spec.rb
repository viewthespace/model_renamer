describe Rename do
  around do |example|
    MemFs.activate { example.run }
  end

  describe 'rename ClientCompany to Account' do
    def client_company_model_content
      <<~HEREDOC
        class ClientCompany
        end
      HEREDOC
    end

    def client_company_controller_content
      <<~HEREDOC
        class ClientCompanyController < ApplicationController
        end
      HEREDOC
    end

    def account_model_content
      <<~HEREDOC
        class Account
        end
      HEREDOC
    end

    def account_controller_content
      <<~HEREDOC
        class AccountController < ApplicationController
        end
      HEREDOC
    end

    def client_company_manager_import_users_service_content
      <<~HEREDOC
        class ClientCompanyManager::ImportUsersService
          def initialize client_company
            @client_company = client_company
          end
        end
      HEREDOC
    end

    def account_manager_import_users_service_content
      <<~HEREDOC
        class AccountManager::ImportUsersService
          def initialize account
            @account = account
          end
        end
      HEREDOC
    end

    def client_company_user_model_content
      <<~HEREDOC
        class ClientCompanyUser < ActiveRecord::Base
          belongs_to :client_company
          belongs_to :user
        end
      HEREDOC
    end

    def account_user_model_content
      <<~HEREDOC
        class AccountUser < ActiveRecord::Base
          belongs_to :account
          belongs_to :user
        end
      HEREDOC
    end

    def client_company_service_js_content
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

    def account_service_js_content
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

    def client_company_manager_translation_yml_content
      <<~HEREDOC
        en-us:
          views:
            client_company_manager:
              tenant_dedupe:
                tenant_dedupe_tool: Tenant Dedupe Tool
                potential_duplicates: Potential Duplicates
      HEREDOC
    end

    def account_manager_translation_yml_content
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
end
