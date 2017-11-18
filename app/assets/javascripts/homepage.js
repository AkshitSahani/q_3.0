$(document).on("ready", function(){

  $('.owl-carousel').owlCarousel({
      loop:true,
      nav:false,
      responsive:{
          0:{
              items:1
          },
          600:{
              items:1
          },
          1000:{
              items:1
          }
      }
  })


$(".button-collapse").sideNav({
    edge: 'right'
  }
);
  $('ul.tabs').tabs();
  if ($('.song-list').html()) {
    if ($('.song-list').html().trim() === '') {
      $('.search-container').css('display','none');
    }
  }
})
