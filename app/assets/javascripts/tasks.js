window.Tasks = {};

Tasks.setupTaskIconSelection = function() {
    $(".radio-task-icon").change(function() {
        $(".task-icon-selection label img").removeClass("selected-task-icon");
        Tasks.selectIcon($(this));
    });
};

Tasks.initialTaskIconSelection = function() {
    var firstIconId = $(".task-icon-selection-container").data("icon-id");

    if (firstIconId) {
        Tasks.selectIcon($("#radio-task-icon-" + firstIconId));
    }
    Tasks.setupTaskIconSelection();
};

Tasks.selectIcon = function(element) {
    element.siblings().find("img").addClass("selected-task-icon");
};

$(function() {
    Tasks.initialTaskIconSelection();
});
