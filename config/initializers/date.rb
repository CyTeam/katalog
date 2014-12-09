# encoding: UTF-8

# Monkey patch from https://rails.lighthouseapp.com/projects/8994/tickets/340-yaml-activerecord-serialize-and-date-formats-problem
# is used for paper trail
class Date                    # reopen Date class
  def to_yaml(opts = {})      # modeled after yaml/rubytypes.rb in std library
    YAML.quick_emit(self, opts) do |out|
      out.scalar('tag:yaml.org,2002:timestamp', to_s(:db), :plain)
    end
  end
end
