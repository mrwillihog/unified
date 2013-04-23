RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

def load_diffs_from(dir)
  Dir.glob(File.dirname(__FILE__) + '/' + dir + '/*.diff').map {|f| File.read(f) }
end

def valid_diffs
  load_diffs_from("examples/valid")
end

def invalid_diffs
  load_diffs_from("examples/invalid")
end