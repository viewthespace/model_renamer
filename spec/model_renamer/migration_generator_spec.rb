describe MigrationGenerator do
  after do
    FileUtils.rm_rf('./db')
  end

  let(:tables_and_columns) do
    {
      'client_companies' => ['id'],
      'client_company_users' => ['client_company_id'],
      'activity_logs' => ['client_company_id', 'last_modified_time'],
      'spaces' => ['id'],
      'access_requests' => ['accessible_type']
    }
  end
  let(:tables_and_column_defaults) do
    {
      'client_companies' => { 'id' => nil },
      'client_company_users' => { 'client_company_id' => nil },
      'activity_logs' => { 'client_company_id' => 1,  'last_modified_time' => Date.current },
      'spaces' => { 'id' => nil },
      'access_requests' => { 'accessible_type' => 'ClientCompany' }
    }
  end
  let(:params) do
    {
      old_name_plural: 'client_companies',
      new_name_plural: 'accounts',
      old_name_singular: 'client_company',
      new_name_singular: 'account'
    }
  end
  let(:migration_content) do
    <<~CONTENT
      class RenameClientCompanyToAccount < ActiveRecord::Migration
        def change
          if table_exists?(:client_companies)
            rename_table :client_companies, :accounts
          end

          if table_exists?(:client_company_users) && column_exists?(:client_company_users, :client_company_id)
            rename_column :client_company_users, :client_company_id, :account_id
          end

          if table_exists?(:client_company_users)
            rename_table :client_company_users, :account_users
          end

          if table_exists?(:activity_logs) && column_exists?(:activity_logs, :client_company_id)
            rename_column :activity_logs, :client_company_id, :account_id
          end

          if table_exists?(:access_requests) && column_exists?(:access_requests, :accessible_type)
            change_column_default :access_requests, :accessible_type, 'Account'
          end

        end
      end
    CONTENT
  end

  before do
    allow(ActiveRecord::Base).to receive_message_chain(:connection, :tables).and_return(tables_and_columns.keys)
    tables_and_columns.each do |table, cols|
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :columns).with(table).and_return(cols.map{|col| double(name: col)})
    end
    tables_and_column_defaults.each do |table, defaults|
      stub_const(table.classify, double(column_defaults: defaults))
    end

    described_class.new(params).create_migration_file
  end

  it 'generates a migration file with the expected content' do
    expect(Dir['./db/migrate/*'].count).to eq 1
    expect(Dir['./db/migrate/*_rename_client_company_to_account.rb'].count).to eq 1
    expect(File.read(Dir['./db/migrate/*_rename_client_company_to_account.rb'].first)).to eq(migration_content)
  end
end
