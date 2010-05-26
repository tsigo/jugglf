if (typeof JuggLF === "undefined") {
  var JuggLF = {};
}

/**
 * Prompt the user with a string to copy that allows them to whisper someone
 * in WoW for an in-game comparison from JuggyCompare
 */
function wishlistCompare(id) {
    // Whisper, item name
    str = '/w Tsigo compare [' + $('#loot_table_' + id + ' p.posted_info span:first').text() + '],';

    // Build an array of "<Name> <type>" strings
    names = new Array();
    $('#loot_table_' + id + ' table tbody tr').each(function() {
        name     = $(this).find('td.member span.larger a').text();
        priority = $(this).children('td:eq(1)').text().substr(0,3).toLowerCase();
        piece    = (priority == 'nor') ? name : name + ' ' + priority;
        if (jQuery.inArray(piece, names) < 0) {
            names.push(piece);
        }
    });
    str += jQuery.unique(names).join(',');

    prompt("Copy and paste:", str);
}

function attendanceEditLoot(id) {
    loot_row   = '#live_loot_' + id;

    item_name  = $(loot_row + ' > td:nth-child(1) > a').text();
    wow_id     = parseInt($(loot_row + ' > td:nth-child(1) > a').attr('rel').replace(/[^0-9]+/, ''));
    buyer_name = $(loot_row + ' > td:nth-child(2) > a').text();
    loot_type  = $(loot_row + ' > td:nth-child(3)').text();

    // Build the string that the parser expects
    loot_string = ''
    loot_string += (buyer_name == '') ? 'DE' : buyer_name;
    loot_string += (loot_type  == '') ? '' : ' ' + loot_type;
    loot_string += ' - ';
    loot_string += item_name + '|' + wow_id;
    loot_string += "\n";

    // Highlight the text area; focus it
    $('#live_loot_input_text').val($('#live_loot_input_text').val() + loot_string);
    $('#live_loot_input_text').effect('highlight', {}, 500);
    $('#live_loot_input_text').focus();
}

/**
 * Increments all active attendees' attendance by 1 minute in a loop.
 *
 * This won't be _perfectly_ accurate since not every page refresh happens at 0
 * seconds of every minute, but for our purposes it will be a close-enough estimation.
 */
function attendanceIncrement() {
    setTimeout(function() {
        $('.live_attendee.active').each(function() {
            minutes = parseInt($(this).find('td:nth-child(3)').text());
            $(this).find('td:nth-child(3)').text(minutes + 1);
        });

        attendanceIncrement();
    }, 60000);
}
