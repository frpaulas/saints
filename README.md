# Saints

The Goal: An open source Donor database

Tools: Elixir, Phoenix, Elm

Currently? Totally under developement, version 0.0.0

If you clone this expecting it to work - well, at this stage of the game, good luck with that.

But as I have to keep track of development somewhere, here it is.

### Current State
+ models
	+ donor
	+ address - donor may have multiple addresses
	+ phone - donor may have multiple phones (including emails & urls)
	+ note - donor may have multiple notes
	+ users - for authentication
+ actions
	+ authentication
		+ login/out
		+ add users
	+ donors
		+ edit name, address, phone, note
		+ add address, phone, note
		
### Next Steps
+ models
	+ groups 
		+ groups have multiple donors, donors have multiple groups
	+ donations
		+ donors have multiple donations
+ actions
	+ add donor from scratch
	+ add/remove groups
	+ add/remove donors from groups
	+ add donations
+ reports
	+ export csv for bulk mailing
	+ donations YTD
	+ other TBD
	

## License

This is licensed under [the MIT license](LICENSE.md).
