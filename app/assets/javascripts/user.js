$(document).on("ready", function(){

  $('.modal').modal({
    startingTop: '20%',
    endingTop: '10%',
  });

  $('.guestlist-playlist').on('click', function(event) {
    var regExp = /\d+/;
    var playlistId = parseInt(regExp.exec(window.location.pathname)[0]);
    event.preventDefault();
    $.ajax({
       url:'/playlists/' + playlistId + '/guestlist',
       method:'GET',
    }).done(function(data) {
      console.log(data);
      $('.guest-list-container ol').html('');
      data.forEach(function(guest){
        if (guest[3] === 'Guest') {
          var li = $('<li>').attr('class','guest').attr("guest-id", guest[2]);
          var span = $('<span>').html(guest[0] + ' ' + guest[1]);
          var guestDelete = $('<button>').html("Block Guest").addClass('btn-flat').addClass('guest-delete')
          var guestdiv = $(li).append(span).append(guestDelete);
          $('.guest-list-container ol').append(guestdiv);
        } else {
          var li = $('<li>').attr('class','guest').attr("guest-id", guest[2]);
          var span = $('<span>').html(guest[0] + ' ' + guest[1]);
          var guestForbidden = $('<button>').html("Unblock Guest").addClass('btn-flat').addClass('guest-delete')
          var guestdiv = $(li).append(span).append(guestForbidden);
          $('.guest-list-container ol').append(guestdiv);
        };
      });
      $('body').delegate('.guest-delete', 'click', function(event) {

        var guestId = parseInt($(this).parents('.guest').attr("guest-id"));

        if ($(this).html()=== "Block Guest") {
          $(this).html('Unblock Guest')
        } else {
          $(this).html('Block Guest')
        }
        $.ajax({
          url: '/playlists/' + playlistId + '/update_authorization',
          method: "POST",
          data: {
            playlist_id: playlistId,
            user_id: guestId
          }
        }).done(function(data) {
        })

      })
    });
  });

  $('.guestlist').on('click', function(event) {
    console.log("clicking guestlist");
    var playlistId = parseInt($(this).parents('.hosted-playlist').attr('playlist-id'))
    event.preventDefault()
    $.ajax({
       url:'/playlists/' + playlistId + '/guestlist',
       method:'GET',
     }).done(function(data) {
       console.log(data);
       $('.guest-list-container ol').html('');
       data.forEach(function(guest){
         if (guest[3] === 'Guest') {
           var li = $('<li>').attr('class','guest').attr("guest-id", guest[2]);
           var span = $('<span>').html(guest[0] + ' ' + guest[1]);
           var guestDelete = $('<button>').html("Block Guest").addClass('btn-flat').addClass('guest-delete')
           var guestdiv = $(li).append(span).append(guestDelete);
           $('.guest-list-container ol').append(guestdiv);
         } else {
           var li = $('<li>').attr('class','guest').attr("guest-id", guest[2]);
           var span = $('<span>').html(guest[0] + ' ' + guest[1]);
           var guestForbidden = $('<button>').html("Unblock Guest").addClass('btn-flat').addClass('guest-delete')
           var guestdiv = $(li).append(span).append(guestForbidden);
           $('.guest-list-container ol').append(guestdiv);
         };
       });
       $('body').delegate('.guest-delete', 'click', function(event) {

         var guestId = parseInt($(this).parents('.guest').attr("guest-id"))
         console.log("[" + playlistId + "," + guestId + "]");
         $.ajax({
           url: '/playlists/' + playlistId + '/update_authorization',
           method: "POST",
           data: {
             playlist_id: playlistId,
             user_id: guestId
           }
         }).done(function(data) {
           console.log('updating');
           if ($('.guest-delete').html()==="Block Guest") {
             console.log('changing to unblock');
             $('.guest-delete').html('Unblock Guest')
           } else {
             console.log('changing to block');
             $('.guest-delete').html('Block Guest')
           }
         })

       })
     });
   });

   $('.purpleButton').on('click', function(e) {
    e.preventDefault();
    $('.loader-div').css('display', 'block');
    $.ajax({
        type: "GET",
        url: "/playlists/new",
        success: function(data){
            $('.loader-div').css('display', 'none');
            $('.hostLoadDiv').html(data).css("display", "block");
        }
    });
   })

   $(document).on('click', '.form-close', function(){
     $('.hostLoadDiv').css('display', 'none');
   });

   $(document).keyup(function(e) {
     if (e.keyCode == 27) { // escape key maps to keycode `27`
      $('.hostLoadDiv').css('display', 'none');
    }
});
});


  // $(document).on('click', '.guest-delete', (function() { //the regular way of .guest-delete on click doesn't work but this does
  //   console.log('deleting guest');
  // }));
  // $('#close').on('click',function(event){
  //   $('.guest-list-container').fadeOut('fast',function(){})
  // })
