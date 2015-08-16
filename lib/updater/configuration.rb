require 'yaml'

class Configuration
  attr_reader :yaml
  
  Mirror = Struct.new(:specs_push_url, :source_push_url, :source_clone_url, :gitlab)
  Git = Struct.new(:access_token, :organisation, :endpoint)

  def initialize(path:)
    @yaml = YAML.load_file(path)
  end

  def master_repo
    @yaml['master_repo']
  end

  def pod_items
    @yaml['pod_items']
  end

  def pod_skips
    @yaml['pod_skips']
  end

  def mirror
    context = @yaml['mirror']
    Mirror.new(
      context['specs_push_url'],
      context['source_push_url'],
      context['source_clone_url'],
      gitlab)
  end

  private

  def gitlab
    context = @yaml['mirror']['gitlab']
    Git.new(
      context['acccess_token'],
      context['organisation'],
      context['endpoint'])
  end

end