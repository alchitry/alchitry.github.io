+++
title = "New Site, New Forum, New Alchitry Labs"
date = "2024-03-26"
+++

A lot has happened since the last blog post!

First lets start with the page you're reading this on, the new website!
<!-- more -->
## New Website

As you can tell, the website has been updated. It's in the process of migrating from a Square Space to GitHub Pages. 

Over the years I've used many different platforms for the website. 

Back when we still sold boards directly, it was hosted on Shopify. However, once I no longer needed a shopping card, I moved it to Square Space.

Square Space is fine, but it is kind of a pain to work with their backend to create new pages. Too many times I accidentally hit back on my mouse only to lose all the content I was working on. I started writing everything locally then moving it to the site only after I was done.

Another major pain point I've always had was using html tags to format the pages. All the code blocks you see on the old website were typed `<pre>` tags that would get highlighted on page load by some JavaScript.

This could be really cumbersome to write out making writing tutorials less appealing.

This brings me to the current solution, using [Zola](https://www.getzola.org/) and [GitHub Pages](https://pages.github.com/).

Zola is an interesting piece of software that turns a collection of [Markdown](https://www.markdownguide.org/) pages into a static website. This means instead of having to write all the HTML tags, I can instead just write Markdown which is much faster/enjoyable.

This also means the site is faster as there is nothing else for the server to do other than cough up the page you asked for. The syntax highlighting is done during the conversion so your browser doesn't need to run any JS to do the highlighting either.

The source for the website is on a public [GitHub repo](https://github.com/alchitry/alchitry.github.io). If you ever discover something you think should be changed, you can create a pull request with the change and making it live is then as simple as accepting the request.

I'm currently in the process of porting over all the old pages so most of the pages still just link to the old Square Space site. I hope to have this done by the end of the week.

Let me know what you think of the new site over at the [new forum](https://forum.alchitry.com/)!

## New Forum

For quite some time, the forum we had was closed down (read-only). I did this for two main reasons, spam was rampant and I was bad about checking it and responding to posts.

It was easier for me to just answer emails. However, some things are nice to have in a public place.

I spent some time last week setting up a [Discourse](https://www.discourse.org/) forum and porting over the data from the old MyBB forum.

If you had an account on the old forum and posted something, your account should still exist on the new forum.

All the old posts are now in the *Legacy Posts* category and are still read-only. The formatting of some of the posts didn't transfer perfectly but at least all the information is still there.

There are now new categories that you can post to and I should get a notification when this happens.

Discourse also seems to handle the spam substantially better than anything I've tried before. The forum has already been hit with quite a few spam  sign ups but most of them never got to post anything. The ones that did manage to post are very easy to clean up.

Hopefully this time around the forum will be a great place to ask questions and get answers.

## Alchitry Labs 2.0.7

There have also been some new releases of [Alchitry Labs](https://alchitry.com/Alchitry-Labs-V2/download.html).

Since the last blog post about 2.0.5 there have been some major under the hood upgrades.

Apart for the typical bug fixes, 2.0.6 brought in basic auto-complete to make life a little easier when writing Lucid.

2.0.7 is where most of the updates happened.
### Syntax Changes

First off, there were a couple of syntax tweaks to Lucid V2.

The grammar was updated to allow for trailing commas in lists. 

For example...

``` lucid
module myModule (
    input clk,
    input rst,
    output out, // <=== trailing comma used to be a syntax error
)
```

A small breaking change renamed `$widthOf()` to `$width()`. I just felt like the *Of* portion didn't really fit.
### New Component Library

When I went to port the components from the *Component Library* over I wanted to structure things a bit differently.

The old version threw all the components into a single folder and used an XML file to provide information about them. This method didn't scale very well and adding new files was annoying.

The new version instead puts all the information about a component into a special JSON style comment in the component itself.

For example, here is the header for the `wave` component.

```lucid
/**  
    "name" : "Wave",  
    "description" : "Fancy wave effect for 8 LEDs. This is the module used in the default configuration that ships on the Alchitry boards."  
**/
```

When loading in the components, Alchitry Labs looks for the `/** **/` block (note the double star) and interprets this a JSON.

This comment is then stripped out so it is never seen by the user.

A component's category is determined by the directory structure making them much more organized.

This isn't implemented yet, but it will also automatically determine the dependencies of each component. This was all explicitly written in the XML file before.

All of this drastically simplifies adding new components but perhaps more importantly, it makes it much easier to add support for user created components.

User created components was something I would get request for fairly frequently but never implemented because of how complex it could be to correctly add a component.  In a future release, I'll implement this likely as simply checking for components in a `components` folder in the workspace directory.
### New Project Format

Since I was getting familiar with [KSerializer](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-core/kotlinx.serialization/-k-serializer/)  for doing the JSON parsing, it seemed like a good time to revisit the old XML style project files.

Here's the original *Base Project* .alp file.

```xml
<?xml version="1.0" encoding="UTF-8"?>  
<project name="Base Project" board="Alchitry Au" language="Lucid" version="4">  
  <files>  
    <src top="true">alchitryTop.luc</src>  
    <constraint lib="true">alchitry.acf</constraint>  
    <component>resetConditioner.luc</component>  
  </files>  
</project>
```

Here's the same project in the new JSON format.

```json
{  
    "template": {  
        "name": "Base Project",  
        "description": "Minimum boilerplate project for Alchitry boards",  
        "boards": ["Au", "Au+", "Cu"],  
        "priority": 0  
    },  
    "project": {  
        "type": "V1.0",  
        "projectName": "Base",  
        "board": "Alchitry Au",  
        "sourceFiles": [  
            {  
                "file": {  
                    "type": "DiskFile",  
                    "path": "source/alchitryTop.luc"  
                },  
                "top": true  
            },  
            {  
                "file": {  
                    "type": "Component",  
                    "path": "Conditioning/resetConditioner.luc"  
                }  
            }  
        ],  
        "constraintFiles": [  
            {  
                "file": {  
                    "type": "Component",  
                    "path": "Constraints/alchitry.acf"  
                }  
            }  
        ]  
    }  
}
```

The sample above includes the `template` section that only exists on example projects and is stripped off before being saved as a user project. The idea behind this is the same as adding the JSON section to the components. All the template information used to be in a rigid directory structure and XML files.

The old version didn't allow for sharing an example project across multiple boards. The new one, as you probably noticed, allows for a list of compatible boards to be specified.

The `priority` field is used to sort them for the UI.

As I alluded to, all of this is done using KSerializer so the conversion to/from JSON is largely free. There was a lot of ugly code that converted projects to/from XML that is no longer needed.

In 2.0.7, the XML project reader is still there so it will automatically convert your project to JSON, but it will be removed at some point so the XML parser dependency can be removed.
### UndefinedValues

Finally, the biggest update is in how `UndefinedValues` are  handled.

Without writing 10 more pages I'll try to give a quick overview of how values are represented in Alchitry Labs.

Something like the value `10` is represented as a `BitListValue`. That is, a list of bits. It is well defined, consisting of four bits with known values. It is also marked as constant and unsigned.

If you have a single bit, it is represented as a `BitValue`. This is basically the same as a `BitListValue` but can only represent a single bit.

Both of these are grouped into the `SimpleValue` class which represents basic *number* values.

In Lucid, you can pack multiple `SimpleValue` values into arrays or structs. To represent these, there are `ArrayValue` and `StructValue` classes.

For a while now, these have been well implement. However, there is one other type of `Value`, the `UndefinedValue`. 

So what exactly is an `UndefinedValue`? The only time this is used when there isn't a syntax error, is during a standalone error checking pass of a module with a parameter that doesn't have a default or test value. Follow all that? Great!

Here's an example.

```lucid
module counter #(
    SIZE : SIZE > 0, // Width of the output
    DIV = 0  : DIV >= 0, // number of bits to use as divisor
    TOP = 0  : TOP >= 0, // max value, 0 = none

    // direction to count, use 1 for up and 0 for down
    UP = 1 : UP == 1 || UP == 0
)(
    input clk,
    input rst,
    output value[SIZE]
) {

    .clk(clk), .rst(rst) {
        dff ctr[SIZE+DIV]
    }

    const MAX_VALUE = TOP << DIV // value when maxed out

    always {
        value = ctr.q[SIZE+DIV-1-:SIZE] // set the output

        if (UP) { // when this is an up counter
            ctr.d = ctr.q + 1 // increase
            if (TOP != 0 && ctr.q == MAX_VALUE) { // reached the top?
                ctr.d = 0 // reset
            }
        } else { // down counter
            ctr.d = ctr.q - 1 // decrease
            if (TOP != 0 && ctr.q == 0) { // reached the bottom?
                ctr.d = MAX_VALUE // reset to top
            }
        }
    }
}
```

The parameter `SIZE` doesn't have a default or test value so it will be assigned an `UndefinedValue` that has an `UndefinedSimpleWidth`. That means that it will be assumed to be a simple number, not an array or struct.

The issue is that this `UndefinedValue` will propagate through the parse. For example, the output `value` is an array of size `SIZE`. But `SIZE` is undefined so we don't actually know how big `value` is.

This means `value` will be an `UndefinedValue` with a width of `UndefinedArrayWidth`. Most values have their width defined simply by their value. In other words, a `BitListValue` of four bits has a `BitListWidth` with size four (a class that just holds the number of bits). However, `UndefinedValue` can have any width that may or may not be known.

Keeping track of the width helps with providing errors. For example, if we tried to use something that had a width of `UndefinedArrayWidth` where an array can't be used, we can provide an error before the module is instantiated.

All of this was implement in 2.0.7 and fairly well tested through [these tests](https://github.com/alchitry/Alchitry-Labs-V2/blob/cb8faec1a29bb65730e17c26c32177c2a66dc487/src/test/kotlin/UndefinedValueTests.kt).

The propagation of `UndefinedValue` through an error checking parse means there isn't a ton of information for the IDE to use to provide you with meaningful feedback until your module is instantiated and the value is no longer undefined.

You can avoid all this by simply providing a test value using the `~` operator.

```lucid
    SIZE ~ 8 : SIZE > 0, // Width of the output
```

This says that `8` is a reasonable test value for `SIZE` but shouldn't be used as a default value. In contrast to using `=`, a value for `SIZE` will still be required when someone instantiates this module.

This is a new Lucid V2 feature.