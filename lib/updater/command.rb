require 'claide'
require 'colored'

module PodLocalize
  class PlainInformative < StandardError
      include CLAide::InformativeError
  end

  class Informative < PlainInformative
    def message
      "[!] #{super}".red
    end
  end

  class Command < CLAide::Command
    require "updater"

    self.abstract_command = true
    self.command = 'pod-localize'
    self.version = '0.1.0'
    self.description = 'Pods Localize'
  end
end
