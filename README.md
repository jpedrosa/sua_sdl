SuaSDL
-----

The main idea for this project is to experiment with SDL from Swift, but mostly
as a way to come up with alternative GUIs. The focus of this project is not on
games per se.

SDL is a top graphics library that works on many different platforms and does a
good job of providing the basics for windows, events, OpenGL and much more.
Given the diversity of platforms and the near-monopoly of browser-based UIs, the
SDL is one of the only ways to work around them. The SDL is more multi-purpose,
whereas other libraries may have more specific purposes instead, like the
[Skia](http://skia.org) one.

------------------

As a way not to slow down development, rather than to depend on Sua as an
external, static library, we have added the Sua files directly to the Sources
directory. In effect "inlining" them.

The current snapshot from Sua is this one:

    commit df0d1bc2bffa29e07de12b724be46739990744ec
    [...]
    Date:   Tue Feb 2 23:28:46 2016 -0300

There is also a dependency on the
[CSDL module](https://github.com/jpedrosa/csdl_module) sister project.

Even when you got the CSDL module installed, you may also need to set the
following environment variable so that the SDL library can be loaded:

    export LD_LIBRARY_PATH=/usr/local/lib/

-------------------

You could also check out this previous project based on both Swift and SDL:
https://github.com/jaz303/CSDL2.swift

License
-------

See the [LICENSE](LICENSE.txt) file.
