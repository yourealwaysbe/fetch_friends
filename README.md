# Fetch Friends

Extracts contact details (first name, surname, email) from the headers of an
email.  Takes as a command line argument a program to be run on the discovered
contacts.  E.g. a script to add them to custom address book.

E.g.  an example script add_vcard.sh is provided which takes the arguments

    add_vcard.sh <name> <surname> <email>

and adds the contact to a vcard file.  Running fetch_friends.rb on an email
(piped through STDIN) will result in

   0: Holly +++ Herndon +++ h.herndon@googlemail.com
   1: Johan +++ Surrballe Wieth +++ weith@iceage.sg
   2: Cleo +++ Tucker +++ cleo@last.fm
   3: Corin +++ Tucker +++ tucker@digmeout.com
   Which to add? ('y[e]' all, 'n' none, or '1[e] 4[e] 5-7[e]', optional 'e' to edit)

The user can select which to add, optionally editing them.  E.g.

    1-3

to add numbers 1, 2, and 3.  This will result in the add_vcard.sh command being
called on all three, adding them to the vcard file.

## Requires 

* [Ruby](https://www.ruby-lang.org/)
* [Ruby Mail](https://rubygems.org/gems/mail/versions/2.6.3)

## Setup For Mutt

To use with Mutt -- supposing you copy the scripts to ~/bin/ and want to run
add_vcard.sh on all found contacts -- add the following line to your muttrc:

    macro pager,index \Ca ":exec pipe-message<enter>~/bin/fetch_friends.rb ~/bin/add_vcard.sh<enter>"

Then just press ctrl-a on an email.

You might also want to add

    set pipe_decode = yes
