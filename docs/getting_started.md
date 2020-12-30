# Getting started

This shall be a quick dive into the possibilities of this layer.
For in-depth configuration please see the other documents in this folder.

## Prepare an image

Let's say *normally* you would build `image-foo` in your build, which represents the image(s) you would ship.
Then you need to create an additional image, let's call it `image-foo-dca`, containing

```bitbake
require image-foo.bb
inherit dca
```

## Run the tests

Simply by running `bitbake image-foo-dca -c testimage`, additional tests will be executed and results will be stored in a **meta-sca** compatible format
