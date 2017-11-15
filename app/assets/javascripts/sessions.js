$('document').ready(function(){

  $('#facebook-button').on('click', function(e) {
    e.preventDefault();
    window.location = "/auth/facebook";
  })

});
