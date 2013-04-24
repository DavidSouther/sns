# Stellar Naval Simulator

Take command of a Stellar Naval Vessel (SNV) in a universe with physics from the CoDominium universe. Manage navigation, weapons, science, and more as you lead your crew on various missions ranging from military engagements to interstellar diplomacy to scientific exploration. Earn your place in the admiralty and take on larger missions, eventually controlling armadas and fleets at a galactic level.


For more information, read through the [design docs](https://gist.github.com/DavidSouther/5390171).

## Running

### Production

```
npm start
```

Starts the SNS server normally.


### Development

```
npm run supervise
```

Starts the SNS server with supervise, aka live reload for the server. Any edits to a `.coffee` file in the `lib/server` folder will force the app to restart. This doesn't trigger a live reload, so that still needs a manual reload of the browser.


## Configuration

nconf will load `ini.json`. Each module defines its own defaults for loaded params, but some useful server-level defaults:

* `port` {integer} port to bind. <=1024 will require starting with sudo.
* `replify` {boolean} with dev dependencies, starts a replify socket in `./replify/debugger.sock`
* `livereload` {boolean} with dev dependencies, starts a livereload server
