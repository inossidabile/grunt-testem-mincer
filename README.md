# grunt-contrib-testem

[![NPM version](https://badge.fury.io/js/grunt-contrib-testem.png)](http://badge.fury.io/js/grunt-contrib-testem)
[![Build Status](https://travis-ci.org/inossidabile/grunt-contrib-testem.png?branch=master)](https://travis-ci.org/inossidabile/grunt-contrib-testem)

> Run tests with Testem in a convenient way:
>
>   * Multi-environment runs :heart:
>   * Out-of-box support for Coffee, Ejs, JST, ... :green_heart:
>   * Built-in support of Mincer :blue_heart:

## Getting Started
This plugin requires Grunt `~0.4.0`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-contrib-testem --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-contrib-testem');
```


## How to use

### Environments and tasks

Within your Grunt configuration you have to define one or more environments that Testem will run with:

```javascript
grunt.initConfig({
  testem: {
    environment1: {
      // List of files to attach
      src: [
        'bower_components/jquery/jquery.js',
        'source/**/*.coffee',
        'spec/helpers/*.coffee',
        'spec/**/*_spec.coffee'
      ],
      // Options that will be passed to Testem
      options: {
        parallel: 8,
        launch_in_ci: ['PhantomJS', 'Firefox', 'Safari'],
        launch_in_dev: ['PhantomJS', 'Firefox', 'Safari']
      }
    },
    environment2: {
      // ...
    }
  }
```

In the example given we pass coffee files straight into the `src` and there's no mistake in that. `grunt-contrib-testem` will chew it for you :godmode:.

There are two modes that you can run tests at:
  * `grunt testem:ci:<environment>` command-line CI mode
  * `grunt testem:run:<environment>` Development mode where Testem watches for modifications of files to rerun tests on your behalf

_The default `grunt testem` task runs all settled environments one by one in CI mode._

### Available options

Every environment can take 4 arguments which are:

  * `src`: the full list of files to run (allows unix glob masks: "path/**/*.*"). Files get included into playground in the order they are listed at the array.
  * `options`: options that get passed to running instance of Testem (they are typically located at Testem config)
  * `assets`: options that can be used to configure internal instance of Mincer preprocessor
  * `report_file`: file path location for the output report file which is produced from running Testem.

#### Testem options

The full list of options you can use to affect Testem instance is available [at Testem documentation](https://github.com/airportyh/testem/blob/master/docs/config_file.md#option-reference).

Note also that you can use JS function as hooks:

```javascript
grunt.initConfig({
  testem: {
    environment1: {
      src: '*.js'
      options: {
        before_tests: function (config, data, callback) {
          data;         // {}
          config;       // ... resulting Testem config
          callback();   // call to finalize hook
        },
        on_change: function (config, data, callback) {
          data;         // {file: '...'}
          config;       // ... resulting Testem config
          callback();   // call to finalize hook
        }
      }
    }
  }
}
```

#### Preprocessor options

  * **assets.port**: port that preprocessing server will listen at (defaults to 7358)
  * **assets.setup**: callback to use to setup instance of mincer. Gets instance of `Mincer.Environment` as a first parameter and `Mincer` itself as a second.

## Advanced usage

Internally `grunt-contrib-testem` is powered by Mincer and it allows you to organize testing of almost any kind of code no matter how exactly it is organized and what preprocessing it requires. This is exactly how it works:

<p align="center">
  <img src="http://f.cl.ly/items/0Q2u2v2c1C1e132R3L33/cloud.png">
</p>

During initialization, plugin setups local Mincer server with project root as an inclusion path. Then it substitutes local paths with URLs served through it. So instead of passing `spec/spec.coffee` to Testem (that will not work obviously), it passes `http://localhost:7358/spec/spec.coffee` and Mincer takes care of the rest. It also intelligently passes proper `watch_files` option to Testem so no worries – autoreload works just fine.

What does it mean in other words? It means you can utilize Mincer during the building of your specs or application files. You can use any directives and any Engines it has to offer you (or even write your own). And all that complexity will work blazing fast thanks to built-in Mincer caching! :scream:

So go ahead, take a look at these samples...

  * [Basic config](https://github.com/inossidabile/grunt-contrib-testem/tree/master/spec/basic)
  * [Handling Mincer includes](https://github.com/inossidabile/grunt-contrib-testem/tree/master/spec/minced)
  * [Custom builder in da area](https://github.com/inossidabile/grunt-contrib-testem/tree/master/spec/custom)
  * [Reporting config](https://github.com/inossidabile/grunt-contrib-testem/tree/master/spec/reporting)

... and hurry up to start using it!

## Kudos

Huge thanks goes to [Toby Ho](https://github.com/airportyh/), the original author of Testem that was one by one accepting my pull-requests and modifications that made such integration possible.

## Maintainers

* Boris Staal, [@inossidabile](http://staal.io)

## License

Copyright 2013 [Boris Staal](http://staal.io)

It is free software, and may be redistributed under the terms of MIT license.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/inossidabile/grunt-contrib-testem/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
