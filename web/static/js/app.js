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

channel.on('db_msg', data => {
  elmApp.ports.dbSez.send(data)
})

// Hook Up Elm

var elmDiv = document.getElementById('elm-main')
  , initialState = {
      donorLists: { 
          searchName: ""
        , flash: ""
        , page: {
              totalPages: 0
            , totalEntries: 0
            , pageSize: 0
            , pageNumber: 0
          }
        , donors: []
        , dbMsg: {
              ofType: "ok"
            , text: ""
        }
      }
      , okDonor: {
            id:           -1
          , title:        ""
          , firstName:    ""
          , middleName:   ""
          , lastName:     ""
          , nameExt:      ""
          , aka:          ""
          , phones:       []
          , addresses:    []
          , notes:        []
          , donations:    []
      }
      , dbSez: {
          model:  ""
        , id:     -1
        , donor:  -1
        , ofType: "ok"
        , text:   ""
      }
      }
  , elmApp = Elm.embed(Elm.ElmSaints, elmDiv, initialState)

// now try askign for data

elmApp.ports.requestPage.subscribe(function(pageRequest) {
  channel.push("request_page", pageRequest)
});
elmApp.ports.requestDonorDetail.subscribe(function(donor) {
  channel.push("request_donor_detail", donor.id)
});
elmApp.ports.updateDonor.subscribe(function(donor) {
  console.log("UPDATE DONOR: ", donor);
  if (donor.id < 0) {channel.push("create_donor", donor)}
  else {channel.push("update_donor", donor)}
})
elmApp.ports.deleteDonor.subscribe(function(donor) {
  channel.push("delete_donor", donor)
})
elmApp.ports.updateDonation.subscribe(function(donation) {
  if (donation.id < 0) {channel.push("create_donation", donation)}
  else {channel.push("update_donation", donation)};
})
elmApp.ports.deleteDonation.subscribe(function(donation) {
  channel.push("delete_donation", donation)
}) 
elmApp.ports.updateNote.subscribe(function(note) {
  if (note.id < 0) {channel.push("create_note", note)}
  else {channel.push("update_note", note)};
})
elmApp.ports.deleteNote.subscribe(function(note) {
  channel.push("delete_note", note)
}) 
elmApp.ports.updateAddress.subscribe(function(address) {
  if (address.id < 0) {channel.push("create_address", address)}
  else {channel.push("update_address", address)};
})
elmApp.ports.deleteAddress.subscribe(function(address) {
  channel.push("delete_address", address)
})
elmApp.ports.updatePhone.subscribe(function(phone) {
  if (phone.id < 0) {channel.push("create_phone", phone)}
  else {channel.push("update_phone", phone)};
})
elmApp.ports.deletePhone.subscribe(function(phone) {
  channel.push("delete_phone", phone);
})

