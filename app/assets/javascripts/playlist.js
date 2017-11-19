$(document).on("ready", function(){

var regExp = /\d+/;
if(regExp.exec(window.location.pathname) != null) {
  var playlistId = parseInt(regExp.exec(window.location.pathname)[0]);
}

  $(window).scroll( function(){
      /* Check the location of each desired element */
      $('.hideme').each( function(i){
          var bottom_of_object = $(this).offset().top + $(this).outerHeight();
          var bottom_of_window = $(window).scrollTop() + $(window).height();
          /* If the object is completely visible in the window, fade it it */
          if( bottom_of_window > bottom_of_object ){
              $(this).animate({'opacity':'1'},500);
          }
      });
  });

  $('.song-in-queue')
    .on('mouseenter', function(){ $(this).addClass('blue-grey lighten-5') })
    .on('mouseleave', function() { $(this).removeClass(' blue-grey lighten-5') });

  $("body").delegate('.upvote', 'click', function (event){

    var currentVote = parseInt($(this).parents('.buttons').children('.heart').children(".netvote").html());
    console.log(currentVote);
    console.log($(this).siblings('.downvote').hasClass('voted'));

    if ($(this).hasClass("voted")) {
      Materialize.toast("Vote withdrawn!", 3000);
      var netVote = currentVote - 1;
      $(this).parents('.buttons').children('.heart').children(".netvote").html(netVote);

      $(this).removeClass("voted")

    } else {

      if ($(this).siblings('.downvote').hasClass('voted')) {
        var netVote = currentVote + 2;
        $(this).siblings('.downvote').removeClass('voted');
      } else {
        var netVote = currentVote + 1;
      }

      $(this).parents('.buttons').children('.heart').children(".netvote").html(netVote);
      Materialize.toast("Voted Up!", 3000, 'blue');

      $(this).addClass("voted")
      // $(this).removeClass("lighten-2 btn")
      // $(this).siblings('button').removeClass('clicked btn-flat darken-2').addClass('red lighten-2 btn')
    };
  });
  $("body").delegate('.downvote', 'click', function (event){

    var currentVote = parseInt($(this).parents('.buttons').children('.heart').children(".netvote").html());
    console.log(currentVote);

    if ($(this).hasClass("voted"))  {
      Materialize.toast("Vote Withdrawn!", 3000);
      var netVote = currentVote + 1;
      $(this).parents('.buttons').children('.heart').children(".netvote").html(netVote);
//      $(this).addClass("thumb_btn");
      $(this).removeClass("voted")

    } else {

      if ($(this).siblings('.upvote').hasClass('voted')) {
        var netVote = currentVote - 2;
        $(this).siblings('.upvote').removeClass('voted');
      } else {
        var netVote = currentVote - 1;
      }

      Materialize.toast("Voted Down!", 3000, 'red');
      $(this).parents('.buttons').children('.heart').children(".netvote").html(netVote);
      $(this).addClass("voted")
      // $(this).removeClass("lighten-2 btn")
      // $(this).siblings('button').removeClass('clicked btn-flat darken-2').addClass('blue lighten-2 btn')
    };
  });

  $("body").delegate('.delete-song', 'click', function(event){
    console.log('clicked')
    $.ajax({
       url:'/playlists/' + playlistId + '/suggestedsongs/' + $(this).parent().parent().attr('data-suggested-song-id'),
       method:'DELETE'
    }).done(function(data){
        Materialize.toast("Song deleted!", 3000, 'red');
    })
  });

  $("body").delegate('.delete-song-show', 'click', function(event){
    console.log('clicked')
    $.ajax({
       url:'/playlists/' + playlistId + '/suggestedsongs/' + $(this).parent().parent().attr('data-suggested-song-id'),
       method:'DELETE'
    }).done(function(data){
        Materialize.toast("Song deleted!", 3000, 'red');
    })
  });

  //Back to top button

  $('a[href^="#"]').on('click',function (e) {
    e.preventDefault();

    var target = this.hash;
    var $target = $(target);

    $('html, body').stop().animate({
        'scrollTop': $(target).offset().top
    }, 900, 'swing', function() {
        window.location.hash = target;
    });
  });

  // When the user scrolls down 20px from the top of the document, show the button
  window.onscroll = function() {scrollFunction()};

  function scrollFunction() {
      if (document.body.scrollTop > 400 || document.documentElement.scrollTop > 400) {
          document.getElementById("myBtn").style.display = "block";
      } else {
          document.getElementById("myBtn").style.display = "none";
      }
  }

  if ($(window).width() < 600) {
    var closeIcon = $('.icon-close');
    console.log('hello');
    $('.icon-close').html("more_vert").addClass('icon-more');
  }

  $('.icon-more-horiz').on('click', function() {
    // $('.playlist-extras').css('display', 'block');
  })

});
