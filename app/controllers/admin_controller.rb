class AdminController < ApplicationController
    before_action :have_secret
    before_action :has_bool_state, only:[
        :set_sharding,
        :set_return_ids,
        :set_enable_bulb,
        :set_queue_changes,
    ]

    # example: curl 'localhost:3000/admin/toggle_sharding?trustme=puppies4eva'
    def toggle_sharding
        Rails.application.config.allow_sharding = !Rails.application.config.allow_sharding
        render :get_sharding
    end

    # example curl 'localhost:3000/admin/set_sharding?trustme=puppieva&state=false' -v
    # example curl 'localhost:3000/admin/set_sharding?trustme=puppieva&state=true' -v
    def set_sharding
        Rails.application.config.allow_sharding = params[:state]
        render :get_sharding
    end

    def get_sharding
    end

    # example: curl 'localhost:3000/admin/toggle_return_ids?trustme=puppies4eva'
    def toggle_return_ids
        Rails.application.config.return_ids = !Rails.application.config.return_ids
        render :get_return_ids
    end

    # example curl 'localhost:3000/admin/set_return_ids?trustme=puppieva&state=false' -v
    # example curl 'localhost:3000/admin/set_return_ids?trustme=puppieva&state=true' -v
    def set_return_ids
        Rails.application.config.return_ids = params[:state]
        render :get_return_ids
    end

    def get_return_ids
    end

    # example: curl 'localhost:3000/admin/toggle_enable_bulb?trustme=puppies4eva'
    def toggle_enable_bulb
        Rails.application.config.enable_bulb = !Rails.application.config.enable_bulb
        render :get_enable_bulb
    end

    # example curl 'localhost:3000/admin/set_enable_bulb?trustme=puppieva&state=false' -v
    # example curl 'localhost:3000/admin/set_enable_bulb?trustme=puppieva&state=true' -v
    def set_enable_bulb
        Rails.application.config.enable_bulb = params[:state]
        render :get_enable_bulb
    end

    def get_enable_bulb
    end

    # example: curl 'localhost:3000/admin/toggle_queue_changes?trustme=puppies4eva'
    def toggle_queue_changes
        Rails.application.config.queue_changes = !Rails.application.config.queue_changes
        render :get_queue_changes
    end

    # example curl 'localhost:3000/admin/set_queue_changes?trustme=puppieva&state=false' -v
    # example curl 'localhost:3000/admin/set_queue_changes?trustme=puppieva&state=true' -v
    def set_queue_changes
        Rails.application.config.queue_changes = params[:state]
        render :get_queue_changes
    end

    def get_queue_changes
    end

    # example curl 'localhost:3000/admin/set_queue_delay?trustme=puppieva&delay=0.6' -v
    def set_queue_delay
        new_delay = params[:delay].to_f
        if new_delay == 0
            head :bad_request
        else
            Rails.application.config.queue_delay = new_delay
            render :get_queue_delay
        end
    end

    def get_queue_delay
    end

    private

    # allow the secret to show up on the URL or as a header
    def have_secret
        tmurl = params[:trustme]
        tmheader = request.headers["HTTP_X_TRUSTME"]
        secret = Rails.application.config.admin_secret
        logger.info "checking tmurl #{tmurl}, tmheader #{tmheader}, secret #{secret}"
        if !(tmurl == secret or tmheader == secret)
            head :unauthorized
        end
    end

    # enforce that state exists and is a boolean for setting sharding
    def has_bool_state
        params.require(:state)
        if ! params[:state].in? ["true", "false"]
            head :bad_request
        end
        params[:state] = ActiveModel::Type::Boolean.new.cast(params[:state])
    end
end
