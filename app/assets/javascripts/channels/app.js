$('document').ready(function(){

  App.app = App.cable.subscriptions.create('AppChannel', {

    connected: function(){
      console.log("connected");
    },

    disconnected: function(){
      console.log("disconnected");
    },

    received: function(data) {
      var userId = parseInt($('.delete_user_id').text());
      var regExp = /\d+/;
      if(regExp.exec(window.location.pathname) != null) {
        var playlist_id = parseInt(regExp.exec(window.location.pathname)[0]);
      }
      console.log(data);
      if (data[0].id === playlist_id) {
        if (data[0].public) {  //public

          $('#make-public').toggleClass('active');
          $('.que').find('.buttons').addClass('hidden');
          if (userId != data[2])  { //if guest or viewer
            $('.add-search-container').addClass('hidden');
            $('.song-in-queue').children('a').addClass('hidden')
          }
          else { //if host
            $('.playing').children('a').addClass('hidden');
          }
        }
        else if (data[0].public === false) { //private
          console.log('we are going private');

          $('#make-public').toggleClass('active');
          $('.add-search-container').removeClass('hidden');
        }
      }

      if (data[0][0].playlist_id === playlist_id) {
      if (data[1] === "restart") {
        console.log('we are in restarting');
        var nextSong = data[0][data[0].length - 1].song_id;
        var nextRecord = data[0][data[0].length - 1].id;
          DZ.player.playTracks([nextSong]);
          $.ajax({
            url: '/playlists/' + playlist_id + '/update_song_playing?song_id=' + nextRecord,
            method: 'get',
          });
          DZ.Event.subscribe('track_end', function(){
            $.ajax({
              url: '/playlists/' + playlist_id + '/update_song?song_id=' + nextRecord,
              method: 'get',
            }).done(function(data){
              console.log('we are updating the song to get the next song for the playlist');
              console.log(data);
              DZ.player.playTracks([data['song_id']]);
              nextRecord = data['song_record'];
              $.ajax({
                url: '/playlists/' + playlist_id + '/playlist_broadcast',
                method: 'get',
              })
              })
            });
        }


        $('.song-list').html('');

        data[0].forEach(function(song) {
          if (song.status === "played") {
            var divContainer = $('<div>').attr('class', 'song-in-queue played').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id).html('<i class="fa fa-check" aria-hidden="true"></i>'+song.name + ' - ' + song.artist);
          }
          else if (song.status === "playing") {
            var divContainer = $('<div>').attr('class', 'song-in-queue playing').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id).html('<i class="fa fa-volume-down" aria-hidden="true"></i>'+song.name + ' - ' + song.artist);
          } else if (song.status === "que") {
            // First 4 star playlist apply pulic-que
            if (data[4].id < 4 ){
              var divContainer = $('<div>').attr('class', 'song-in-queue que public-que').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id).attr('data-deezer-id',song.song_id).html('<i class="fa fa-long-arrow-up" aria-hidden="true"></i>'+song.name + ' - ' + song.artist);
            } else {
              var divContainer = $('<div>').attr('class', 'song-in-queue que').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id).attr('data-deezer-id',song.song_id).html('<i class="fa fa-long-arrow-up" aria-hidden="true"></i>'+song.name + ' - ' + song.artist);
            }

            // var span = $('<span>').attr('class',"buttons");
            // var buttonUp = $('<button>').attr('type',"button").attr('name','button').attr('class','upvote thumb_btn');
            // var buttonDown = $('<button>').attr('type',"button").attr('name','button').attr('class','downvote thumb_btn');

            // data[3].forEach(function(vote) {
            //   if ((vote.suggestedsong_id === song.id) && (vote.user_id === userId)){
            //     if (vote.status === "up"){
            //       $(buttonUp).addClass('voted');

            //     }
            //     else {
            //       $(buttonDown).addClass('voted');

            //     }
            //     }
            //   }
            // )

            // var iconUp = $('<i>').attr('class','material-icons').html('thumb_up');
            // var upButton = $(buttonUp).append(iconUp);

            // var iconDown = $('<i>').attr('class','material-icons').html('thumb_down');
            // var downButton = $(buttonDown).append(iconDown);
          }

            var str_id = String(userId)
            var true_user_id = Number( str_id.slice(0, (str_id.length / 2)) );
            var span = $('<span>').attr('class',"buttons");
            var buttonUp = $('<button>').attr('type',"button").attr('name','button').attr('class','upvote thumb_btn');
            var buttonDown = $('<button>').attr('type',"button").attr('name','button').attr('class','downvote thumb_btn');

            if (data[2] != true_user_id && data[4].public == false) {
              $(buttonUp).addClass('not_active').removeClass('upvote');
              $(buttonDown).addClass('not_active').removeClass('downvote');
            }
            data[3].forEach(function(vote) {
              if ((vote.suggestedsong_id === song.id) && (vote.user_id === userId)){
                if (vote.status === "up"){
                  $(buttonUp).addClass('voted');

                }
                else {
                  $(buttonDown).addClass('voted');

                }
                }
              }
            )

            var iconUp = $('<i>').attr('class','material-icons').html('thumb_up');
            var upButton = $(buttonUp).append(iconUp);

            var iconDown = $('<i>').attr('class','material-icons').html('thumb_down');
            var downButton = $(buttonDown).append(iconDown);
        var spanHeart = $('<span>').attr('class','heart');
        var iconHeart = $('<i>').attr('class','fa fa-heart');
        var netVote = $('<span>').attr('class','netvote').attr('id',song.id).html(song.net_vote);

        var heart = $(spanHeart).append(iconHeart).append(" ").append(netVote);

        console.log(span);
        console.log(upButton);
        console.log(downButton);
        var votes = $(span).append(upButton).append(" ").append(downButton);
        var divSong = $(divContainer);
        var spanAdd = $('<span>').html("<br/>" + ' Added By: <span class=\'song-added-by-user\'>' + song.user_name + '</span>').addClass('added-by');
        var div_replace = $(divSong).append(spanAdd)
        votes.append(heart);
        tempuserid = (data[5]) ? (data[5].id) : ("");
        console.log(data);
        if ( true_user_id == song.user_id || song.user_id == tempuserid ) { // if user created this playlist or add song
          votes.append('<a class="thumb_btn delete_song_btn tooltipped delete-song"><i class="material-icons icon-close">close</i></a>');
        }
        $(div_replace).append(votes);
        //if (song.playlist_id > 4) {

          if ((data[2] === userId) || (song.user_id === userId)) {
            votes.append('<a class="thumb_btn delete_song_btn  delete-song"><i class="fa fa-trash" aria-hidden="true"></i></a>')
          }

          //
          // if (data[4].public == false) {
          //   console.log('did we get here?');
          // $(div_replace).append(votes);
          // }

        //}

        $(div_replace).appendTo('.song-list');

        })
      }
      }
    })
    $(".song-list").ready(function() {
      App.app.received(gon.data_for_request);
    });
  }
)
