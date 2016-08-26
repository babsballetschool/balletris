## balletris
A ballet-themed tetris.

Build on top of elm-flatris.

## Features

* works on both desktop and mobile
* renders the grid to canvas with `Graphics.Collage`
* preserves the game state in `localStorage`, just try to reload the page while playing!

## Instructions to run

1. Install elm [elm-lang.org/install][install]
2. Clone this repo and `cd` into it
3. Run `elm reactor`
4. Open [localhost:8000/src/Main.elm][local] in the browser

## Instructions to make

1. Execute `make`
2. Execute `publish-game.sh`
3. Visit the [game][game]

## Touch support (tested on iOS)

Add the following meta into `index.html`:
    
```html
<meta name="viewport" content="width=480,user-scalable=0">
```

[install]: http://elm-lang.org/install
[local]: http://localhost:8000/src/Main.elm
[game]: https://dvberkel.github.io/balletris/
