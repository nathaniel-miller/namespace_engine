# Rails Namespace Engine
Generate a rails engine with an extra layer of namespacing.

# Introduction

This is a script that first generates a new rails plugin. It is the same as running `rails new plugin my_engine --mountable`.
It then procedes to both add to, and restructure the file directory according to the provided namespace argument.
Lastly, it modifies the necessary files, including the parent app's `Gemfile` and `config/routes.rb` file.

# Installation
There are a couple of ways you can do this: The simplest is to install it as a gem either in a Rails' Gemfile:
```ruby
#Gemfile

gem 'rails_namespace_engine'
```
or from the command line with  `bundle install rails_namespace_engine`.

It can then be run from **within the top level directory of a rails app** using the `namespace_engine` command and two arguments,
a namespace name and an engine name.
```bash
namespace_engine MyNamespace MyEngine
```
or
```bash
namespace_engine my_namespace my_engine
```
Both result in the same thing.

Again, it is important to run the command from the **the top level directory of a rails app** as it references both the
`Gemfile` and the `config/routes.rb` files. If those are not present, the script will err.
<hr>
The Second way of using this script would be to clone this repo and run the script directly.


Assuming `git` is installed:<br />
1.) Fork or clone this repo: `git clone https://github.com/nathaniel-miller/namespace_engine` into the **top level of your rails app**.<br />
2.) From your command line, in the **top level directory** run `rails_namespace_engine/bin/namespace_engine`.<br />

Note: In this script's current state, if you wish to remove the changes it has made:<br>
1.)Delete the `engines/` directory in the top level of your rails app.<br>
2.)Remove the bottom two lines in your app's Gemfile.<br>
3.)Remove the `--mount` line from your rails app's `config/routes.rb` file.<br>



## Contributing

Should you wish to contribute, simply fork this repo, code to your heart's content, and issue a pull request. I will review the changes and, if deemed an improvement, will accept the request.

# License

The MIT License (MIT)

Copyright (c) 2016 Nathaniel Miller


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
