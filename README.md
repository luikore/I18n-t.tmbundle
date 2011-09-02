# What

Query / Generate Rails I18n Locale for TextMate.

Works for erb, slim and haml.

# Install

Make sure i18n gem is installed.

    cd ~/Library/Application\ Support/TextMate/Bundles
    git clone git://github.com/luikore/I18n-t.tmbundle.git

# Usage

The key is option + L (you can change)

## Query existing message

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/1-1.png "Usage")

Then we get

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/1-2.png "Usage")

## Add a key that translates into selected text

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/2-1.png "Usage")

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/2-2.png "Usage")

Then we get

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/2-3.png "Usage")

and the new key inserted into en.yml in the right position

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/2-4.png "Usage")

## Select a key that translates into selected text

Assume `t('hello.world.title') == t('global') == 'Title'`

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/3-1.png "Usage")

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/3-2.png "Usage")

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/3-3.png "Usage")

Then we get

![Usage](http://github.com/luikore/I18n-t.tmbundle/raw/master/ScreenShots/3-4.png "Usage")

# Ruby 1.9

TextMate support lib is broken in Ruby 1.9.

To replace it for 1.8 and 1.9 compatibilities:

    cd /Applications/TextMate.app/Contents/SharedSupport/Support/
    mv lib lib.bak
    wget cloud.github.com/downloads/luikore/I18n-t.tmbundle/lib.tgz
    tar -zxvf lib.tgz
