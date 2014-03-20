$.extend($.fn.dataTableExt.oSort, {
    'valoracio-asc': function (a, b) {
        var valA = parseFloat($(a).attr('data-valoracio'));
        var valB = parseFloat($(b).attr('data-valoracio'));

        return compareFloat(valA, valB);
    },
    'valoracio-desc': function (a, b) {
        var valA = parseFloat($(a).attr('data-valoracio'));
        var valB = parseFloat($(b).attr('data-valoracio'));

        return (-1) * compareFloat(valA, valB);
    },
    'datetime-asc': function (a, b) {
        return compareDateTime(a, b);
    },
    'datetime-desc': function (a, b) {
        return (-1) * compareDateTime(a, b);
    }
});

function compareFloat(a, b) {
    if (a < b) return -1;
    else if (a == b) return 0;
    else return 1;
}

function compareDateTime(a, b) {
    var partsA = a.split(' ');
    var dateA = partsA[0].split('/');
    var timeA = partsA[1].split(':');
    var dayA = parseInt(dateA[0]);
    var monthA = parseInt(dateA[1]);
    var yearA = parseInt(dateA[2]);
    var hourA = parseInt(timeA[0]);
    var minuteA = parseInt(timeA[1]);

    var partsB = b.split(' ');
    var dateB = partsB[0].split('/');
    var timeB = partsB[1].split(':');
    var dayB = parseInt(dateB[0]);
    var monthB = parseInt(dateB[1]);
    var yearB = parseInt(dateB[2]);
    var hourB = parseInt(timeB[0]);
    var minuteB = parseInt(timeB[1]);

    if (yearA < yearB) return -1;
    else if (yearA > yearB) return 1;
    else {
        if (monthA < monthB) return -1;
        else if (monthA > monthB) return 1;
        else {
            if (dayA < dayB) return -1;
            else if (dayA > dayB) return 1;
            else {
                if (hourA < hourB) return -1;
                else if (hourA > hourB) return 1;
                else {
                    if (minuteA < minuteB) return -1;
                    else if (minuteA > minuteB) return 1;
                    else return 0;
                }
            }
        }
    }
}