$(function() {

var regExp = /\d+/
var playlistId = parseInt(regExp.exec(window.location.pathname)[0])

var nextSongId
var nextSongRecord

$.ajax({
  url: '/playlists/' + playlistId + '/next_song',
  method: 'get',
}).done(function(data){
  console.log("getting the first song");
  console.log(data);
  nextSongId = data['song_id'];
  nextSongRecord = data['song_record'];
  setTimeout(function(){DZ.player.playTracks([nextSongId])},3000);
  $.ajax({
    url: '/playlists/' + playlistId + '/update_song_playing?song_id=' + nextSongRecord,
    method: 'get',
  }).done(function(data){
    console.log("Update first song to playing");
    console.log(data);
    $('.que').first().find('.buttons').addClass('hidden');
    $('.que').first().children('a').addClass('hidden');
    $('.que').first().addClass('playing').removeClass('que');
  });
  setTimeout(function(){DZ.Event.subscribe('track_end', function(){
    $.ajax({
      url: '/playlists/' + playlistId + '/update_song?song_id=' + nextSongRecord,
      method: 'get',
    }).done(function(data){
      console.log("getting the next song");
      console.log(data);
      DZ.player.playTracks([data['song_id']]);
      nextSongRecord = data['song_record'];
      $.ajax({
        url: '/playlists/' + playlistId + '/playlist_broadcast',
        method: 'get',
      }).done(function(data){
        console.log('created the latest playlist to send to actioncable');
        console.log(data);
      })
      })
    })},3000);
  })
})
