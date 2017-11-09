$('document').ready(function(){

  $('#facebook-button').on('click', function(e) {
    e.preventDefault();

    console.log('hey there');
    window.location = "/auth/facebook";
  })

});
