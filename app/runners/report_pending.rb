# This file prints the number of currently pending writes, updating every tenth of a second

# every so often, print a timestamp along with the count
i = 0
fast_interval = 20 # every 2+ seconds
slow_interval = 600 # every minute, more or less
interval = fast_interval

# keep max / min for the periodic reporting
max = 0
min = 0
while true
    i += 1
    @logs = Changelog.where(processed: false).last(50)
    numlogs = @logs.length
    max = numlogs > max ? numlogs : max
    min = numlogs < min ? numlogs : min
    print "\r"
    print "#{numlogs}              "
    sleep(0.1)
    interval = numlogs == 0 ? slow_interval : fast_interval
    if i >= interval
        now = Time.now
        printf "\r#{now} (current = #{numlogs.to_s.rjust(3)})    (max = #{max.to_s.rjust(3)})    (min = #{min.to_s.rjust(3)})\n"
        max = min = numlogs
        i = 0
    end
end
