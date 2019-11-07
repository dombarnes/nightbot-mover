// Form Selecting
window.setSelectedText = function setSelectedText(selectObj, valueToSet) {
    for (var i = 0; i < selectObj.options.length; i++) if (selectObj.options[i].text == valueToSet) return void (selectObj.options[i].selected = !0);
}
window.setSelectedValue = function setSelectedValue(selectObj, valueToSet) {
    for (var i = 0; i < selectObj.options.length; i++) if (selectObj.options[i].value == valueToSet) return void (selectObj.options[i].selected = !0);
}

window.populateDropdown = function populateDropdown(id, data){
    let dropdown = $(id);
    dropdown.empty();
    dropdown.append('');
    dropdown.prop('selectedIndex', 0);
    $.each(data, function (key, entry) {
        dropdown.append($('<option></option>').attr('value', entry['value']).text(entry['name']).prop('disabled', entry['disabled']));
    })
}

// Confirm dialogs
$(document).ready(function() {
    $("[data-confirm]").click(function(e) {
        confirm(jQuery(this).attr("data-confirm")) || e.preventDefault();
    });
    // jQuery('input[type=submit],button[type=submit]').prop('disabled', true);
});
