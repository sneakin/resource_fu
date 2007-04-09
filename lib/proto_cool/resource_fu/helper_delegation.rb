# Coming up with a nice DSL that makes this easier to 
# understand has eluded me.
module ProtoCool::ResourceFu::HelperDelegation
  def delegate_helper_methods(opts = {})
    return if opts.empty?
    opts.each do |new_helper, delegated_helper|
      module_eval(<<-EOS, "(__DELEGATED_HELPERS_#{new_helper.to_s}__)", 1)
        def #{new_helper.to_s}(*args)
          #{delegated_helper.to_s}(*args)
        end
        helper_method #{new_helper.to_sym.inspect}
        protected #{new_helper.to_sym.inspect}
      EOS
    end
  end
end
