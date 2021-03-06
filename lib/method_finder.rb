class MethodFinder
  ARGS = {
    :cycle => [1] # prevent cycling forever
  }

  def self.find(obj, res, *args, &block)
    redirect_streams

    obj.methods.sort.map(&:intern).select do |met|
      o = obj.dup rescue obj
      m = o.method(met)
      if m.arity <= args.size
        a = args.empty? && ARGS.has_key?(met) ? ARGS[met] : args
        m.call(*a, &block) == res rescue nil
      end
    end
  ensure
    restore_streams
  end

  def self.redirect_streams
    @orig_stdout = $stdout
    @orig_stderr = $stderr
    $stdout = File.new('/dev/null', 'w')
    $stderr = File.new('/dev/null', 'w')
  end

  def self.restore_streams
    $stdout = @orig_stdout
    $stderr = @orig_stderr
  end

  private_class_method :redirect_streams, :restore_streams
end

