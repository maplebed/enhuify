class ChangelogController < ApplicationController

def recent
    @logs = Changelog.where(processed: true).last(50)
    # logger.info "got these: #{@logs}"
    render :loglist, status: :ok
end

def pending
    @logs = Changelog.where(processed: false).last(50)
    # logger.info "got these: #{@logs}"
    render :loglist, status: :ok
end

end
