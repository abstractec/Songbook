# Songbook
An iPad app for managing songs for the gigging musician

I made this app because I was very frustrated with the current offerings for iPad apps. I wanted something more structured in its approach and I was tired of the nag-ware from commercial offerings. 

## So What Does It Do?

What sets Songbook apart from other apps is that the data entry is structured into the following elements:

### Song

The top level of what we're trying to display. The song has a number of parts to it, but mainly it contains the top-level information

* Title
* Key

### Section

Think of these as verses, intros, choruses and the like

### Phrase

A musical motif. These contain chords and / or lyrics. 

### Lyrics

The words to a song

### Chord Progression

What chords are played in what order

### Chords

The chords themselves. 

### Playlist

A collection of songs; useful for organising a gig. 

## What's Coming?

First thing is to complete how a song is entered and make it display correctly for the user in a live, gigging situation. 
Then there will be a refactor to remove any of the 'work in progress' items that are no longer used. 
Then there will be the idea of instruments. 
Scrolling of songs will be a thing
Sharing of songs and chords is in progress. 



### Instruments

The current way of managing a song in current apps is to have each musician with their own version of the app. I want to change this so that each musician has their own view of the song. 

How I want to achieve this is by having the idea of "instrumentation" for the songs whereby each song has a Many to Many relationship with an instrument. These instruments will, essentially, relate to an individual, real world instrument. 

As a guitarist, I have a number of guitars and they're all in different tunings. And I will, occasionally, play songs with a Capo at, say, the 3rd fret while the other musicians will not transpose the song. 

What I want to achieve is that when a song is loaded into the playlist, I can select which instrument I want to use and the song will display the chords that are appropriate.

An example of this will be the song "Living in the Past" by Jethro Tull. 

* Guitar one will be an acoustic guitar in normal tuning with a capo at the 3rd fret. 
* Guitar two will be an electric guitar in normal tuning with no capo
* Bass will be an electric bass with no capo

Each musician will be able to select the instrumentation for their performance, and Songbook will adapt the display for them. 

* Guitarist one will have the chords Am / G / D 
* Guitarist two will have the chords Cm / Bb / F
* The bassist will have the chords Cm / Bb / F

# Issues

Current issues are listed here: https://github.com/abstractec/Songbook/issues
This also has the feature requests. 