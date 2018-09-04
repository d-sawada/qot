Dir[File.join(Rails.root, "constants", "*.rb")].each { |l| require l }
