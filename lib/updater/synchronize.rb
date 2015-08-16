require 'open-uri'
require 'tmpdir'
require 'openssl'

module PodLocalize
  class Command
    class Synchronize < Command
      self.command = 'sync'
      self.summary = 'Synchronize the public CocoaPods repository with your mirror'

      self.arguments = [
        CLAide::Argument.new('CONFIG', :true),
      ]

      def initialize(argv)
        p '==init====='
        @yml_path = argv.shift_argument
      end

      def validate!
        raise Informative, "Please specify a valid CONFIG path" unless @yml_path
      end

      def setup(temp_path:)
        @config = Configuration.new(path: @yml_path)
        p '==dependencies white list====='
        @master_specs = Specs.new(path: File.join(temp_path, 'master'), whitelist: dependencies, specs_root: 'Specs')
        @internal_specs = Specs.new(path: File.join(temp_path, 'local'))
        @skipped_pod_items = skipped_pods
        p '@skipped_pod_items'
        p  @skipped_pod_items
      end

      def bootstrap
        @internal_specs.git.clone(url: @config.mirror.specs_push_url)
        @master_specs.git.clone(url: @config.master_repo, options: '. --depth 1')
      end

      def update_specs
        @internal_specs.merge_pods(@master_specs.pods)

        @internal_specs.pods.each do |pod|
          pod.versions.each do |version|
            if version.contents["source"]["git"]
              pod_name = pod_new_name(pod_name: pod.name)
              version.contents["source"]["git"] = "#{@config.mirror.source_clone_url}/#{pod_name.downcase}.git"
            end
          end
          pod.save
        end
        @internal_specs.git.commit(message: commit_message)
        @internal_specs.git.push
      end

      def commit_message
        time_str = Time.now.strftime('%c')
        "Update #{time_str}"
      end

      def update_sources(temp_path:)
        @master_specs.pods.each do |pod|
          # 判断是不是要跳过 Pod Git Mirror
          
          if @skipped_pod_items.include?(pod.name)
            p '判断是不是要跳过 Pod Git Mirror'
            p pod.name

            return
          end

          p '====================='

          # 更新 Podname
          pod_name = pod_new_name(pod_name: pod.name)

          pod.git.path = File.join(temp_path, 'source_cache', pod_name)
          pod.git.clone(url: pod.git_source, options: ". --bare")

          p '====create_gitlab_repocr====='

          pod.git.create_gitlab_repo(
            access_token: @config.mirror.gitlab.access_token,
            org: @config.mirror.gitlab.organisation,
            name: pod_name,
            endpoint: @config.mirror.gitlab.endpoint
          )
          
          p pod.git.path
          p "==#{@config.mirror.source_push_url}/#{pod_name.downcase}.git"
          
          pod.git.set_origin(url: "#{@config.mirror.source_push_url}/#{pod_name.downcase}.git")
          # pod.git.push(remote: nil, options: '--mirror')
          pod.git.push(remote: nil, options: '--tags')
        end
      end

      def dependencies
        pods_dependencies = []

        p '==@config.pod_items'
        p @config.pod_items

        @config.pod_items.each do |pod_item|
          p '==pod_imte'
          p pod_item
          
          pods_dependencies << pod_item

          p '==pods_dependencies'
          p pods_dependencies
        end

        b = pods_dependencies.uniq
        return b
      end

      def skipped_pods
        p 'skipped_podsskipped_podsskipped_podsskipped_podsskipped_podsskipped_podsskipped_pods'
        skipped_pod_items = []

        p @config.pod_skips

        @config.pod_skips.each do |pod_item|
          skipped_pod_items << pod_item
        end

        b = skipped_pod_items.uniq
        return b
      end

      def pod_new_name(pod_name:)
        p '==origin pod name'
        pod_name.gsub!('+','-')

        p '==new pod_name'
        p pod_name

        return pod_name
      end

      def run
        Dir.mktmpdir do |dir|
          p '==run setup'
          self.setup(temp_path: dir)
          self.bootstrap
          self.update_specs
          self.update_sources(temp_path: dir)
        end
      end

    end
  end
end
