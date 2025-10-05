# Ensure vite_ruby is loaded early so helpers/constants are defined
begin
  require 'vite_ruby'
rescue LoadError => e
  Rails.logger.warn "vite_ruby gem not loaded: #{e.message}"
end
