# SVGA
Copyright © 2015 Bart Massey

This shell script sets up projectors on a Linux box using
`xrandr`.  The script attempts to set up all video outputs
to mirror the primary output, using the highest common
resolution. For this to work, all outputs must have a common
resolution, and there must be an output marked
primary.

You may specify a desired resolution on the command line (in
which case it will be blindly obeyed), or "off" to turn off
all but the primary output.

Refresh rates are currently ignored, which may be a
defect. Preferred resolutions as indicated by xrandr are
ignored, which is a minor defect.

This code is available under the MIT license. Please see the
file `COPYING` in this distribution for license terms.
