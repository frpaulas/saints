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

import socket from "./socket"
let channel = socket.channel("donors:list")

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on('set_donors', data => {
  elmApp.ports.donorLists.send(data.donors)
})

channel.on('ok_donor', data => {
  elmApp.ports.okDonor.send(data.donor)
})

// Hook Up Elm

var elmDiv = document.getElementById('elm-main')
  , initialState = {
      donorLists: { 
        searchName: ""
        , page: {
              totalPages: 0
            , totalEntries: 0
            , pageSize: 0
            , pageNumber: 0
          }
        , donors: []
        }
      , okDonor: {
            id:           0
          , title:        ""
          , firstName:    ""
          , middleName:   ""
          , lastName:     ""
          , nameExt:      ""
          , phone:        []
          , address:      []
          , note:         []
          , hideDetails:  true
          , hideEdit:     true
        }
      }
  , elmApp = Elm.embed(Elm.ElmSaints, elmDiv, initialState)

// now try askign for data

elmApp.ports.requestPage.subscribe(function(pageRequest) {
  channel.push("request_page", pageRequest)
});
elmApp.ports.requestDonorDetail.subscribe(function(donor) {
  console.log("REQUEST DETAILS: ", donor);
  channel.push("request_donor_detail", donor.id)
});
elmApp.ports.updateDonor.subscribe(function(donor) {
  channel.push("update_donor", donor)
})
