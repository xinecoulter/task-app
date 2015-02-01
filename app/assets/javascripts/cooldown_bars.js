window.CooldownBars = {};

CooldownBars.setupBar = function(bar) {
    var interval = bar.data("interval") * 1000; // convert to milliseconds
    var dueDate = bar.data("due-date") * 1000; // convert to milliseconds

    bar.progressbar({
        value: ( dueDate - new Date($.now()) ),
        max: interval
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

$(function() {
    $(".progress-bar").each(
        function() {
            CooldownBars.setupBar($(this));
        }
    );
});
