$('document').ready(function(){

  App.app = App.cable.subscriptions.create('AppChannel', {

    connected: function(){
      console.log("connected");
    },

    disconnected: function(){
      console.log("disconnected");
    },

    received: function(data) {
      console.log(data);
      var userId = parseInt($('.delete_user_id').text());
      var regExp = /\d+/;
      var playlist_id = parseInt(regExp.exec(window.location.pathname)[0]);

      if (data[0].id === playlist_id) {
        if (data[0].public === true) {  //public
          console.log('we are going public');
          $('#make-public').html('Public');
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
          $('#make-public').html('Private');
          $('#make-public').toggleClass('active');
          $('.add-search-container').removeClass('hidden');
          // $('.que').find('.buttons').removeClass('hidden');
          // if (userId != data[2])  { //if guest or viewer
          // $('.song-in-queue').children('a').removeClass('hidden');
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
        }}

        $('.song-list').html('');
        var timeOut = 50;

        data[0].forEach(function(song) {
          if (song.status === "played") {
            var divContainer = $('<div>').attr('class', 'song-in-queue played').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id);
          }
          else if (song.status === "playing") {
            var divContainer = $('<div>').attr('class', 'song-in-queue playing').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id);
          } else if (song.status === "que") {
            var divContainer = $('<div>').attr('class', 'song-in-queue que').attr('data-playlist-id', playlist_id).attr('data-suggested-song-id', song.id).attr('data-deezer-id',song.song_id);
            var span = $('<span>').attr('class',"buttons");
            var buttonUp = $('<button>').attr('type',"button").attr('name','button').attr('class','upvote btn waves-effect waves-light blue lighten-2');
            var buttonDown = $('<button>').attr('type',"button").attr('name','button').attr('class','downvote btn waves-effect waves-light red lighten-2');

            data[3].forEach(function(vote) {
              if ((vote.suggestedsong_id === song.id) && (vote.user_id === userId)){
                if (vote.status === "up"){
                  $(buttonUp).addClass('btn-flat darken-2');

                }
                else {
                  $(buttonDown).addClass('btn-flat darken-2');

                }
                }
              }
            )

            var iconUp = $('<i>').attr('class','material-icons').html('thumb_up');
            var upButton = $(buttonUp).append(iconUp);

            var iconDown = $('<i>').attr('class','material-icons').html('thumb_down');
            var downButton = $(buttonDown).append(iconDown);
          }
        var spanHeart = $('<span>').attr('class','heart');
        var iconHeart = $('<i>').attr('class','fa fa-heart').attr('style','font-size:12px');
        var netVote = $('<span>').attr('class','netvote').attr('id',song.id).html(song.net_vote);

        var heart = $(spanHeart).append(netVote).append(" ").append(iconHeart);



        var votes = $(span).append(upButton).append(" ").append(downButton);
        var divSong = $(divContainer).html(song.name + ' - ' + song.artist);
        var spanAdd = $('<span>').html("<br/>" + ' Added By: ' + song.user_name).addClass('added-by');
        var div_replace = $(divSong).append(spanAdd)

        if ((data[2] === userId) && (song.status != "playing")) {
          $(div_replace).append('<a rel="nofollow" class="delete-song" data-method="delete" href="/playlists/' + playlist_id + '/suggestedsongs/' + song.id + '"> &nbsp Delete </a>').append(votes).append(heart);
        }
        else if ((song.user_id === userId) && song.status === "que") {
          $(div_replace).append('<a rel="nofollow" class="delete-song" data-method="delete" href="/playlists/' + playlist_id + '/suggestedsongs/' + song.id + '"> &nbsp Delete </a>').append(votes).append(heart);
        }
        else {
          $(div_replace).append(votes).append(heart);
        }

        $(div_replace).appendTo('.song-list');
      })
    }


})

  }

)
