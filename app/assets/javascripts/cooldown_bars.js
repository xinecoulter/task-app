window.CooldownBars = {};

CooldownBars.setupBar = function(bar) {
    var interval = bar.data("interval") * 1000; // convert to milliseconds
    var dueDate = bar.data("due-date") * 1000; // convert to milliseconds
    var progressLabel = bar.find( ".progress-label" );

    bar.progressbar({
        value: ( dueDate - new Date($.now()) ),
        max: interval,
        change: function() {
            if ( bar.progressbar("value") === 0 ) {
                bar.text( bar.data("task-name") + ": DUE NOW!" );
            } else {
                progressLabel.text( bar.data("task-name") + ": " + CooldownBars.timeLeft( bar.progressbar( "value" )) + " remaining" );
            }
        }
    });

    function progress() {
        var val = bar.progressbar("value") || 0;
        bar.progressbar("value", val - 1000);
        if ( val > 1 ) {
            setTimeout(progress, 1000);
        }
    }
    setTimeout(progress, 0);
};

CooldownBars.timeLeft = function(milliseconds) {
    var totalSeconds = Math.floor(milliseconds / 1000); // convert to seconds
    var days = Math.floor(totalSeconds / 86400); // 1 day ( 24 hrs * 60 min * 60 sec ) = 86400 sec
    var hours = Math.floor((totalSeconds %= 86400) / 3600); // 1 hr ( 60 min * 60 sec ) = 3600 sec
    var minutes = Math.floor((totalSeconds %= 3600) / 60); // 1 min = 60 sec
    var seconds = totalSeconds % 60;
    var secondsText = seconds + " second" + numberEnding(seconds);
    var minutesText = minutes + " minute" + numberEnding(minutes) + " and " + secondsText;
    var hoursText = hours + " hour" + numberEnding(hours) + ", " + minutesText;
    var daysText = days + " day" + numberEnding(days) + ", " + hoursText;

    function numberEnding(number) {
        return (number > 1) ? "s" : "";
    }

    if (days) return daysText;
    if (hours) return hoursText;
    if (minutes) return minutesText;
    if (seconds) return secondsText;
    return "less than a second";
};

$(function() {
    $(".progress-bar").each(
        function() {
            CooldownBars.setupBar($(this));
        }
    );
});
