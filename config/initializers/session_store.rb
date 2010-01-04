# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_codewave_session',
  :secret      => '46e5ff966cb060bf60959df18a3811ed221f55b371514ca6d7fda186e1a98927750fe583b611e4ca5f0d7c1bd159e3f86663976de482df263157fb4e5730f4fd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
