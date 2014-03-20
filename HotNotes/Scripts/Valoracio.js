function getEstrelles(valoracio) {
    valoracio /= 2;
    var estrelles = [];
    var partEntera = Math.floor(valoracio);
    var partDecimal = valoracio - partEntera;
    if (partDecimal < 0.25) {
        partDecimal = 0;
    } else if (partDecimal > 0.75) {
        partEntera++;
        partDecimal = 0;
    } else {
        partDecimal = 0.5;
    }

    for (var i = 0; i < partEntera; i++) {
        estrelles.push('full');
    }

    if (partDecimal == 0.5) {
        estrelles.push('half');
    }

    for (var i = estrelles.length; i <= 5; i++) {
        estrelles.push('empty');
    }

    return estrelles;
}