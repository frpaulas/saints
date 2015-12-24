// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import {Socket} from "deps/phoenix/web/static/js/phoenix"
let socket = new Socket("/socket")
socket.connect();
let donor = document.getElementById('donor_data')
,   donor_id = "notes:" + donor.getAttribute('data-index')
,   channel = socket.channel(donor_id, {})
,   elmDiv = document.getElementById('elm-main')
,   initialState = {noteList: []} 
,   elmApp = Elm.embed(Elm.NoteSaver, elmDiv, initialState)
channel.join()
  .receive(
    "ok", notes => elmApp.ports.noteList.send(notes))
    // "ok", resp => console.log("CHANNEL JOINED", resp))
  .receive(
    "error", resp => console.log(resp))
channel.on("new:notes", notes=> console.log("CHANNEL ON", notes))