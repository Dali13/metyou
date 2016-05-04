class UnlocksController < Devise::UnlocksController
  
    protected
  
      # The path used after unlocking the resource
    def after_unlock_path_for(resource)
      resource.update cached_failed_attempts: 0, failed_attempts: 0
      super
    end
    
end