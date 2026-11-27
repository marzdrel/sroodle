# Build the Vite assets once before the test suite starts. Without this, the
# parallel test workers each try to build them on first render, and the
# builds overwrite each other.
Rake::Task["test:prepare"].enhance do
  next unless Rails.env.test?

  ViteRuby.commands.build || abort("Vite build for tests failed")
end
