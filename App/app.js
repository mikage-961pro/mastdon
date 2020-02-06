var CLOSURE_UNCOMPILED_DEFINES = {};
var CLOSURE_NO_DEPS = true;
if(typeof goog == "undefined") document.write('<script src="target/app/goog/base.js"></script>');
document.write('<script src="target/app/goog/deps.js"></script>');
document.write('<script src="target/app/cljs_deps.js"></script>');
document.write('<script>if (typeof goog == "undefined") console.warn("ClojureScript could not load :main, did you forget to specify :asset-path?");</script>');
document.write('<script>goog.require("figwheel.connect");</script>');
document.write('<script>goog.require("process.env");</script>');
document.write('<script>goog.require("ivory.core");</script>');

document.write("<script>figwheel.connect.start();</script>");