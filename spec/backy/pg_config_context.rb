RSpec.shared_context "PG Config", shared_context: :metadata do
  let(:pg_host) { "localhost" }
  let(:pg_port) { "5432" }
  let(:pg_password) { "postgres" }
  let(:pg_username) { "postgres" }
  let(:pg_database) { "test" }

  before do
    Backy.configure do |config|
      config.pg_host = pg_host
      config.pg_port = pg_port
      config.pg_database = pg_database
      config.pg_username = pg_username
      config.pg_password = pg_password
    end
  end

  let(:pg_password_env) { "PGPASSWORD='#{pg_password}' " }
  let(:terminate_connection_sql) { "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{pg_database}' AND pid <> pg_backend_pid();" }
  let(:pg_credentials) { " -U #{pg_username} -h #{pg_host} -p #{pg_port}" }
end
