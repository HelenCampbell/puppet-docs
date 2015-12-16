require 'puppet_references'
require 'git'

module PuppetReferences
  class Repo

    attr_reader :name, :directory, :source, :repo

    def initialize(name, directory, source = nil)
      @name = name
      @directory = directory
      if source
        @source = source
      else
        @source = "git@github.com:puppetlabs/#{@name}.git"
      end
      unless Dir.exist?(@directory + '.git')
        puts "Cloning #{@name} repo..."
        Git.clone(@source, @directory)
        puts 'done cloning.'
      end
      @repo = Git.open(@directory)
    end

    def checkout(commit)
      @repo.fetch
      @repo.checkout(commit, {force: true})
    end

    def update_bundle
      Dir.chdir(@directory) do
        if Dir.exist?(@directory + '.bundle/stuff')
          puts "In #{@name} dir: Running bundle update."
          Bundler.clean_system('bundle update')
        else
          puts "In #{@name} dir: Running bundle install --path .bundle/stuff"
          Bundler.clean_system('bundle install --path .bundle/stuff')
        end
      end
    end

  end
end