class ChangelogController < ApplicationController

def recent
    @logs = Changelog.where(succeeded: true).last(50)
    logger.info "got these: #{@logs}"
    render :loglist, status: :ok
end

def pending
    @logs = Changelog.where(succeeded: false).last(50)
    logger.info "got these: #{@logs}"
    render :loglist, status: :ok
end

end
