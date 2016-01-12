$(document).ready(function() {
    $('.altbg').click(function(event) {
        event.preventDefault();
        var bg = $(this).attr('data');
        $('body').css('background-image', 'url("' + bg + '")');
    });

    $('.altfontweight').click(function(event){
        event.preventDefault();
        var newWeight = $(this).attr('data');
        $('body').css('font-weight', newWeight);
    });

    var version = $('.citation').first().html().replace('- ', '');

    $('.passage h2').each(function() {

        var searchString = $(this).html().replace(' ', '+').toLowerCase();
        var cleanSearchString = searchString.replace('+', '');

        $(this).append('<a class="more-icon" data-toggle="modal" data-target=".modal-' + cleanSearchString + '" href="#"><span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a><div class="modal fade modal-' + cleanSearchString + '" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel"><div class="modal-dialog modal-lg"><div class="modal-content"></div></div></div>');


        $('.modal-' + cleanSearchString).on('show.bs.modal', function(event) {
            var modal = $(this);
            modal.find('.modal-content').html('<iframe class="iframe-'+cleanSearchString+'" src="https://www.biblegateway.com/passage/?search=' + searchString + '&version=' + version + '"></iframe>');
        });



    });





});
